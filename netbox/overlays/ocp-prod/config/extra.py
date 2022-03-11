import os

CORS_ORIGIN_ALLOW_ALL = True
LOGIN_REQUIRED = True
REMOTE_AUTH_AUTO_CREATE_GROUPS = True
REMOTE_AUTH_AUTO_CREATE_USER = True
REMOTE_AUTH_ENABLED = True
REMOTE_AUTH_GROUP_HEADER = "HTTP_X_FORWARDED_GROUPS"
REMOTE_AUTH_GROUP_SEPARATOR = ","
REMOTE_AUTH_GROUP_SYNC_ENABLED = True
REMOTE_AUTH_HEADER = "HTTP_X_FORWARDED_PREFERRED_USERNAME"
REMOTE_AUTH_STAFF_GROUPS = ["netbox-admins"]
REMOTE_AUTH_SUPERUSER_GROUPS = ["netbox-admins"]
SKIP_SUPERUSER = True

# See:
# - https://netbox.readthedocs.io/en/stable/configuration/optional-settings/#storage_backend
# - https://django-storages.readthedocs.io/en/stable/backends/amazon-S3.html
STORAGE_BACKEND = "storages.backends.s3boto3.S3Boto3Storage"
STORAGE_CONFIG = {
    "AWS_STORAGE_BUCKET_NAME": os.environ["BUCKET_NAME"],
    "AWS_S3_REGION_NAME": os.environ["BUCKET_REGION"],
    "AWS_S3_ADDRESSING_STYLE": "path",
    "AWS_S3_ENDPOINT_URL": "https://{}:{}".format(
        os.environ["BUCKET_HOST"], os.environ["BUCKET_PORT"]
    ),
    "AWS_S3_VERIFY": "/run/secrets/kubernetes.io/serviceaccount/service-ca.crt",
    "AWS_S3_CUSTOM_DOMAIN": "s3-openshift-storage.apps.ocp-prod.massopen.cloud/{}".format(
        os.environ["BUCKET_NAME"]
    ),
}
