#!/usr/bin/env bash

NAMESPACE="${NAMESPACE:-thehive}"
THEHIVE_URL="${THEHIVE_URL:-http://127.0.0.1:9000}"
ADMIN_USER="${ADMIN_USER:-admin@thehive.local}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-secret}"
ORG_USER="${ORG_USER:-thehive@thehive.local}"
ORG_PASSWORD="${ORG_PASSWORD:-thehive1234}"
ORG_NAME="${ORG_NAME:-demo}"

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

  success "All prerequisites met"
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

api_call() {
  local expected_status=$1
  local method=$2
  local endpoint=$3
  local user=$4
  local data=$5
  shift 5
  local extra_headers=("$@")

  local curl_cmd="curl -s -o /tmp/response.json -w '%{http_code}' -X${method} \"${THEHIVE_URL}${endpoint}\" -H 'Content-Type: application/json'"

  for header in "${extra_headers[@]}"; do
    curl_cmd="${curl_cmd} -H '${header}'"
  done

  curl_cmd="${curl_cmd} -u \"${user}\" -d '${data}'"

  local status_code
  status_code=$(eval ${curl_cmd} 2>/dev/null || echo "000")

  if [ "${status_code}" = "${expected_status}" ]; then
    cat /tmp/response.json 2>/dev/null
    return 0
  else
    echo "[ERROR] API call failed: ${method} ${endpoint} -> HTTP ${status_code} (expected ${expected_status})" >&2
    local body
    body=$(cat /tmp/response.json 2>/dev/null)
    if [ -n "$body" ]; then
      echo "[ERROR] Response body: ${body}" >&2
    fi
    return 1
  fi
}

create_org() {
  info "Creating organization '${ORG_NAME}'..."

  if api_call 201 POST "/api/organisation" "${ADMIN_USER}:${ADMIN_PASSWORD}" '{
    "description": "Demo organisation for testing",
    "name": "'${ORG_NAME}'"
  }' > /dev/null 2>&1; then
    success "Organization '${ORG_NAME}' created"
  else
    warning "Organization '${ORG_NAME}' may already exist, continuing..."
  fi
}

create_orgadmin() {
  info "Creating org admin user '${ORG_USER}'..."

  USER_ID=$(api_call 201 POST "/api/v1/user" "${ADMIN_USER}:${ADMIN_PASSWORD}" '{
    "login": "'${ORG_USER}'",
    "name": "thehive",
    "organisation": "'${ORG_NAME}'",
    "profile": "org-admin",
    "password": "'${ORG_PASSWORD}'"
  }' 2>/dev/null | jq -r '._id' 2>/dev/null || echo "")

  if [ -n "$USER_ID" ] && [ "$USER_ID" != "null" ]; then
    if api_call 200 PUT "/api/v1/user/${USER_ID}/organisations" "${ADMIN_USER}:${ADMIN_PASSWORD}" '{
      "organisations": [
        {
          "organisation": "admin",
          "profile": "admin"
        },
        {
          "organisation": "'${ORG_NAME}'",
          "profile": "org-admin"
        }
      ]
    }' > /dev/null 2>&1; then
      success "User '${ORG_USER}' created with org admin privileges"
    fi
  else
    warning "User '${ORG_USER}' may already exist, continuing..."
  fi
}

