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

## Run Locally

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
```

## Build Windows App

```powershell
.\windows-build.ps1
```

The GitHub Actions workflow in `.github/workflows/windows-build.yml` builds and signs the Windows executable.
