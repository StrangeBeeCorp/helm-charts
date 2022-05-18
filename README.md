# thehive helm charts

Run the command:

To Verify if the templates are correct:
```bash
helm install thehive ./ --values values.yaml -n thehive --create-namespace --dry-run --debug
```
Apply the templates:

```bash
helm install thehive ./ --values values.yaml -n thehive --create-namespace