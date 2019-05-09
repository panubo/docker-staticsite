# Static Site Deploy

Minimal Alpine Linux Docker image with `nginx`, `awscli` and a deployment script installed.

This is useful as an intermediate container for holding static website build artefacts. This image can then be used
as a container for holding static websites. And the resulting image artefact can be used to view the site, or used to deploy the site to an S3 website bucket, or a bucket backed CloudFront distribution.

## Entrypoint Commands

- `nginx` - Serve static files from `/var/www/html` (default)
- `s3sync` - Synchronize the files in `/var/www/html` with a s3 bucket (uses awscli).

## Environment Options

For s3sync:

- `AWS_ACCESS_KEY` - AWS Access Key (optional)
- `AWS_SECRET_KEY` - AWS Secret Key (optional)
- `AWS_BUCKET_NAME` - AWS Bucket Name (required).
- `CACHE_CONTROL_DEFAULT="public, max-age=3600"` - Default Cache-Control header to set (optional).
- `CACHE_CONTROL_DEFAULT_OVERRIDE="public, max-age=60, s-maxage=60"` - Alternate default Cache-Control header (optional).
- `CACHE_CONTROL_OVERRIDE_N` - Override the Cache-Control header for a file.

### Cache Control Override

`CACHE_CONTROL_OVERRIDE_N` can be defined as `FILE:VALUE` eg. `index.html:public max-age=30`. If `VALUE` is exclude the `CACHE_CONTROL_DEFAULT_OVERRIDE` is used. Multiple overrides can be set by changing `_N`. Can be replaced with any alphanumeric value eg `CACHE_CONTROL_OVERRIDE_INDEX` and `CACHE_CONTROL_OVERRIDE_404`.

## Status

Experimental.

### Known issues

* When using s3sync the cache-control will only be updated when the file is also updated.

### Todo

* Implement similar Cache-Control functionality for nginx hosted static sites.
