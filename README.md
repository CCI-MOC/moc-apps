This repository manages ArgoCD applications deployed on [MOC][] managed
clusters.

The directory layout of this repository follows the standards of the
[Operate First][] project (specifically [ADR-0009][]).

[moc]: https://massopen.cloud
[operate first]: https://www.operate-first.cloud/
[adr-0009]: https://github.com/operate-first/blueprint/blob/main/docs/adr/0009-cluster-resources.md

## Validations to make your life easier

### Pre-commit checks

Configure linters to run before each commit by install the
`pre-commit` tool:

```
pip install pre-commit
```

And then enabling it for your working directory. From inside this
repository, run:

```
pre-commit install
```


### Pre-push checks

There are some checks we may not want to run for each commit, but we
do want to run before pushing changes up to GitHub.  First, make sure
you have the [openshift-schemas][] repository checked out:

[openshift-schemas]: https://github.com/CCI-MOC/openshift-schemas

```
git -C .. clone https://github.com/cci-moc/openshift-schemas
```

And make sure [kubeval][] is somewhere in your path.

[kubeval]: https://github.com/instrumenta/kubeval

Then place the following in `.git/hooks/pre-push` in your local
checkout of the `moc-apps` repository:

```
#!/bin/sh

./ci/validate-manifests.sh -s ../openshift-schemas/schemas
```

Ensure the file is executable:

```
chmod 755 .git/hooks/pre-push
```

This will run `kustomize build` on all overlays and validate the
output using `kubeval` prior to each push.
