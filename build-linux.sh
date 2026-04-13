#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Build a Linux binary with PyInstaller.
# ------------------------------------------------------------

APP_NAME="S3_GoSimply_Manager"
ENTRY_SCRIPT="app.py"
VENV_PATH=".venv"
DIST_BIN="./dist/${APP_NAME}"
HIDDEN_IMPORTS=(minio urllib3 tqdm PIL)

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. Install Python 3 and try again." >&2
  exit 1
fi

if [[ ! -d "${VENV_PATH}" ]]; then
  python3 -m venv "${VENV_PATH}"
fi

# shellcheck disable=SC1091
source "${VENV_PATH}/bin/activate"

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

pyinstaller --noconfirm --clean --onefile --windowed \
  --name "${APP_NAME}" \
  "${hidden_args[@]}" \
  "${ENTRY_SCRIPT}"

echo
echo "Build output tree:"
find ./dist -maxdepth 2 -type f | sort

if [[ ! -f "${DIST_BIN}" ]]; then
  echo "Expected Linux binary '${DIST_BIN}' was not created." >&2
  exit 1
fi

chmod +x "${DIST_BIN}"

echo
echo "Done. Final Linux app file: ${DIST_BIN}"
