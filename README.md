# Static Site

Minimal Alpine Linux Docker image with `nginx`, `awscli` and `gomplate`. Also included are scripts for
deploying to S3 and templating files.

This is useful as an intermediate container for holding static website build artefacts. This image can then be used
as a container for holding a static website. And the resulting image artefact can be used to serve the site, or used to deploy the site to an S3 website bucket, or a bucket backed CloudFront distribution.

This image is available on quay.io `quay.io/panubo/staticsite` and AWS ECR Public `public.ecr.aws/panubo/staticsite`.

## Entrypoint Commands

- `nginx` - Serve static files from `/var/www/html` (default)
- `s3sync` - Synchronize the files in `/var/www/html` with a S3 bucket (uses awscli)
- `k8s-init` - Copy all files to volume and template files (intended for a Kubernetes initContainer)
- `k8s-nginx` - Start nginx only (no rendering, intended to run after `k8s-init`)

## Configuration / Environment Options

For `nginx` entrypoint:

- `PORT` - server port for nginx to listen on (Default: `8080`)
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

### Deployfile

Additional entrypoint pre-commands or post-commands can be specified in a `Deployfile.pre` and/or `Deployfile.post`.

- `DEPLOYFILE_PRE` - Pre Deployfile location, (Default: `/Deployfile.pre`)
- `DEPLOYFILE_POST` - Post Deployfile location, (Default: `/Deployfile.post`)
- `RUN_DEPLOYFILE_COMMANDS` - Set to `true` to enable this functionality.

Notes:

* When running `nginx` command, only the `DEPLOYFILE_PRE` is able to execute.
* Pre and post Deployfile is disabled for the `k8s-*` entrypoints

### Cache Control Override

`CACHE_CONTROL_OVERRIDE_N` can be defined as `FILE:VALUE` eg. `index.html:public max-age=30`. If `VALUE` is exclude the `CACHE_CONTROL_DEFAULT_OVERRIDE` is used. Multiple overrides can be set by changing `_N`. Can be replaced with any alphanumeric value eg `CACHE_CONTROL_OVERRIDE_INDEX` and `CACHE_CONTROL_OVERRIDE_404`.

**See known issues**

### Control Type Override

`CONTENT_TYPE_OVERRIDE_N` can be defined as `FILE:VALUE` eg. `mydatafile:application/json`. Multiple overrides can be set by changing `_N`. Can be replaced with any alphanumeric value eg `CONTENT_TYPE_OVERRIDE_INDEX` and `CONTENT_TYPE_OVERRIDE_404`.

**See known issues**

## Usage Examples

See [docs](./docs/) for usage examples.

## Status

This is used for deploying production sites, however it should be considered subject to functionality changes.

## v0.4.0 Upgrade **BREAKING CHANGES**

There are two main breaking changes includes in the v0.4.0 release.

**Run as non-root**

The image is setup to be run as non-root. This requires any content added to the image be owned by the `nginx` user. This can be achieved with one of the following methods.

Using `COPY --chown=nginx:nginx . /var/www/html` (recommended)

Or, using

```
USER root
RUN chown -R nginx:nginx /var/www/html
USER nginx
```

Alternatively this change can be simply reverted by adding `USER root` to your downstream image.

**Change nginx port to 8080**

Previously nginx listened on port `80` however this is considered a privileged port, the image now defaults to listening on port `8080`. This can be overridden by setting the env var `PORT=80`.

### Known issues

* Setting both cache control override and content type override may result in unexpected behaviour.

### TODO

* Implement similar Cache-Control functionality for Nginx hosted static sites.
