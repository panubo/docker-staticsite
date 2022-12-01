FROM panubo/staticsite:test

ENV \
  CONTENT_TYPE_OVERRIDE_=".well-known/apple-app-site-association:application/json" \
  CONTENT_TYPE_OVERRIDE_NOMIME_JSON="no-mime-json:application/json" \
  CACHE_CONTROL_OVERRIDE_INDEX="index.html" \
  CACHE_CONTROL_OVERRIDE_404="404.html" \
  CACHE_CONTROL_DEFAULT_OVERRIDE="public, max-age=60, s-maxage=60" \
  CACHE_CONTROL_OVERRIDE_SPECIAL="special-cache.html:public, max-age=1200" \
  CONTENT_TYPE_OVERRIDE_CACHED_JSON="cached-json:application/json" \
  CACHE_CONTROL_OVERRIDE_CACHED_JSON="cached-json:public, max-age=1200"

COPY . /var/www/html
