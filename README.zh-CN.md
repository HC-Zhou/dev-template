# Dev Fullstack Template

[![English README](https://img.shields.io/badge/README-English-blue)](README.md)

Python 3.12 + FastAPI + Next.js 全栈开发模板。

本模板参考 Dify 的工程化组织方式：

- 根目录通过 `Makefile` 统一编排常用命令
- `dev/` 下提供 Dify 风格的轻量开发脚本
- `api/` 作为独立后端项目
- `web/` 作为独立前端项目
- `docker/` 管理本地中间件和完整 Docker 栈
- 使用 `.env.example` 作为配置模板
- 支持 devcontainer，内置 Python 3.12、Node.js、pnpm、uv 和 Docker-in-Docker

## 项目结构

```text
.
├── api/                    # FastAPI 后端，使用 uv 管理
├── web/                    # Next.js 前端，使用 pnpm 管理
├── dev/                    # 日常开发脚本
├── docker/                 # Docker compose、环境变量模板、env 同步工具
├── .devcontainer/          # Dev Container 配置
├── Makefile                # 常用项目命令
└── README.md
```

## 快速开始

```bash
make dev-setup
make docker-up
make dev
```

服务地址：

- Web: http://localhost:3000
- API: http://localhost:5001
- API docs: http://localhost:5001/docs
- Postgres: localhost:5432
- Redis: localhost:6379

## 日常开发

根目录 `Makefile` 提供常用入口：

```bash
make dev-setup      # 创建本地 env 文件并安装依赖
make docker-up      # 启动本地中间件：Postgres 和 Redis
make docker-down    # 停止本地中间件
make dev            # 同时启动 API 和 Web 开发服务
make check          # 运行前后端 lint 和类型检查
make test           # 运行前后端测试
make format         # 格式化并自动修复代码
make build-api      # 构建后端 Docker 镜像
make build-web      # 构建前端 Docker 镜像
make compose-up     # 启动完整 Docker 栈
make compose-down   # 停止完整 Docker 栈
```

`dev/` 目录也提供等价的显式脚本：

```bash
dev/setup
dev/start-docker-compose
dev/stop-docker-compose
dev/start-api
dev/start-web
dev/check
dev/test
dev/reformat
```

## 后端

后端位于 `api/`。

技术栈：

- Python 3.12
- FastAPI
- uv
- Ruff
- mypy
- pytest

只启动后端：

```bash
dev/start-api
```

后端常用命令：

```bash
cd api
uv sync --dev
uv run uvicorn app.main:app --host 0.0.0.0 --port 5001 --reload
uv run ruff check .
uv run mypy app tests
uv run pytest
```

## 前端

前端位于 `web/`。

技术栈：

- Next.js
- React
- TypeScript
- pnpm
- ESLint
- Prettier
- Vitest

只启动前端：

```bash
dev/start-web
```

前端常用命令：

```bash
cd web
corepack enable
corepack pnpm install
corepack pnpm dev
corepack pnpm lint
corepack pnpm type-check
corepack pnpm test
corepack pnpm build
```

## Docker 结构

Docker 配置位于 `docker/`。

```text
docker/
├── compose.middleware.yaml     # 仅用于本地开发中间件
├── compose.template.yaml       # 完整 Docker 栈的源模板
├── compose.yaml                # 生成后的完整 Docker 栈
├── generate-compose            # 重新生成 compose.yaml
├── env-sync.py                 # 从 .env.example 同步 .env 文件
├── env-sync.sh                 # env-sync.py 的 shell 包装脚本
└── envs/
    ├── core-services/
    └── databases/
```

`compose.middleware.yaml` 用于本地开发，只启动 Postgres 和 Redis。

`compose.template.yaml` 是完整 Docker 栈的源文件。

`compose.yaml` 是生成物，不要直接修改。

重新生成：

```bash
docker/generate-compose
```

启动本地中间件：

```bash
make docker-up
```

启动完整 Docker 栈：

```bash
make compose-up
```

## 环境变量文件

每个 `.env.example` 都是模板。本地 `.env` 文件由 `dev/setup` 或 `docker/env-sync.sh` 生成。

示例：

```text
api/.env.example                       -> api/.env
web/.env.example                       -> web/.env.local
docker/.env.example                    -> docker/.env
docker/envs/core-services/api.env.example
                                      -> docker/envs/core-services/api.env
```

模板更新后同步 Docker env 文件：

```bash
docker/env-sync.sh
```

同步工具会：

- 创建缺失的 `.env` 文件
- 追加新增的环境变量
- 保留已有本地配置值
- 修改前备份到 `env-backup/`

## Devcontainer

项目内置 `.devcontainer/`。

devcontainer 提供：

- Python 3.12
- Node.js LTS
- 通过 Corepack 使用 pnpm
- uv
- Docker-in-Docker
- Web、API、Postgres、Redis 端口转发

转发端口：

- `3000`: Next.js
- `5001`: FastAPI
- `5432`: Postgres
- `6379`: Redis

### 在 VS Code 中使用

前置要求：

- Docker Desktop
- VS Code
- Dev Containers 扩展

步骤：

1. 用 VS Code 打开当前项目目录。
2. 执行 `Dev Containers: Reopen in Container`。
3. 等待容器构建完成。
4. `postCreateCommand` 会自动执行 `make dev-setup`。
5. 启动中间件和应用服务：

```bash
make docker-up
make dev
```

容器内还会添加这些 alias：

```bash
start-api
start-web
start-stack
```

### 在 JetBrains 中使用

前置要求：

- Docker Desktop
- 支持 Dev Containers 的 JetBrains IDE

步骤：

1. 在 IDE 中打开项目。
2. 选择 `.devcontainer/devcontainer.json` 配置。
3. 构建并进入容器。
4. 执行：

```bash
make docker-up
make dev
```

### Devcontainer 说明

`postCreateCommand` 会安装 uv、启用 Corepack，并执行：

```bash
make dev-setup
```

`postStartCommand` 会再次启用 Corepack，确保容器重启后 pnpm 可用。

由于启用了 Docker-in-Docker，容器内可以执行：

```bash
make docker-up
make compose-up
docker compose ps
```

## 推荐工作流

首次初始化：

```bash
make dev-setup
```

每天开发：

```bash
make docker-up
make dev
```

提交前检查：

```bash
make format
make check
make test
```

完整 Docker 验证：

```bash
make compose-up
make compose-down
```

