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

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. Install Python 3 from python.org or Homebrew and try again." >&2
  exit 1
fi

if [[ ! -d "${VENV_PATH}" ]]; then
  python3 -m venv "${VENV_PATH}"
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
