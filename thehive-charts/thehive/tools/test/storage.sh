#!/usr/bin/env bash

set -e

NAMESPACE="${NAMESPACE:-thehive}"
THEHIVE_URL="${THEHIVE_URL:-http://127.0.0.1:9000}"
ADMIN_USER="${ADMIN_USER:-admin@thehive.local}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-secret}"
ORG_USER="${ORG_USER:-thehive@thehive.local}"
ORG_PASSWORD="${ORG_PASSWORD:-thehive1234}"
ORG_NAME="${ORG_NAME:-demo}"
TEST_DIR="${TEST_DIR:-/tmp/thehive-storage-test}"

info()    { echo "[INFO] $1" >&2; }
success() { echo "[SUCCESS] $1" >&2; }
warning() { echo "[WARN] $1" >&2; }
error()   { echo "[ERROR] $1" >&2; }

check_prerequisites() {
  info "Checking prerequisites..."

  for cmd in kubectl curl jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "$cmd not found. Please install $cmd."
      exit 1
    fi
  done

  if ! command -v shasum >/dev/null 2>&1 && ! command -v sha256sum >/dev/null 2>&1; then
    error "shasum or sha256sum not found. Please install coreutils."
    exit 1
  fi

  success "All prerequisites met"
}

sha256() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

