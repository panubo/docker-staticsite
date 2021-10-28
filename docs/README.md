# Node Static Site Example

This is intended as an example of how staticsite can be used with a Node application:

### `env-config.js.tmpl`

A basic [gomplate](https://docs.gomplate.ca/) template which will be used to render out `env-config.js` at runtime with the value of `MYCONFIG` environment variable:

```
window._env_ = {
    "myconfig": "{{ env.Getenv "MYCONFIG" }}",
}
```

### `Dockerfile`

First we need a basic multi-stage Dockerfile with a node build stage and a final stage for staticsite:

```Dockerfile
FROM node:latest as build

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

# copy your app to /user/src/app
ADD . .

# Build the site using yarn
RUN yarn install --pure-lockfile --ignore-optional --no-progress

FROM panubo/staticsite:latest

# Copy build artefacts to staticsite image
COPY --from=build /usr/src/app/dist /var/www/html

WORKDIR /var/www/html

# install the template install
COPY env-config.js.tmpl .

ENV RENDER_TEMPLATE_ENV_CONFIG=/var/www/html/env-config.js.tmpl
```

## Code Example

Include the generated `env-config.js` file in your HTML page:

```html
<script src="env-config.js"></script>
```

To utilise the environment variable in your application you could reference it as follows:

```javascript
let myconfig = window._env_.myconfig;
...
// do something with myconfig value
```

## Runtime Usage

To use the image:

```bash
# build the image
docker build -t myimage .
# Set MYCONFIG at runtime to the desired value when running nginx
docker run --rm -it -P -e MYCONFIG=somevalue  myimage nginx
```
