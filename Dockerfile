FROM node:16-alpine as builder

COPY assets /bwhc-frontend/assets
COPY components /bwhc-frontend/components
COPY layouts /bwhc-frontend/layouts
COPY pages /bwhc-frontend/pages
COPY plugins /bwhc-frontend/plugins
COPY static /bwhc-frontend/static
COPY store /bwhc-frontend/store
COPY nuxt.config.js /bwhc-frontend
COPY package.json /bwhc-frontend
COPY package-lock.json /bwhc-frontend
COPY yarn.lock /bwhc-frontend

WORKDIR /bwhc-frontend

RUN npm install

FROM node:16-alpine

LABEL org.opencontainers.image.source="https://github.com/CCC-MF/bwhc-frontend"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.description="Portal UI Prototype (Frontend Application) of bwHealthCloud"

WORKDIR /bwhc-frontend
COPY --from=builder /bwhc-frontend/ .
COPY ./docker/entrypoint.sh .

# nuxt host and port to be replaced in package.json. (See 2.3 in bwHCPrototypeManual)
# NUXT_HOST should have a value with public available IP address from within container.
# If changing NUXT_PORT, also change exposed port.
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

# Backend access setup. (See 2.4 in bwHCPrototypeManual)
ENV BACKEND_PROTOCOL=http
ENV BACKEND_HOSTNAME=localhost
ENV BACKEND_PORT=8080

EXPOSE $NUXT_PORT

ENTRYPOINT /bwhc-frontend/entrypoint.sh