create_customfields() {
  info "Creating custom fields..."

  if api_call 201 POST "/api/customField" "${ADMIN_USER}:${ADMIN_PASSWORD}" '{
    "name": "BusinessImpact",
    "reference": "businessimpact",
    "description": "Impact of the incident on business",
    "type": "string",
    "mandatory": false,
    "options": ["Critical", "High", "Medium", "Low"]
  }' > /dev/null 2>&1; then
    success "Custom field 'BusinessImpact' created"
  else
    warning "Custom field 'BusinessImpact' may already exist"
  fi

  if api_call 201 POST "/api/customField" "${ADMIN_USER}:${ADMIN_PASSWORD}" '{
    "name": "BusinessUnit",
    "reference": "businessunit",
    "description": "Targeted business unit",
    "type": "string",
    "mandatory": false,
    "options": ["VIP", "HR", "Security", "Sys Administrators", "Developers", "Sales", "Marketing", "Procurement", "Legal"]
  }' > /dev/null 2>&1; then
    success "Custom field 'BusinessUnit' created"
  else
    warning "Custom field 'BusinessUnit' may already exist"
  fi

  if api_call 201 POST "/api/customField" "${ADMIN_USER}:${ADMIN_PASSWORD}" '{
    "name": "SLA",
    "reference": "sla",
    "description": "Service Level Agreement in hours",
    "type": "integer",
    "mandatory": false,
    "options": [4, 8, 12, 24]
  }' > /dev/null 2>&1; then
    success "Custom field 'SLA' created"
  else
    warning "Custom field 'SLA' may already exist"
  fi

  if api_call 201 POST "/api/customField" "${ADMIN_USER}:${ADMIN_PASSWORD}" '{
    "name": "Contact",
    "reference": "contact",
    "description": "Email address of the contact",
    "type": "string",
    "mandatory": false,
    "options": []
  }' > /dev/null 2>&1; then
    success "Custom field 'Contact' created"
  else
    warning "Custom field 'Contact' may already exist"
  fi

  if api_call 201 POST "/api/customField" "${ADMIN_USER}:${ADMIN_PASSWORD}" '{
    "name": "Hits",
    "reference": "hits",
    "description": "Number of hits found during hunting",
    "type": "integer",
    "mandatory": false,
    "options": []
  }' > /dev/null 2>&1; then
    success "Custom field 'Hits' created"
  else
    warning "Custom field 'Hits' may already exist"
  fi
}

create_case_template() {
  info "Creating case template 'MISPEvent'..."

  if api_call 201 POST "/api/v1/caseTemplate" "${ORG_USER}:${ORG_PASSWORD}" '{
    "name": "MISPEvent",
    "titlePrefix": null,
    "severity": 2,
    "tlp": 2,
    "pap": 2,
    "tags": ["hunting"],
    "tasks": [
      {
        "order": 0,
        "title": "Search for IOCs on Mail gateway logs",
        "group": "default",
        "description": "Run queries in Mail gateway logs and look for IOCs of type IP, email addresses, hostnames, free text."
      },
      {
        "order": 1,
        "title": "Search for IOCs on Firewall logs",
        "group": "default",
        "description": "Run queries in firewall logs and look for IOCs of type IP, port"
      },
      {
        "order": 2,
        "title": "Search for IOCs on Web proxy logs",
        "group": "default",
        "description": "Run queries in web proxy logs and look for IOCs of type IP, domain, hostname, user-agent"
      }
    ],
    "customFields": [
      {
        "name": "hits",
        "value": null
      }
    ],
    "description": "Check if IOCs shared by the community have been seen on the network",
    "displayName": "MISP"
  }' > /dev/null 2>&1; then
    success "Case template 'MISPEvent' created"
  else
    warning "Case template 'MISPEvent' may already exist"
  fi
}

