# Static Site Deploy

Minimal Alpine Linux Docker image with `nginx` exposed, `awscli` and an s3 deployment script installed.

This is useful as an intermediate container for  static site build artefacts. This image can be used
as a container for static websites, and the resulting artefact can be viewed locally, or deployed to an S3 bucket.

## Commands

- `nginx` - Serve static files from `/var/www/html` (default)
- `s3sync` - Synchronize the files in `/var/www/html` with s3 bucket

## Environment Options

For s3sync:

- `AWS_ACCESS_KEY` - AWS Access Key (required)
- `AWS_SECRET_KEY` - AWS Secret Key (required)
- `AWS_BUCKET_NAME` - AWS Bucket Name

## Status

Experimental. Work in progress.
