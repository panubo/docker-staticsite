FROM panubo/staticsite:test

ENV \
  CONTENT_TYPE_OVERRIDE_=".well-known/apple-app-site-association:application/json" \
  CACHE_CONTROL_OVERRIDE_INDEX="index.html" \
  CACHE_CONTROL_OVERRIDE_404="404.html" \
  CACHE_CONTROL_DEFAULT_OVERRIDE="public, max-age=60, s-maxage=60" \
  CACHE_CONTROL_OVERRIDE_SPECIAL="special-cache.html:public, max-age=600" \
  RENDER_TEMPLATE_ENV_CONFIG=/var/www/html/env-config.js.tmpl \
  RENDER_TEMPLATE_ENV_CONFIG2=env-config2.js.tmpl

COPY --chown=nginx:nginx . /var/www/html