create_alerts() {
  info "Creating test alert..."

  ALERT_ID=$(api_call 201 POST "/api/v1/alert" "${ORG_USER}:${ORG_PASSWORD}" '{
    "caseTemplate": "MISPEvent",
    "customFields": [
      {
        "name": "hits",
        "value": null,
        "order": 0
      }
    ],
    "description": "Imported from MISP Event #1311.",
    "severity": 1,
    "source": "misp server",
    "sourceRef": "1311",
    "tags": ["tlp:white", "type:OSINT", "osint:lifetime=\"perpetual\""],
    "title": "CISA.gov - AA21-062A Mitigate Microsoft Exchange Server Vulnerabilities",
    "tlp": 0,
    "type": "misp"
  }' "X-Organisation: ${ORG_NAME}" | jq -r '._id')

  if [ -n "$ALERT_ID" ] && [ "$ALERT_ID" != "null" ]; then
    success "Alert created (ID: ${ALERT_ID})"

    info "Adding observables to alert..."

    api_call 201 POST "/api/v1/alert/${ALERT_ID}/observable" "${ORG_USER}:${ORG_PASSWORD}" '{
      "tlp": 0,
      "message": "imported from MISP event",
      "dataType": "ip",
      "data": ["5.254.43.18"],
      "ignoreSimilarity": false
    }' "X-Organisation: ${ORG_NAME}" > /dev/null

    api_call 201 POST "/api/v1/alert/${ALERT_ID}/observable" "${ORG_USER}:${ORG_PASSWORD}" '{
      "tlp": 0,
      "message": "imported from MISP event",
      "dataType": "ip",
      "data": ["5.2.69.14"],
      "ignoreSimilarity": false
    }' "X-Organisation: ${ORG_NAME}" > /dev/null

    api_call 201 POST "/api/v1/alert/${ALERT_ID}/observable" "${ORG_USER}:${ORG_PASSWORD}" '{
      "tlp": 0,
      "message": "imported from MISP event",
      "dataType": "hash",
      "data": ["65149e036fff06026d80ac9ad4d156332822dc93142cf1a122b1841ec8de34b5"],
      "ignoreSimilarity": false
    }' "X-Organisation: ${ORG_NAME}" > /dev/null

    api_call 201 POST "/api/v1/alert/${ALERT_ID}/observable" "${ORG_USER}:${ORG_PASSWORD}" '{
      "tlp": 0,
      "message": "imported from MISP event",
      "dataType": "ip",
      "data": ["211.56.98.146"],
      "ignoreSimilarity": false
    }' "X-Organisation: ${ORG_NAME}" > /dev/null

    success "Added observables to alert"
  else
    error "Failed to create test alert (empty or null _id returned)"
    error "Check that '${ORG_USER}' has 'manageAlert/create' permission in '${ORG_NAME}' and that the instance license allows it"
    exit 1
  fi
}

create_case() {
  info "Creating test case..."

  CASE_ID=$(api_call 201 POST "/api/v1/case" "${ORG_USER}:${ORG_PASSWORD}" '{
    "customFields": [
      {
        "name": "hits",
        "value": null,
        "order": 0
      }
    ],
    "description": "Case used to test Analyzers and Responders",
    "severity": 1,
    "title": "Analyzers and Responders development",
    "tlp": 0
  }' "X-Organisation: ${ORG_NAME}" | jq -r '._id')

  if [ -n "$CASE_ID" ] && [ "$CASE_ID" != "null" ]; then
    success "Case created (ID: ${CASE_ID})"

    info "Adding observables to case..."

    api_call 201 POST "/api/v1/case/${CASE_ID}/observable" "${ORG_USER}:${ORG_PASSWORD}" '{
      "tlp": 0,
      "message": "Analyzers and Responders development",
      "dataType": "ip",
      "data": ["8.8.8.8"],
      "ignoreSimilarity": false
    }' "X-Organisation: ${ORG_NAME}" > /dev/null

    api_call 201 POST "/api/v1/case/${CASE_ID}/observable" "${ORG_USER}:${ORG_PASSWORD}" '{
      "tlp": 0,
      "message": "Analyzers and Responders development ; EICAR test SHA256",
      "dataType": "hash",
      "data": ["275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f"],
      "ignoreSimilarity": false
    }' "X-Organisation: ${ORG_NAME}" > /dev/null

    success "Added observables to case"
  else
    error "Failed to create test case (empty or null _id returned)"
    error "Check that '${ORG_USER}' has 'manageCase/create' permission in '${ORG_NAME}' and that the instance license allows it"
    exit 1
  fi
}

