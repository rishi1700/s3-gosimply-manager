#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Build a macOS app bundle with PyInstaller.
# ------------------------------------------------------------

APP_NAME="S3_GoSimply_Manager"
ENTRY_SCRIPT="app.py"
VENV_PATH=".venv"
DIST_APP="./dist/${APP_NAME}.app"
SPEC_PATH="./build/macos-spec"
HIDDEN_IMPORTS=(minio urllib3 tqdm PIL)

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
      command -v "${candidate}" >/dev/null 2>&1 || continue
      resolved="$(command -v "${candidate}")"
    fi
    if python_is_usable "${resolved}"; then
      PYTHON_BIN="${resolved}"
      return 0
    fi
  done
  return 1
}

if [[ -n "${PYTHON_BIN:-}" ]]; then
  if ! python_is_usable "${PYTHON_BIN}"; then
    echo "PYTHON_BIN is set but is not usable for this macOS build: ${PYTHON_BIN}" >&2
    exit 1
  fi
elif ! choose_python_from_candidates \
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
  echo "Modern Python 3 with Tk 8.6+ and OpenSSL is required." >&2
  echo "Install Python from https://www.python.org/downloads/macos/ or run:" >&2
  echo "  brew install python@3.12 python-tk@3.12" >&2
  exit 1
fi

echo "Using Python: ${PYTHON_BIN}"

if [[ -x "${VENV_PATH}/bin/python" ]] && ! python_is_usable "${VENV_PATH}/bin/python"; then
  echo "Existing ${VENV_PATH} was created with an unsupported Python; recreating it."
  rm -rf "${VENV_PATH}"
fi

if [[ ! -d "${VENV_PATH}" ]]; then
  "${PYTHON_BIN}" -m venv "${VENV_PATH}"
fi

# shellcheck disable=SC1091
source "${VENV_PATH}/bin/activate"

python - <<'PY'
import ssl
import sys
import tkinter
print(f"Python executable: {sys.executable}")
print(f"Tkinter available: Tk {tkinter.TkVersion}")
print(f"SSL: {ssl.OPENSSL_VERSION}")
if tuple(int(part) for part in str(tkinter.TkVersion).split(".")[:2]) < (8, 6):
    raise SystemExit("Tk 8.6 or newer is required. Install Python from python.org or use Homebrew python-tk.")
if "LibreSSL" in ssl.OPENSSL_VERSION:
    raise SystemExit("Apple system Python/LibreSSL is not supported. Install Python from python.org or use Homebrew python-tk.")
PY

python -m pip install --upgrade pip
if [[ -f requirements.txt ]]; then
  pip install -r requirements.txt
else
  pip install pyinstaller minio urllib3 tqdm pillow
fi

hidden_args=()
for hidden in "${HIDDEN_IMPORTS[@]}"; do
  hidden_args+=(--hidden-import "${hidden}")
done

mkdir -p "${SPEC_PATH}"

pyinstaller --noconfirm --clean --windowed \
  --name "${APP_NAME}" \
  --specpath "${SPEC_PATH}" \
  "${hidden_args[@]}" \
  "${ENTRY_SCRIPT}"

echo
echo "Build output tree:"
find ./dist -maxdepth 3 -type f | sort

if [[ ! -d "${DIST_APP}" ]]; then
  echo "Expected macOS app bundle '${DIST_APP}' was not created." >&2
  exit 1
fi

echo
echo "Done. Final macOS app bundle: ${DIST_APP}"
echo "Launch with: open '${DIST_APP}'"
