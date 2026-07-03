#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
from datetime import datetime
from pathlib import Path


def parse_env(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.exists():
        return values

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        values[key.strip()] = value.strip()
    return values


def sync_env(example_path: Path, env_path: Path) -> bool:
    if not example_path.exists():
        raise FileNotFoundError(f"missing example file: {example_path}")

    if not env_path.exists():
        shutil.copy2(example_path, env_path)
        print(f"created {env_path}")
        return True

    example_values = parse_env(example_path)
    env_values = parse_env(env_path)
    missing = [key for key in example_values if key not in env_values]

    if not missing:
        print(f"up to date {env_path}")
        return False

    backup_dir = env_path.parent / "env-backup"
    backup_dir.mkdir(exist_ok=True)
    backup_path = backup_dir / f"{env_path.name}.backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(env_path, backup_path)

    with env_path.open("a", encoding="utf-8", newline="\n") as file:
        file.write("\n# Added from env-sync.py\n")
        for key in missing:
            file.write(f"{key}={example_values[key]}\n")

    print(f"updated {env_path}; backup {backup_path}; added {', '.join(missing)}")
    return True


def find_example_files(root: Path) -> list[Path]:
    files = [root / ".env.example"]
    envs_dir = root / "envs"
    if envs_dir.exists():
        files.extend(sorted(envs_dir.rglob("*.env.example")))
    return files


def main() -> None:
    parser = argparse.ArgumentParser(description="Sync .env files from .env.example files.")
    parser.add_argument(
        "--root",
        default=Path(__file__).resolve().parent,
        type=Path,
        help="Docker config root directory.",
    )
    args = parser.parse_args()

    root = args.root.resolve()
    for example_path in find_example_files(root):
        env_path = example_path.with_name(example_path.name.removesuffix(".example"))
        sync_env(example_path, env_path)


if __name__ == "__main__":
    main()

