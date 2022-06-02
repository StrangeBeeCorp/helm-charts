check:
  helm install thehive ./ --values values.yaml -n thehive --create-namespace --dry-run --debug

install:
  helm install thehive ./ --values values.yaml -n thehive --create-namespace

upgrade:
  helm upgrade thehive ./ --values values.yaml -n thehive