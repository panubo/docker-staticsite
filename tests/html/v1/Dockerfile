FROM panubo/staticsite:test

ENV \
  CONTENT_TYPE_OVERRIDE_=".well-known/apple-app-site-association:application/json" \
  CACHE_CONTROL_OVERRIDE_INDEX="index.html" \
  CACHE_CONTROL_OVERRIDE_404="404.html" \
  CACHE_CONTROL_DEFAULT_OVERRIDE="public, max-age=60, s-maxage=60"

COPY . /var/www/html
