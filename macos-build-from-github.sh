#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Clone this project from GitHub, build the macOS app bundle,
# and launch it on a fresh Mac.
#
# Usage:
#   bash macos-build-from-github.sh
#
# Optional overrides:
#   REPO_URL=https://github.com/rishi1700/s3-gosimply-manager.git
#   BRANCH=claude/fix-register-button-clipping-li1qZ
#   INSTALL_DIR="$HOME/s3-gosimply-manager"
#   LAUNCH_APP=1
#   DEBUG_LAUNCH=0
#   INSTALL_HOMEBREW=0
# ------------------------------------------------------------

REPO_URL="${REPO_URL:-https://github.com/rishi1700/s3-gosimply-manager.git}"
REPO_ZIP_URL="${REPO_ZIP_URL:-https://github.com/rishi1700/s3-gosimply-manager/archive/refs/heads/${BRANCH:-claude/fix-register-button-clipping-li1qZ}.zip}"
BRANCH="${BRANCH:-claude/fix-register-button-clipping-li1qZ}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/s3-gosimply-manager}"
LAUNCH_APP="${LAUNCH_APP:-1}"
DEBUG_LAUNCH="${DEBUG_LAUNCH:-0}"
INSTALL_HOMEBREW="${INSTALL_HOMEBREW:-0}"
APP_NAME="S3_GoSimply_Manager"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1
}

python_is_usable() {
  "$1" - <<'PY' >/dev/null 2>&1
import ssl
import sys
import tkinter

tk_version = tuple(int(part) for part in str(tkinter.TkVersion).split(".")[:2])
if tk_version < (8, 6):
    raise SystemExit(1)
if "LibreSSL" in ssl.OPENSSL_VERSION:
    raise SystemExit(1)
if sys.executable == "/usr/bin/python3":
    raise SystemExit(1)
PY
}

choose_python_from_candidates() {
  local candidate resolved
  for candidate in "$@"; do
    if [[ "${candidate}" == */* ]]; then
      [[ -x "${candidate}" ]] || continue
      resolved="${candidate}"
    else
      need_command "${candidate}" || continue
      resolved="$(command -v "${candidate}")"
    fi
    if python_is_usable "${resolved}"; then
      PYTHON_BIN="${resolved}"
      return 0
    fi
  done
  return 1
}

ensure_homebrew_if_requested() {
  if need_command brew; then
    return
  fi

  if [[ "${INSTALL_HOMEBREW}" != "1" ]]; then
    return
  fi

  echo "Installing Homebrew because INSTALL_HOMEBREW=1 was set."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

select_python() {
  if [[ -n "${PYTHON_BIN:-}" ]] && python_is_usable "${PYTHON_BIN}"; then
    return
  fi

  if choose_python_from_candidates \
    /Library/Frameworks/Python.framework/Versions/3.13/bin/python3 \
    /Library/Frameworks/Python.framework/Versions/3.12/bin/python3 \
    /Library/Frameworks/Python.framework/Versions/3.11/bin/python3 \
    /opt/homebrew/bin/python3.13 \
    /opt/homebrew/bin/python3.12 \
    /opt/homebrew/bin/python3.11 \
    /usr/local/bin/python3.13 \
    /usr/local/bin/python3.12 \
    /usr/local/bin/python3.11 \
    python3.13 \
    python3.12 \
    python3.11 \
    python3; then
    echo "Using Python: ${PYTHON_BIN}"
    return
  fi

  ensure_homebrew_if_requested

  if need_command brew; then
    echo "Installing Python and Tkinter with Homebrew."
    brew install python@3.12 python-tk@3.12
    local brew_prefix
    brew_prefix="$(brew --prefix)"
    if choose_python_from_candidates "${brew_prefix}/opt/python@3.12/bin/python3.12"; then
      echo "Using Python: ${PYTHON_BIN}"
      return
    fi
  fi

  die "Modern Python 3 with Tkinter and OpenSSL is required. Install Python from https://www.python.org/downloads/macos/ or rerun with INSTALL_HOMEBREW=1."
}

clone_or_update_repo() {
  if [[ -d "${INSTALL_DIR}/.git" ]]; then
    echo "Updating existing checkout: ${INSTALL_DIR}"
    need_command git || die "git is required to update the existing checkout at ${INSTALL_DIR}."
    git -C "${INSTALL_DIR}" fetch origin "${BRANCH}"
    git -C "${INSTALL_DIR}" checkout "${BRANCH}"
    git -C "${INSTALL_DIR}" pull --ff-only origin "${BRANCH}"
    return
  fi

  if [[ -e "${INSTALL_DIR}" ]]; then
    local backup_dir
    backup_dir="${INSTALL_DIR}.backup-$(date +%Y%m%d-%H%M%S)"
    echo "Existing non-Git install found at ${INSTALL_DIR}; moving it to ${backup_dir}"
    mv "${INSTALL_DIR}" "${backup_dir}"
  fi

  if need_command git; then
    echo "Cloning ${REPO_URL} branch ${BRANCH} into ${INSTALL_DIR}"
    git clone --branch "${BRANCH}" "${REPO_URL}" "${INSTALL_DIR}"
    return
  fi

  echo "git not found; downloading repository ZIP instead."
  need_command curl || die "curl is required to download the repository ZIP."
  need_command unzip || die "unzip is required to extract the repository ZIP."

  local tmp_dir zip_path extracted_dir
  tmp_dir="$(mktemp -d)"
  zip_path="${tmp_dir}/repo.zip"

  curl -fsSL "${REPO_ZIP_URL}" -o "${zip_path}"
  unzip -q "${zip_path}" -d "${tmp_dir}"
  extracted_dir="$(find "${tmp_dir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  [[ -n "${extracted_dir}" ]] || die "Could not find extracted repository directory."
  mv "${extracted_dir}" "${INSTALL_DIR}"
}

build_app() {
  cd "${INSTALL_DIR}"

  rm -rf .venv build dist
  "${PYTHON_BIN}" -m venv .venv
  # shellcheck disable=SC1091
  source .venv/bin/activate

  python -m pip install --upgrade pip
  pip install -r requirements.txt

  if [[ -x ./build-macos.sh ]]; then
    ./build-macos.sh
  else
    bash ./build-macos.sh
  fi

  [[ -d "./dist/${APP_NAME}.app" ]] || die "Build finished but ./dist/${APP_NAME}.app was not created."
}

launch_app() {
  if [[ "${LAUNCH_APP}" == "1" ]]; then
    if [[ "${DEBUG_LAUNCH}" == "1" ]]; then
      echo "Launching in debug mode. Close the app window to return to the shell."
      S3_MANAGER_DEBUG=1 "${INSTALL_DIR}/dist/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
    else
      open "${INSTALL_DIR}/dist/${APP_NAME}.app"
    fi
  fi
}

ensure_homebrew_if_requested
select_python
clone_or_update_repo
build_app
launch_app

echo
echo "Done."
echo "Project: ${INSTALL_DIR}"
echo "App: ${INSTALL_DIR}/dist/${APP_NAME}.app"
echo "Log: $HOME/Library/Logs/S3_GoSimply_Manager.log"
