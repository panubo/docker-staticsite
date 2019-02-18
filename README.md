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

## Status

Experimental.
