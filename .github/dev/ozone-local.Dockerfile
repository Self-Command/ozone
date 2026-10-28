# Workspace-local variant of ./Dockerfile. The upstream image has no build-time
# NEXT_PUBLIC_* args, but the local stack must bake local PLC / resolver / UI
# addresses into the Next.js bundle. Keep the build itself identical otherwise.
FROM node:24.22.1-alpine3.23 AS build

WORKDIR /usr/src/ozone

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn
COPY . .

ARG NEXT_PUBLIC_PLC_DIRECTORY_URL=http://localhost:2582
ARG NEXT_PUBLIC_HANDLE_RESOLVER_URL=http://localhost:2584
ARG NEXT_PUBLIC_SOCIAL_APP_URL=http://localhost:8100
ARG NEXT_PUBLIC_OZONE_PUBLIC_URL=http://localhost:2586
ARG NEXT_PUBLIC_OZONE_SERVICE_DID=
ENV NEXT_PUBLIC_PLC_DIRECTORY_URL=$NEXT_PUBLIC_PLC_DIRECTORY_URL \
    NEXT_PUBLIC_HANDLE_RESOLVER_URL=$NEXT_PUBLIC_HANDLE_RESOLVER_URL \
    NEXT_PUBLIC_SOCIAL_APP_URL=$NEXT_PUBLIC_SOCIAL_APP_URL \
    NEXT_PUBLIC_OZONE_PUBLIC_URL=$NEXT_PUBLIC_OZONE_PUBLIC_URL \
    NEXT_PUBLIC_OZONE_SERVICE_DID=$NEXT_PUBLIC_OZONE_SERVICE_DID

RUN yarn build
RUN rm -rf node_modules .next/cache
RUN mv service/package.json package.json && mv service/yarn.lock yarn.lock
RUN yarn

# final stage

FROM node:24.22.1-alpine3.23

RUN apk add --update dumb-init
ENV TZ=Etc/UTC

WORKDIR /usr/src/ozone
COPY --from=build /usr/src/ozone /usr/src/ozone
RUN chown -R node:node .

ENTRYPOINT ["dumb-init", "--"]
EXPOSE 3000
ENV OZONE_PORT=3000
ENV NODE_ENV=production
USER node
CMD ["node", "./service"]

LABEL org.opencontainers.image.source=https://github.com/bluesky-social/ozone
LABEL org.opencontainers.image.description="Ozone Moderation Service Web UI (workspace local)"
LABEL org.opencontainers.image.licenses=MIT
