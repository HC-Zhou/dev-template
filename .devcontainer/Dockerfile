FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends make curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

