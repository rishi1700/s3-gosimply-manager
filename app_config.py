from __future__ import annotations

import secrets
from datetime import datetime, timedelta
from typing import Any, Dict, Optional

from s3 import CONFIG_PATH, load_settings, save_settings

SESSION_KEY = "SESSION"
UI_DARK_KEY = "UI_DARK"
SESSION_DURATION_DAYS = 7


def load_app_settings() -> Dict[str, Any]:
    return load_settings()


def save_app_settings(data: Dict[str, Any]) -> None:
    save_settings(data)


def load_valid_session_username(settings: Optional[Dict[str, Any]] = None) -> Optional[str]:
    cfg = settings if settings is not None else load_app_settings()
    session = cfg.get(SESSION_KEY) or {}
    username = session.get("username")
    expires_at = session.get("expires_at")
    if not username or not expires_at:
        return None
    try:
        expires = datetime.fromisoformat(expires_at)
    except Exception:
        return None
    if expires <= datetime.now():
        return None
    return str(username)


def save_session(username: str, keep_signed_in: bool, settings: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    cfg = dict(settings if settings is not None else load_app_settings())
    if keep_signed_in:
        session = cfg.get(SESSION_KEY) or {}
        cfg[SESSION_KEY] = {
            "username": username,
            "token": session.get("token") or secrets.token_hex(16),
            "expires_at": (datetime.now() + timedelta(days=SESSION_DURATION_DAYS)).isoformat(),
        }
    else:
        cfg.pop(SESSION_KEY, None)
    save_app_settings(cfg)
    return cfg


def clear_session(settings: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    cfg = dict(settings if settings is not None else load_app_settings())
    cfg.pop(SESSION_KEY, None)
    save_app_settings(cfg)
    return cfg


def set_ui_dark_preference(enabled: bool, settings: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    cfg = dict(settings if settings is not None else load_app_settings())
    cfg[UI_DARK_KEY] = "1" if enabled else "0"
    save_app_settings(cfg)
    return cfg
