This directory contains the namespaced elements of [External
Secrets][].

[external secrets]: https://github.com/external-secrets/kubernetes-external-secrets

Installed via:

```
helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
helm template --include-crds --output-dir ./output_dir moc external-secrets/kubernetes-external-secrets --set serviceMonitor.enabled=true
```

And then organized using [halberd][].

[halberd]: https://github.com/larsks/halberd
