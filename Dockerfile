FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
RUN corepack enable

FROM base AS build
WORKDIR /app
COPY . /app

RUN apk add --no-cache python3 alpine-sdk
RUN pnpm install --prod --frozen-lockfile
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

COPY --from=build --chown=node:node /prod/api /app

# Eliminar lockfile para que pnpm no intente checks en runtime
RUN rm -f /app/pnpm-lock.yaml /app/package.json

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
