#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import socket
import sys
from pathlib import Path


def ui_port() -> int:
    default = int(os.environ.get("UI_PORT", "8787"))
    data_dir = Path(os.environ.get("VPNGATE_DATA_DIR", "/data"))
    try:
        config = json.loads((data_dir / "ui_auth.json").read_text(encoding="utf-8"))
        return int(config.get("port", default))
    except (OSError, ValueError, TypeError, json.JSONDecodeError):
        return default


try:
    with socket.create_connection(("127.0.0.1", ui_port()), timeout=3):
        pass
except OSError as exc:
    print(f"AimiliVPN UI health check failed: {exc}", file=sys.stderr)
    raise SystemExit(1)
