# S3 GoSimply Manager

A desktop app for managing files in AWS S3 or MinIO storage — no command line knowledge needed.

---

## Table of Contents

1. [First launch — create your account](#1-first-launch--create-your-account)
2. [Signing in](#2-signing-in)
3. [Connect to your storage](#3-connect-to-your-storage)
4. [Uploading files](#4-uploading-files)
5. [Downloading files](#5-downloading-files)
6. [Listing bucket contents](#6-listing-bucket-contents)
7. [Deleting files or buckets](#7-deleting-files-or-buckets)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. First launch — create your account

The very first time you open the app, you will see a **Register** screen.

This account is **local only** — it lives on your computer to protect your storage credentials. It has nothing to do with AWS or MinIO.

1. Type a **username** of your choice
2. Type a **password** (mix letters, numbers, and symbols for best security)
3. Type the same password again in **Confirm Password**
4. Click **Register & Sign In**

You are now signed in and ready to use the app.

---

## 2. Signing in

On every launch after the first, you will see the **Sign In** screen.

1. Enter the **username** and **password** you registered with
2. Click **Sign In**

> Tip: tick **Keep me signed in** to skip this screen on future launches.

---

## 3. Connect to your storage

Go to the **Settings** tab and fill in your storage details.

### For AWS S3

| Field | What to enter |
|---|---|
| Provider | Select **AWS** |
| Access Key | Your AWS Access Key ID |
| Secret Key | Your AWS Secret Access Key |
| Region | The region your bucket is in, e.g. `us-east-1` |

### For MinIO

| Field | What to enter |
|---|---|
| Provider | Select **MinIO / Custom** |
| Endpoint URL | Your MinIO server address, e.g. `http://192.168.1.10:9000` |
| Access Key | Your MinIO access key |
| Secret Key | Your MinIO secret key |
| Region | Can be anything, e.g. `us-east-1` |

Click **Save Settings** when done.

> Don't have these details? For AWS, find them in the AWS Console under **IAM → Users → Security credentials**. For MinIO, ask whoever set up your MinIO server.

> **Note:** The bucket name is not entered in Settings — you type it directly in each tab when you upload, download, list, or delete.

---

## 4. Uploading files

1. Click the **Upload** tab
2. Click **Browse** and select the file you want to upload
3. Check the **Bucket** name and the **destination path** (Key) are correct
4. Click **Upload**

A progress bar shows how much has transferred. You can upload again from where you left off if the connection drops.

---

## 5. Downloading files

1. Click the **Download** tab
2. Make sure the **Bucket** name is correct
3. Enter the **Key** — this is the file's path inside your bucket, for example `reports/january.pdf`
4. Click **Browse** to choose where to save it on your computer
5. Click **Download**

---

## 6. Listing bucket contents

1. Click the **List** tab
2. Make sure the **Bucket** name is correct
3. Optionally type a **Prefix** to filter results — for example type `images/` to show only files inside that folder
4. Click **List**

All matching files are shown with their names and sizes.

---

## 7. Deleting files or buckets

> **Warning:** deletion is permanent. There is no undo.

### Delete a single file

1. Click the **Delete Object** tab
2. Enter the **Bucket** name and the file path (**Key**)
3. Click **Delete Object** and confirm when prompted

### Delete an entire bucket

1. Click the **Delete Bucket** tab
2. Enter the **Bucket** name
3. Click **Delete Bucket**
4. Type the bucket name again to confirm — this is a safety check to prevent accidents

---

## 8. Troubleshooting

**"Access Denied" error**
Your Access Key or Secret Key is wrong, or your account does not have permission to perform that action. Double-check the keys in Settings. For AWS, make sure the IAM user has `s3:GetObject`, `s3:PutObject`, `s3:ListBucket`, and `s3:DeleteObject` permissions on your bucket.

**"Bucket not found" error**
Check the bucket name is spelled exactly right — bucket names are case-sensitive. For AWS S3, also confirm the region in Settings matches where the bucket was created.

**"Connection refused" to MinIO**
Your MinIO server may be offline, or the Endpoint URL is wrong. Check the address and port (default is `9000`) and make sure the server is running.

**Forgot your local password**
The local account is stored in a file called `auth.db` in the app folder. Delete that file and restart the app — you will be asked to register a new account. Your files in cloud storage are not affected.

**Settings not saving**
Make sure you click **Save Settings** before switching tabs. If the problem continues, close and reopen the app.

---

## Build macOS App

For a new Mac, install Python 3.11 or newer with Tkinter/Tcl-Tk support first. The simplest option is the official installer from [python.org](https://www.python.org/downloads/macos/).

Then run from source:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
python app.py
```

PyInstaller builds are platform-specific, so build this on macOS for macOS. Apple Silicon and Intel builds should be produced on the matching architecture unless you set up a universal build separately.

```bash
chmod +x ./build-macos.sh
bash ./build-macos.sh
open ./dist/S3_GoSimply_Manager.app
```

The final macOS app bundle is written to:

```bash
./dist/S3_GoSimply_Manager.app
```

Notes:

- The app uses Tkinter, so the Python installation must include working Tcl/Tk support.
- Unsigned local builds may be blocked by Gatekeeper on another Mac. For distribution, sign and notarize the `.app` with an Apple Developer ID certificate.

## Build macOS App From GitHub

On a new Mac where the code has not been copied locally, run the bootstrap script from GitHub:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rishi1700/s3-gosimply-manager/claude/fix-register-button-clipping-li1qZ/macos-build-from-github.sh)"
```

The script clones the repo into `~/s3-gosimply-manager`, installs Python dependencies, builds the app bundle, and launches:

```bash
~/s3-gosimply-manager/dist/S3_GoSimply_Manager.app
```

If `~/s3-gosimply-manager` already exists from an earlier ZIP download, the script moves it to a timestamped backup folder before downloading a fresh copy.

If the Mac does not already have Python with Tkinter, install Python from [python.org](https://www.python.org/downloads/macos/) first, or let the script use Homebrew:

```bash
INSTALL_HOMEBREW=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rishi1700/s3-gosimply-manager/claude/fix-register-button-clipping-li1qZ/macos-build-from-github.sh)"
```

Useful options:

```bash
BRANCH=claude/fix-register-button-clipping-li1qZ INSTALL_DIR="$HOME/Apps/s3-gosimply-manager" LAUNCH_APP=0 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rishi1700/s3-gosimply-manager/claude/fix-register-button-clipping-li1qZ/macos-build-from-github.sh)"
```

If the app opens to a blank window, rerun the bootstrap in debug launch mode from Terminal:

```bash
DEBUG_LAUNCH=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rishi1700/s3-gosimply-manager/claude/fix-register-button-clipping-li1qZ/macos-build-from-github.sh)"
```

Then check the startup log:

```bash
cat "$HOME/Library/Logs/S3_GoSimply_Manager.log"
```
