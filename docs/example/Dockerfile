FROM node:latest as build

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

# copy your app to /user/src/app
ADD . .

# Build the site using yarn
RUN yarn install --pure-lockfile --ignore-optional --no-progress

FROM panubo/staticsite:latest

# Copy build artefacts to staticsite image
# COPY --from=build /usr/src/app/dist /var/www/html

WORKDIR /var/www/html

# install the template install
COPY env-config.js.tmpl .

ENV RENDER_TEMPLATE_ENV_CONFIG=/var/www/html/env-config.js.tmpl
