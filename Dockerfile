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

RUN apk add --no-cache git

COPY --from=build --chown=node:node /prod/api /app

# Cobalt necesita un git repo para obtener info de versión
RUN git init && \
    git config user.email "deploy@cobalt" && \
    git config user.name "deploy" && \
    git add -A && \
    git commit --allow-empty -m "deploy"

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
