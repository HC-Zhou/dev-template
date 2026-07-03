# Docker

This directory contains Docker orchestration for the fullstack template.

## Compose Files

- `compose.middleware.yaml` starts only local development dependencies.
- `compose.template.yaml` is the source for the full Docker stack.
- `compose.yaml` is generated from `compose.template.yaml`; do not edit it directly.

Regenerate the full stack compose file with:

```bash
docker/generate-compose
```

## Environment Layout

- `.env.example` contains startup-level values such as exposed ports.
- `.env` contains local overrides and is created from `.env.example`.
- `envs/**/*.env.example` contains service-specific defaults.
- `envs/**/*.env` contains local service-specific values and is generated during setup.

Run this after pulling template updates:

```bash
docker/env-sync.sh
```

The sync tool creates missing env files, appends newly introduced variables, and backs up changed files under `env-backup/`.

## Middleware

```bash
dev/start-docker-compose
dev/stop-docker-compose
```

## Full Stack

```bash
make compose-up
make compose-down
```
