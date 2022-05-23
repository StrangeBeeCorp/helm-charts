# Thehive Helm Chart


To Verify if the templates are correct:
```bash
helm install thehive ./ --values values.yaml -n thehive --create-namespace --dry-run --debug
```
Deploy chart:

```bash
helm install thehive ./ --values values.yaml -n thehive --create-namespace
```

Update helm deployment:

```bash
helm upgrade thehive ./ --values values.yaml -n thehive
```