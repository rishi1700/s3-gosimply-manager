# S3 GoSimply Manager

Desktop GUI for uploading, downloading, listing, and deleting objects in AWS S3 or MinIO-compatible storage.

## Features

- Local username/password sign-in backed by SQLite
- Saved connection settings for AWS S3 or MinIO
- Upload and download progress with transfer metrics
- Bucket listing and object deletion flows
- Windows packaging with PyInstaller

## Project Layout

- `app.py`: main Tkinter desktop application
- `app_config.py`: app settings and local session helpers
- `s3.py`: MinIO SDK client and CLI helper logic
- `auth_store.py`: local auth database and password hashing
- `windows-build.ps1`: local Windows build script
- `build-linux.sh`: local Linux build script

## Run Locally

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
```

## Run On Ubuntu

Install the OS packages Tkinter depends on first:

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-tk
```

Then run the app:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 app.py
```

## Build Windows App

```powershell
.\windows-build.ps1
```

The GitHub Actions workflow in `.github/workflows/windows-build.yml` builds and signs the Windows executable.

## Build Linux App

On Ubuntu, install the build prerequisites first:

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-tk build-essential
```

Then build the Linux binary:

```bash
bash ./build-linux.sh
```

The final Linux binary is written to:

```bash
./dist/S3_GoSimply_Manager
```

Notes:

- The app uses Tkinter, so the Ubuntu desktop environment needs GUI support.
- The Linux binary is built on Linux; PyInstaller output is platform-specific.
- If you want a more distribution-friendly package later, the next step is wrapping the Linux build as an AppImage or `.deb`.
