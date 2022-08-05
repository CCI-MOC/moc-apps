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

./ci/validate-manifests.sh
```

Ensure the file is executable:

```
chmod 755 .git/hooks/pre-push
```

This will run `kustomize build` on all overlays and validate the
output using `kubeval` prior to each push.

## Deploying Secrets

Secrets for both `ocp-staging` and `ocp-prod` are stored in AWS Secret Manager
and accessed on the cluster via `ExternalSecret`. AWS Credentials for the
`mocops` user can be found in BitWarden.

- Login to AWS and navigate to Secret Manager.
- Select `Store a New Secret` and select `Other type of secret`.
- Input the value under the plain text tab. Keep the default encryption key.
- The name of the secret should be `cluster/<cluster_name>/<namespace>/<secret_name>`.
- Under tags, Add `cluster` as key and the name of the cluster as `value`.
  The secret will not be accessible otherwise.
- Create a `.yaml` manifest for the `ExternalSecret`. See [example][].

[example]: https://github.com/CCI-MOC/moc-apps/blob/52400857a5c6cd70c491749116143ad8f3a85648/acct-mgt/overlays/ocp-staging/externalsecrets.yaml