add_alert_comments() {
  if [ -z "$ALERT_ID" ]; then
    return 0
  fi

  info "Adding comments to alert..."

  api_call 201 POST "/api/v1/alert/${ALERT_ID}/comment" "${ORG_USER}:${ORG_PASSWORD}" '{
    "message": "Initial triage completed. Alert contains IOCs related to Microsoft Exchange vulnerabilities."
  }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1

  api_call 201 POST "/api/v1/alert/${ALERT_ID}/comment" "${ORG_USER}:${ORG_PASSWORD}" '{
    "message": "Escalating to SOC team for further investigation."
  }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1

  success "Added comments to alert"
}

add_case_comments() {
  if [ -z "$CASE_ID" ]; then
    return 0
  fi

  info "Adding comments to case..."

  api_call 201 POST "/api/v1/case/${CASE_ID}/comment" "${ORG_USER}:${ORG_PASSWORD}" '{
    "message": "Case created for testing analyzer and responder integration."
  }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1

  api_call 201 POST "/api/v1/case/${CASE_ID}/comment" "${ORG_USER}:${ORG_PASSWORD}" '{
    "message": "Observables added. Ready for analysis."
  }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1

  success "Added comments to case"
}

create_case_tasks() {
  if [ -z "$CASE_ID" ]; then
    error "Cannot create tasks: CASE_ID is empty"
    exit 1
  fi

  info "Creating tasks in case..."

  TASK_ID_1=$(api_call 201 POST "/api/v1/case/${CASE_ID}/task" "${ORG_USER}:${ORG_PASSWORD}" '{
    "title": "Analyze malicious IP addresses",
    "description": "Run threat intelligence lookup on identified IP addresses",
    "status": "InProgress",
    "flag": false
  }' "X-Organisation: ${ORG_NAME}" | jq -r '._id' 2>/dev/null)

  TASK_ID_2=$(api_call 201 POST "/api/v1/case/${CASE_ID}/task" "${ORG_USER}:${ORG_PASSWORD}" '{
    "title": "Verify hash in malware databases",
    "description": "Check the SHA256 hash against VirusTotal and other malware databases",
    "status": "Waiting",
    "flag": false
  }' "X-Organisation: ${ORG_NAME}" | jq -r '._id' 2>/dev/null)

  api_call 201 POST "/api/v1/case/${CASE_ID}/task" "${ORG_USER}:${ORG_PASSWORD}" '{
    "title": "Document findings",
    "description": "Compile analysis results and document remediation steps",
    "status": "Waiting",
    "flag": true
  }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1

  if [ -n "$TASK_ID_1" ] && [ "$TASK_ID_1" != "null" ]; then
    success "Created 3 tasks in case"
  else
    error "Failed to create tasks in case (empty or null _id returned)"
    error "Check that '${ORG_USER}' has 'manageTask' permission in '${ORG_NAME}'"
    exit 1
  fi
}

add_task_logs() {
  if [ -z "$TASK_ID_1" ] || [ "$TASK_ID_1" = "null" ]; then
    return 0
  fi

  info "Adding logs to tasks..."

  api_call 201 POST "/api/v1/task/${TASK_ID_1}/log" "${ORG_USER}:${ORG_PASSWORD}" '{
    "message": "Started IP address analysis. Checking 8.8.8.8 reputation."
  }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1

  api_call 201 POST "/api/v1/task/${TASK_ID_1}/log" "${ORG_USER}:${ORG_PASSWORD}" '{
    "message": "IP 8.8.8.8 is Google Public DNS - likely false positive."
  }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1

  if [ -n "$TASK_ID_2" ] && [ "$TASK_ID_2" != "null" ]; then
    api_call 201 POST "/api/v1/task/${TASK_ID_2}/log" "${ORG_USER}:${ORG_PASSWORD}" '{
      "message": "Submitted hash to VirusTotal for analysis."
    }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1
  fi

  success "Added logs to tasks"
}

update_case_status() {
  if [ -z "$CASE_ID" ]; then
    return 0
  fi

  info "Updating case status to InProgress..."

  if api_call 204 PATCH "/api/v1/case/${CASE_ID}" "${ORG_USER}:${ORG_PASSWORD}" '{
    "status": "InProgress"
  }' "X-Organisation: ${ORG_NAME}" > /dev/null 2>&1; then
    success "Case status updated to InProgress"
  else
    warning "Failed to update case status"
  fi
}

