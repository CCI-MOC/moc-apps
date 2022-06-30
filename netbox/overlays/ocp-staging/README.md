# Netbox staging deployment

This inherits from the `ocp-prod` deployment, but it makes the following changes:

- Deploys into `netbox-staging` namespace
- Only local, volume-based database backups
- Uses `netbox-staging` keycloak client (instead of `netbox`)
- Gets client secret from `cluster/ocp-staging/netbox/sso-clientsecret-moc`

## Things I had to do outside of this repository

- Create a new keycloak client
- Create a new secret in AWS SecretsManager

## Things you will need to do

Because we're using the upstream Netbox image, which doesn't support automatic group sync, you will need to manually configure groups in the database before you can log in to Netbox:

- Run `psql` in one of the postgres containers and connect to the `netbox` database
- Create the `netbox-admins` group:

  ```
  insert into auth_group (name) values ('netbox-admins');
  ```

Because we're setting...

```
REMOTE_AUTH_STAFF_GROUPS = ["netbox-admins"]
REMOTE_AUTH_SUPERUSER_GROUPS = ["netbox-admins"]
```

...in the netbox configuration, this will give any members of the `netbox-admins` keycloak group admin access (as long as you make this change *before* anyone logs in). We could probably automate this via some sort of initcontainer or something.