filesize() {
  stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

setup_test_dir() {
  info "Setting up test directory: ${TEST_DIR}"
  mkdir -p "${TEST_DIR}"
  cd "${TEST_DIR}"
  success "Test directory ready"
}

setup_port_forward() {
  if curl -s -o /dev/null -w '%{http_code}' "${THEHIVE_URL}/api/status" 2>/dev/null | grep -q "200"; then
    info "TheHive already reachable at ${THEHIVE_URL}, skipping port-forward"
    return 0
  fi

  info "Setting up port-forward to TheHive service..."

  POD_NAME=$(kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=thehive -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

  if [ -z "$POD_NAME" ]; then
    error "No TheHive pod found in namespace ${NAMESPACE}"
    exit 1
  fi

  kubectl port-forward -n "${NAMESPACE}" svc/thehive 9000:9000 >/dev/null 2>&1 &
  PORT_FORWARD_PID=$!
  sleep 3

  info "Port-forward started (PID: ${PORT_FORWARD_PID})"
}

cleanup() {
  if [ -n "$PORT_FORWARD_PID" ]; then
    info "Stopping port-forward..."
    kill "$PORT_FORWARD_PID" 2>/dev/null || true
  fi

  if [ -d "${TEST_DIR}" ]; then
    info "Cleaning up test directory..."
    rm -rf "${TEST_DIR}"
  fi
}

trap cleanup EXIT INT TERM

check_service() {
  info "Checking if TheHive is ready..."

  local max_retries=30
  local count=0

  while [ "$count" -lt "$max_retries" ]; do
    status_code=$(curl -s -o /dev/null -w '%{http_code}' "${THEHIVE_URL}/api/v1/user/current" -u "${ADMIN_USER}:${ADMIN_PASSWORD}" 2>/dev/null || echo "000")

    if [ "${status_code}" = "200" ]; then
      success "TheHive is ready"
      return 0
    fi

    count=$((count + 1))
    warning "TheHive not ready yet (attempt ${count}/${max_retries}), waiting..."
    sleep 5
  done

  error "TheHive did not become ready in time"
  exit 1
}

create_test_files() {
  info "Creating test files..."

  echo "This is a test file for TheHive object storage verification." > small-file.txt
  echo "Storage integration test - $(date)" >> small-file.txt

  dd if=/dev/urandom of=medium-file.bin bs=1024 count=1024 2>/dev/null

  for i in $(seq 1 50000); do
    echo "Line $i: The quick brown fox jumps over the lazy dog. Lorem ipsum dolor sit amet."
  done > large-file.txt

  SMALL_SHA256=$(sha256 small-file.txt)
  MEDIUM_SHA256=$(sha256 medium-file.bin)
  LARGE_SHA256=$(sha256 large-file.txt)

  success "Test files created"
  info "  - small-file.txt ($(filesize small-file.txt) bytes, SHA256: ${SMALL_SHA256:0:16}...)"
  info "  - medium-file.bin ($(filesize medium-file.bin) bytes, SHA256: ${MEDIUM_SHA256:0:16}...)"
  info "  - large-file.txt ($(filesize large-file.txt) bytes, SHA256: ${LARGE_SHA256:0:16}...)"
}

create_test_case() {
  info "Creating test case for storage verification..."

  CASE_ID=$(curl -s -X POST "${THEHIVE_URL}/api/v1/case" \
    -H "Content-Type: application/json" \
    -H "X-Organisation: ${ORG_NAME}" \
    -u "${ORG_USER}:${ORG_PASSWORD}" \
    -d '{
      "title": "Object Storage Test Case",
      "description": "This case is used to test object storage integration",
      "severity": 1,
      "tlp": 0,
      "tags": ["storage-test", "automated-test"]
    }' 2>/dev/null | jq -r '._id' 2>/dev/null)

  if [ -z "$CASE_ID" ] || [ "$CASE_ID" = "null" ]; then
    error "Failed to create test case"
    exit 1
  fi

  success "Test case created (ID: ${CASE_ID})"
}

create_test_task() {
  info "Creating task in case..."

  TASK_ID=$(curl -s -X POST "${THEHIVE_URL}/api/v1/case/${CASE_ID}/task" \
    -H "Content-Type: application/json" \
    -H "X-Organisation: ${ORG_NAME}" \
    -u "${ORG_USER}:${ORG_PASSWORD}" \
    -d '{
      "title": "Storage verification task",
      "description": "Task for testing file attachments via object storage",
      "status": "InProgress"
    }' 2>/dev/null | jq -r '._id' 2>/dev/null)

  if [ -z "$TASK_ID" ] || [ "$TASK_ID" = "null" ]; then
    error "Failed to create task"
    exit 1
  fi

  success "Task created (ID: ${TASK_ID})"
}

upload_file_via_log() {
  local file=$1
  local description=$2

  info "Uploading ${file} via task log..."

  LOG_RESPONSE=$(curl -s -X POST "${THEHIVE_URL}/api/v1/task/${TASK_ID}/log" \
    -H "X-Organisation: ${ORG_NAME}" \
    -u "${ORG_USER}:${ORG_PASSWORD}" \
    -F "_json={\"message\": \"${description}\"};type=application/json" \
    -F "attachments=@${file}" \
    2>/dev/null)

  LOG_ID=$(echo "$LOG_RESPONSE" | jq -r '._id' 2>/dev/null)

  if [ -z "$LOG_ID" ] || [ "$LOG_ID" = "null" ]; then
    error "Failed to upload ${file}"
    return 1
  fi

  ATTACHMENT_ID=$(echo "$LOG_RESPONSE" | jq -r '.attachments[0]._id' 2>/dev/null)

  if [ -z "$ATTACHMENT_ID" ] || [ "$ATTACHMENT_ID" = "null" ]; then
    error "No attachment ID in response for ${file}"
    return 1
  fi

  success "Uploaded ${file} (Log ID: ${LOG_ID}, Attachment ID: ${ATTACHMENT_ID})"
  echo "$LOG_ID $ATTACHMENT_ID"
}

download_and_verify() {
  local file=$1
  local log_id=$2
  local attachment_id=$3
  local expected_sha256=$4

  info "Downloading and verifying ${file}..."

  local download_file="downloaded-${file}"

  curl -s -X GET "${THEHIVE_URL}/api/v1/log/${log_id}/attachment/${attachment_id}/download" \
    -H "X-Organisation: ${ORG_NAME}" \
    -u "${ORG_USER}:${ORG_PASSWORD}" \
    -o "${download_file}" 2>/dev/null

  if [ ! -f "${download_file}" ]; then
    error "Failed to download ${file}"
    return 1
  fi

  ACTUAL_SHA256=$(sha256 "${download_file}")

  if [ "$ACTUAL_SHA256" = "$expected_sha256" ]; then
    success "✓ ${file} verified (SHA256 match)"
    return 0
  else
    error "✗ ${file} verification failed (SHA256 mismatch)"
    error "  Expected: ${expected_sha256}"
    error "  Actual:   ${ACTUAL_SHA256}"
    return 1
  fi
}

upload_file_observable() {
  local file=$1

  info "Uploading ${file} as file observable..."

  OBS_RESPONSE=$(curl -s -X POST "${THEHIVE_URL}/api/v1/case/${CASE_ID}/observable" \
    -H "X-Organisation: ${ORG_NAME}" \
    -u "${ORG_USER}:${ORG_PASSWORD}" \
    -F "_json={\"dataType\": \"file\", \"message\": \"File observable test\"};type=application/json" \
    -F "attachment=@${file}" \
    2>/dev/null)

  OBS_ID=$(echo "$OBS_RESPONSE" | jq -r '.[0]._id' 2>/dev/null)

  if [ -z "$OBS_ID" ] || [ "$OBS_ID" = "null" ]; then
    error "Failed to upload ${file} as observable"
    return 1
  fi

  OBS_ATTACHMENT_ID=$(echo "$OBS_RESPONSE" | jq -r '.[0].attachment._id' 2>/dev/null)

  if [ -z "$OBS_ATTACHMENT_ID" ] || [ "$OBS_ATTACHMENT_ID" = "null" ]; then
    error "No attachment ID in observable response"
    return 1
  fi

  success "Uploaded ${file} as observable (Observable ID: ${OBS_ID}, Attachment ID: ${OBS_ATTACHMENT_ID})"
  echo "$OBS_ID $OBS_ATTACHMENT_ID"
}

download_observable_attachment() {
  local file=$1
  local obs_id=$2
  local attachment_id=$3
  local expected_sha256=$4

  info "Downloading and verifying observable ${file}..."

  local download_file="downloaded-obs-${file}"

  curl -s -X GET "${THEHIVE_URL}/api/v1/observable/${obs_id}/attachment/${attachment_id}/download" \
    -H "X-Organisation: ${ORG_NAME}" \
    -u "${ORG_USER}:${ORG_PASSWORD}" \
    -o "${download_file}" 2>/dev/null

  if [ ! -f "${download_file}" ]; then
    error "Failed to download observable ${file}"
    return 1
  fi

  ACTUAL_SHA256=$(sha256 "${download_file}")

  if [ "$ACTUAL_SHA256" = "$expected_sha256" ]; then
    success "✓ Observable ${file} verified (SHA256 match)"
    return 0
  else
    error "✗ Observable ${file} verification failed (SHA256 mismatch)"
    error "  Expected: ${expected_sha256}"
    error "  Actual:   ${ACTUAL_SHA256}"
    return 1
  fi
}

check_storage_backend() {
  info "Checking storage backend configuration..."

  POD_NAME=$(kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=thehive -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

  if [ -z "$POD_NAME" ]; then
    warning "Cannot determine storage backend (pod not found)"
    return 0
  fi

  S3_ENDPOINT=$(kubectl exec -n "${NAMESPACE}" "${POD_NAME}" -- env 2>/dev/null | grep TH_S3_ENDPOINT | cut -d= -f2)
  S3_BUCKET=$(kubectl exec -n "${NAMESPACE}" "${POD_NAME}" -- env 2>/dev/null | grep TH_S3_BUCKET | cut -d= -f2)

  if [ -n "$S3_ENDPOINT" ]; then
    success "Storage backend detected:"
    info "  Endpoint: ${S3_ENDPOINT}"
    info "  Bucket: ${S3_BUCKET}"
  else
    warning "No S3 endpoint configured (using local filesystem storage)"
  fi
}

run_storage_tests() {
  cd "${TEST_DIR}"

  info "=== Running Object Storage Tests ==="
  echo ""

  local failed=0

  info "Test 1: Small text file upload via task log"
  result=$(upload_file_via_log "small-file.txt" "Small text file test")
  SMALL_LOG_ID=$(echo "$result" | awk '{print $1}')
  SMALL_ATTACHMENT_ID=$(echo "$result" | awk '{print $2}')

  if [ -n "$SMALL_LOG_ID" ] && [ "$SMALL_LOG_ID" != "null" ]; then
    if download_and_verify "small-file.txt" "$SMALL_LOG_ID" "$SMALL_ATTACHMENT_ID" "$SMALL_SHA256"; then
      success "✓ Test 1 passed"
    else
      error "✗ Test 1 failed"
      failed=$((failed + 1))
    fi
  else
    error "✗ Test 1 failed (upload)"
    failed=$((failed + 1))
  fi
  echo ""

  info "Test 2: Medium binary file upload via task log"
  result=$(upload_file_via_log "medium-file.bin" "Medium binary file test (1MB)")
  MEDIUM_LOG_ID=$(echo "$result" | awk '{print $1}')
  MEDIUM_ATTACHMENT_ID=$(echo "$result" | awk '{print $2}')

  if [ -n "$MEDIUM_LOG_ID" ] && [ "$MEDIUM_LOG_ID" != "null" ]; then
    if download_and_verify "medium-file.bin" "$MEDIUM_LOG_ID" "$MEDIUM_ATTACHMENT_ID" "$MEDIUM_SHA256"; then
      success "✓ Test 2 passed"
    else
      error "✗ Test 2 failed"
      failed=$((failed + 1))
    fi
  else
    error "✗ Test 2 failed (upload)"
    failed=$((failed + 1))
  fi
  echo ""

  info "Test 3: Large text file upload via task log"
  result=$(upload_file_via_log "large-file.txt" "Large text file test (5MB)")
  LARGE_LOG_ID=$(echo "$result" | awk '{print $1}')
  LARGE_ATTACHMENT_ID=$(echo "$result" | awk '{print $2}')

  if [ -n "$LARGE_LOG_ID" ] && [ "$LARGE_LOG_ID" != "null" ]; then
    if download_and_verify "large-file.txt" "$LARGE_LOG_ID" "$LARGE_ATTACHMENT_ID" "$LARGE_SHA256"; then
      success "✓ Test 3 passed"
    else
      error "✗ Test 3 failed"
      failed=$((failed + 1))
    fi
  else
    error "✗ Test 3 failed (upload)"
    failed=$((failed + 1))
  fi
  echo ""

  info "Test 4: File observable upload"
  result=$(upload_file_observable "small-file.txt")
  OBS_ID=$(echo "$result" | awk '{print $1}')
  OBS_ATTACHMENT_ID=$(echo "$result" | awk '{print $2}')

  if [ -n "$OBS_ID" ] && [ "$OBS_ID" != "null" ]; then
    if download_observable_attachment "small-file.txt" "$OBS_ID" "$OBS_ATTACHMENT_ID" "$SMALL_SHA256"; then
      success "✓ Test 4 passed"
    else
      error "✗ Test 4 failed"
      failed=$((failed + 1))
    fi
  else
    error "✗ Test 4 failed (upload)"
    failed=$((failed + 1))
  fi
  echo ""

  return $failed
}

print_summary() {
  local failed=$1

  echo ""
  echo "=========================================="
  if [ $failed -eq 0 ]; then
    success "=== ALL TESTS PASSED ==="
    success "Object storage is working correctly!"
  else
    error "=== ${failed} TEST(S) FAILED ==="
    error "Object storage has issues!"
  fi
  echo "=========================================="
  echo ""

  if [ $failed -eq 0 ]; then
    info "Test case available in TheHive:"
    info "  Case ID: ${CASE_ID}"
  fi
  echo ""
}

main() {
  echo ""
  info "=== TheHive Object Storage Test ==="
  echo ""

  check_prerequisites
  check_storage_backend
  setup_test_dir
  setup_port_forward
  check_service

  echo ""
  create_test_files
  echo ""

  create_test_case
  create_test_task

  echo ""
  run_storage_tests
  TEST_RESULT=$?

  print_summary $TEST_RESULT

  exit $TEST_RESULT
}

main