verify_resources() {
  info "Verifying created resources..."
  echo ""

  local failed=0

  if curl -s -u "${ADMIN_USER}:${ADMIN_PASSWORD}" "${THEHIVE_URL}/api/organisation/${ORG_NAME}" 2>/dev/null | jq -e '.name == "'${ORG_NAME}'"' > /dev/null 2>&1; then
    success "✓ Organization '${ORG_NAME}' exists"
  else
    error "✗ Organization '${ORG_NAME}' not found"
    failed=$((failed + 1))
  fi

  if curl -s -u "${ADMIN_USER}:${ADMIN_PASSWORD}" "${THEHIVE_URL}/api/v1/user/${ORG_USER}" 2>/dev/null | jq -e '.login == "'${ORG_USER}'"' > /dev/null 2>&1; then
    success "✓ User '${ORG_USER}' exists"
  else
    error "✗ User '${ORG_USER}' not found"
    failed=$((failed + 1))
  fi

  local cf_count
  cf_count=$(curl -s -u "${ADMIN_USER}:${ADMIN_PASSWORD}" "${THEHIVE_URL}/api/customField" 2>/dev/null | jq '. | length' 2>/dev/null)
  if [ -n "$cf_count" ] && [ "$cf_count" -ge 5 ]; then
    success "✓ Custom fields exist (found ${cf_count})"
  else
    error "✗ Custom fields count: ${cf_count} (expected at least 5)"
    failed=$((failed + 1))
  fi

  if curl -s -u "${ORG_USER}:${ORG_PASSWORD}" -H "X-Organisation: ${ORG_NAME}" "${THEHIVE_URL}/api/v1/caseTemplate/MISPEvent" 2>/dev/null | jq -e '.name == "MISPEvent"' > /dev/null 2>&1; then
    success "✓ Case template 'MISPEvent' exists"
  else
    error "✗ Case template 'MISPEvent' not found"
    failed=$((failed + 1))
  fi

  if [ -n "$ALERT_ID" ] && [ "$ALERT_ID" != "null" ]; then
    local alert_data
    alert_data=$(curl -s -u "${ORG_USER}:${ORG_PASSWORD}" -H "X-Organisation: ${ORG_NAME}" "${THEHIVE_URL}/api/v1/alert/${ALERT_ID}" 2>/dev/null)
    if echo "$alert_data" | jq -e '._id' > /dev/null 2>&1; then
      local alert_obs
      alert_obs=$(curl -s -u "${ORG_USER}:${ORG_PASSWORD}" -H "X-Organisation: ${ORG_NAME}" -H "Content-Type: application/json" \
        "${THEHIVE_URL}/api/v1/query?name=observables" \
        -d '{"query":[{"_name":"getAlert","idOrName":"'${ALERT_ID}'"},{"_name":"observables"}]}' 2>/dev/null | jq '. | length' 2>/dev/null)
      local alert_comments
      alert_comments=$(curl -s -u "${ORG_USER}:${ORG_PASSWORD}" -H "X-Organisation: ${ORG_NAME}" -H "Content-Type: application/json" \
        "${THEHIVE_URL}/api/v1/query?name=comments" \
        -d '{"query":[{"_name":"getAlert","idOrName":"'${ALERT_ID}'"},{"_name":"comments"}]}' 2>/dev/null | jq '. | length' 2>/dev/null)
      success "✓ Alert ${ALERT_ID} exists (observables: ${alert_obs}, comments: ${alert_comments})"
    else
      error "✗ Alert ${ALERT_ID} not found"
      failed=$((failed + 1))
    fi
  fi

  if [ -n "$CASE_ID" ] && [ "$CASE_ID" != "null" ]; then
    local case_data
    case_data=$(curl -s -u "${ORG_USER}:${ORG_PASSWORD}" -H "X-Organisation: ${ORG_NAME}" "${THEHIVE_URL}/api/v1/case/${CASE_ID}" 2>/dev/null)
    if echo "$case_data" | jq -e '._id' > /dev/null 2>&1; then
      local case_status
      case_status=$(echo "$case_data" | jq -r '.status' 2>/dev/null)
      local case_obs
      case_obs=$(curl -s -u "${ORG_USER}:${ORG_PASSWORD}" -H "X-Organisation: ${ORG_NAME}" -H "Content-Type: application/json" \
        "${THEHIVE_URL}/api/v1/query?name=observables" \
        -d '{"query":[{"_name":"getCase","idOrName":"'${CASE_ID}'"},{"_name":"observables"}]}' 2>/dev/null | jq '. | length' 2>/dev/null)
      success "✓ Case ${CASE_ID} exists (status: ${case_status}, observables: ${case_obs})"

      local case_comments
      case_comments=$(curl -s -u "${ORG_USER}:${ORG_PASSWORD}" -H "X-Organisation: ${ORG_NAME}" -H "Content-Type: application/json" \
        "${THEHIVE_URL}/api/v1/query?name=comments" \
        -d '{"query":[{"_name":"getCase","idOrName":"'${CASE_ID}'"},{"_name":"comments"}]}' 2>/dev/null | jq '. | length' 2>/dev/null)
      success "✓ Case has ${case_comments} comments"

      local tasks_count
      tasks_count=$(curl -s -u "${ORG_USER}:${ORG_PASSWORD}" -H "X-Organisation: ${ORG_NAME}" "${THEHIVE_URL}/api/v1/query?name=tasks" \
        -H "Content-Type: application/json" \
        -d '{"query":[{"_name":"getCase","idOrName":"'${CASE_ID}'"},{"_name":"tasks"}]}' 2>/dev/null | jq '. | length' 2>/dev/null)
      if [ -n "$tasks_count" ] && [ "$tasks_count" -ge 3 ]; then
        success "✓ Case has ${tasks_count} tasks"
      else
        error "✗ Expected at least 3 tasks, found: ${tasks_count}"
        failed=$((failed + 1))
      fi
    else
      error "✗ Case ${CASE_ID} not found"
      failed=$((failed + 1))
    fi
  fi

  echo ""
  if [ $failed -eq 0 ]; then
    success "All verifications passed!"
  else
    error "Verification completed with ${failed} failures"
  fi
  echo ""

  return $failed
}

