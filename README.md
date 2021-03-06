# Static Site

Minimal Alpine Linux Docker image with `nginx`, `awscli` and `gomplate`. Also included are scripts for
deploying to S3 and templating files.

This is useful as an intermediate container for holding static website build artefacts. This image can then be used
as a container for holding a static website. And the resulting image artefact can be used to serve the site, or used to deploy the site to an S3 website bucket, or a bucket backed CloudFront distribution.

## Entrypoint Commands

- `nginx` - Serve static files from `/var/www/html` (default)
- `s3sync` - Synchronize the files in `/var/www/html` with a S3 bucket (uses awscli).

## Configuration / Environment Options

For `nginx` entrypoint:

- `NGINX_SERVER_ROOT` - server web root (Default: `/var/www/html`)
- `NGINX_SERVER_INDEX` - server index page(s) (Default: `index.html index.htm`)
- `NGINX_SINGLE_PAGE_ENABLED` - if set to `true` all requests will be routed through `/$NGINX_SINGLE_PAGE_INDEX`
- `NGINX_SINGLE_PAGE_INDEX` - When single page mode is enabled, route request to this page (Default: `index.html`)

For `s3sync` entrypoint:

- `AWS_ACCESS_KEY` - AWS Access Key (optional)
- `AWS_SECRET_KEY` - AWS Secret Key (optional)
- `AWS_BUCKET_NAME` - AWS Bucket Name (required).
- `CACHE_CONTROL_DEFAULT="public, max-age=3600"` - Default Cache-Control header to set (optional).
- `CACHE_CONTROL_DEFAULT_OVERRIDE="public, max-age=60, s-maxage=60"` - Alternate default Cache-Control header (optional).
- `CACHE_CONTROL_OVERRIDE_N` - Override the Cache-Control header for a file.
- `CONTENT_TYPE_OVERRIDE_N` - Override the Cache-Control header for a file.

### Templater

The templater function runs with both entrypoint commands. Useful for generating `env.js` configuration for dynamically configurable JS apps.

Templates must be written in [gomplate](https://docs.gomplate.ca/) template syntax. All templates must be written to utilise environment variables as the context data source.

- `RENDER_TEMPLATE_N` - full path to template file to render. If template ends in `.tmpl` it will be removed from the output file.

### Cache Control Override

`CACHE_CONTROL_OVERRIDE_N` can be defined as `FILE:VALUE` eg. `index.html:public max-age=30`. If `VALUE` is exclude the `CACHE_CONTROL_DEFAULT_OVERRIDE` is used. Multiple overrides can be set by changing `_N`. Can be replaced with any alphanumeric value eg `CACHE_CONTROL_OVERRIDE_INDEX` and `CACHE_CONTROL_OVERRIDE_404`.

**See known issues**

### Control Type Override

`CONTENT_TYPE_OVERRIDE_N` can be defined as `FILE:VALUE` eg. `mydatafile:application/json`. Multiple overrides can be set by changing `_N`. Can be replaced with any alphanumeric value eg `CONTENT_TYPE_OVERRIDE_INDEX` and `CONTENT_TYPE_OVERRIDE_404`.

**See known issues**

## Status

Experimental.

### Known issues

* When using s3sync the `cache-control` will only be updated when the file is also updated.
* When using s3sync the `content-type` will only be updated when the file is also updated.
* Setting both cache control override and content type override may result in unexpected behavior.

### TODO

* Implement similar Cache-Control functionality for Nginx hosted static sites.