main() {
  echo ""
  info "=== TheHive Helm Chart - Smoke Test ==="
  echo ""

  check_prerequisites
  setup_port_forward
  check_service

  echo ""
  info "Starting data initialization..."
  echo ""

  create_org
  create_orgadmin
  create_customfields
  create_case_template

  create_alerts
  add_alert_comments

  create_case
  add_case_comments
  create_case_tasks
  add_task_logs
  update_case_status

  echo ""
  success "=== Data initialization completed ==="
  echo ""

  verify_resources
  local rc=$?

  if [ $rc -ne 0 ]; then
    error "=== Smoke test failed with ${rc} verification errors ==="
    exit $rc
  fi

  echo ""
  success "=== Smoke test completed successfully ==="
  echo ""
  info "You can now login to TheHive with:"
  info "  - Admin user: ${ADMIN_USER} / ${ADMIN_PASSWORD}"
  info "  - Org user:   ${ORG_USER} / ${ORG_PASSWORD}"
  echo ""
  info "Created resources:"
  info "  - Organization: ${ORG_NAME}"
  info "  - Custom fields: 5"
  info "  - Case template: MISPEvent"
  if [ -n "$ALERT_ID" ] && [ "$ALERT_ID" != "null" ]; then
    info "  - Alert: ${ALERT_ID} (with 4 observables and 2 comments)"
  fi
  if [ -n "$CASE_ID" ] && [ "$CASE_ID" != "null" ]; then
    info "  - Case: ${CASE_ID} (with 2 observables, 3 tasks, logs, and comments)"
  fi
  echo ""
}

main
