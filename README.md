# S3 GoSimply Manager

A desktop app for managing files in AWS S3 or MinIO storage — no command line knowledge needed.
Upload, download, list, and delete files through a simple graphical window.

---

## What does this app do?

- **Upload** files and folders to your S3 or MinIO storage
- **Download** files from your storage to your computer
- **List** the contents of any bucket (folder in cloud storage)
- **Delete** individual files or entire buckets
- Works with **AWS S3** and any **MinIO-compatible** storage server

---

## Table of Contents

1. [What you need before starting](#1-what-you-need-before-starting)
2. [Get the code](#2-get-the-code)
3. [Windows — run from source](#3-windows--run-from-source)
4. [Windows — build a standalone exe](#4-windows--build-a-standalone-exe)
5. [Ubuntu / Linux — run from source](#5-ubuntu--linux--run-from-source)
6. [Ubuntu / Linux — build a standalone binary](#6-ubuntu--linux--build-a-standalone-binary)
7. [First launch — create your account](#7-first-launch--create-your-account)
8. [Connect to your storage](#8-connect-to-your-storage)
9. [Uploading files](#9-uploading-files)
10. [Downloading files](#10-downloading-files)
11. [Listing bucket contents](#11-listing-bucket-contents)
12. [Deleting files or buckets](#12-deleting-files-or-buckets)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. What you need before starting

### For AWS S3
- An AWS account
- Your **Access Key ID** and **Secret Access Key** (from AWS IAM)
- The **region** your bucket lives in (e.g. `us-east-1`)

### For MinIO
- The **URL** of your MinIO server (e.g. `http://192.168.1.10:9000`)
- Your MinIO **Access Key** and **Secret Key**

### For running the app
- A computer running **Windows 10/11** or **Ubuntu 20.04 or newer**
- An internet connection (to download the code and dependencies the first time)

---

## 2. Get the code

You need **Git** installed to download the code.

**Check if Git is installed:**

- Windows: open **Command Prompt** and type `git --version`
- Ubuntu: open **Terminal** and type `git --version`

If you see a version number, Git is already installed. If not:

- **Windows**: download and install from https://git-scm.com/download/win — use all default options
- **Ubuntu**: run `sudo apt install -y git` in Terminal

**Download the code:**

```
git clone https://github.com/rishi1700/s3-gosimply-manager.git
cd s3-gosimply-manager
```

This creates a folder called `s3-gosimply-manager` with all the app files inside.

---

## 3. Windows — run from source

This lets you run the app directly without building an exe file. Good for trying it out.

### Step 1 — Install Python

1. Go to https://www.python.org/downloads/
2. Click the big **Download Python** button
3. Run the installer
4. **Important:** on the first screen, tick the box that says **"Add Python to PATH"**
5. Click **Install Now**

To check it worked, open **Command Prompt** and type:
```
python --version
```
You should see something like `Python 3.12.x`.

### Step 2 — Open the project folder in Command Prompt

1. Open **Command Prompt** (press `Win + R`, type `cmd`, press Enter)
2. Navigate to the project folder:
```
cd s3-gosimply-manager
```
> If you downloaded the folder to your Desktop, type:
> `cd %USERPROFILE%\Desktop\s3-gosimply-manager`

### Step 3 — Set up and run

Copy and paste these commands one at a time, pressing Enter after each:

```
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

The app window will open. You only need to do the first three commands once. Next time, just do:

```
.\.venv\Scripts\activate
python app.py
```

---

## 4. Windows — build a standalone exe

This creates a single `.exe` file you can double-click to launch — no Python needed.

### Step 1 — Allow PowerShell scripts to run

Open **PowerShell as Administrator** (right-click the Start menu → Windows PowerShell (Admin)) and run:

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Type `Y` and press Enter when asked.

### Step 2 — Run the build script

Open a normal **PowerShell** window inside the project folder and run:

```
.\windows-build.ps1
```

This will take a few minutes. When it finishes, your exe is at:

```
dist\S3_GoSimply_Manager.exe
```

Double-click it to launch the app — no installation required.

---

## 5. Ubuntu / Linux — run from source

### Step 1 — Install required system packages

Open a **Terminal** and run:

```
sudo apt update
sudo apt install -y python3 python3-venv python3-tk git
```

Type your password when asked and press Enter.

### Step 2 — Navigate to the project folder

```
cd s3-gosimply-manager
```

### Step 3 — Set up and run

```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 app.py
```

The app window will open. You only need to do the first three commands once. Next time, just run:

```
source .venv/bin/activate
python3 app.py
```

---

## 6. Ubuntu / Linux — build a standalone binary

This creates a single file you can run on any Linux machine without installing Python.

### Step 1 — Install build tools

```
sudo apt update
sudo apt install -y python3 python3-venv python3-tk build-essential git
```

### Step 2 — Run the build script

```
bash ./build-linux.sh
```

This takes a few minutes. When done, your binary is at:

```
./dist/S3_GoSimply_Manager
```

To run it:

```
./dist/S3_GoSimply_Manager
```

Or double-click it in your file manager.

---

## 7. First launch — create your account

When you open the app for the very first time, you will see a **Register** screen.

This account is **local only** — it lives on your computer and is used to protect your storage credentials. It is not connected to AWS or MinIO.

1. Type a **username** of your choice
2. Type a **password** (at least 8 characters — mix letters, numbers, and symbols for best security)
3. Type the same password again in **Confirm Password**
4. Click **Register & Sign In**

Next time you open the app, you will see a **Sign In** screen instead. Enter the same username and password you registered with.

> Tip: tick **Keep me signed in** to skip the password screen next time.

---

## 8. Connect to your storage

After signing in, go to the **Settings** tab.

Fill in the fields for your storage provider:

### For AWS S3

| Field | What to enter |
|---|---|
| Endpoint URL | Leave blank (or enter `https://s3.amazonaws.com`) |
| Access Key | Your AWS Access Key ID |
| Secret Key | Your AWS Secret Access Key |
| Region | Your bucket's region, e.g. `us-east-1` |
| Bucket | The name of your S3 bucket |

### For MinIO

| Field | What to enter |
|---|---|
| Endpoint URL | Your MinIO server address, e.g. `http://192.168.1.10:9000` |
| Access Key | Your MinIO access key |
| Secret Key | Your MinIO secret key |
| Region | Usually `us-east-1` (MinIO accepts any value here) |
| Bucket | The name of your bucket |

Click **Save Settings** when done.

---

## 9. Uploading files

1. Click the **Upload** tab
2. Click **Browse** and select the file or folder you want to upload
3. Check that the **Bucket** and **Key (destination path)** are correct
4. Click **Upload**

A progress bar shows how much has been transferred. Large files can be resumed if interrupted.

---

## 10. Downloading files

1. Click the **Download** tab
2. Enter the **Bucket** name
3. Enter the **Key** — this is the file path inside your bucket (e.g. `reports/january.pdf`)
4. Choose where to save it on your computer using **Browse**
5. Click **Download**

---

## 11. Listing bucket contents

1. Click the **List** tab
2. Enter your **Bucket** name
3. Optionally enter a **Prefix** to filter results (e.g. `images/` to see only files in that folder)
4. Click **List**

All matching files are shown with their sizes. You can click any item to copy its path.

---

## 12. Deleting files or buckets

> **Warning:** deletion is permanent. Files cannot be recovered after deletion.

### Delete a single file

1. Click the **Delete Object** tab
2. Enter the **Bucket** name and the **Key** (file path)
3. Click **Delete Object**
4. Confirm when prompted

### Delete an entire bucket

1. Click the **Delete Bucket** tab
2. Enter the **Bucket** name
3. Click **Delete Bucket**
4. Type the bucket name again to confirm — this is a safety check

---

## 13. Troubleshooting

**The app won't open on Ubuntu**
Make sure you have a desktop environment running (not a headless/SSH-only server). The app requires a graphical display. Run `sudo apt install -y python3-tk` and try again.

**"Python not found" on Windows**
Reinstall Python from https://www.python.org/downloads/ and make sure you tick **"Add Python to PATH"** during installation.

**"Access Denied" when connecting to storage**
Double-check your Access Key and Secret Key in Settings. For AWS, make sure the IAM user has `s3:GetObject`, `s3:PutObject`, `s3:ListBucket`, and `s3:DeleteObject` permissions.

**"Bucket not found" error**
Check the bucket name is spelled exactly right (bucket names are case-sensitive). For AWS S3, also confirm the region matches where the bucket was created.

**Connection refused to MinIO**
Make sure your MinIO server is running and the endpoint URL is correct, including the port (default is `9000`). If you are connecting over a network, check that port 9000 is open in your firewall.

**The exe or binary does not start**
On Ubuntu, you may need to make the file executable first:
```
chmod +x ./dist/S3_GoSimply_Manager
./dist/S3_GoSimply_Manager
```
On Windows, if a security warning appears, click **More info → Run anyway**.

**Forgot your local password**
The local account database is stored in a file called `auth.db` in the app folder. Delete that file to reset all accounts — you will be asked to register again. Your cloud storage data is not affected.

---

## Project files (for reference)

| File | Purpose |
|---|---|
| `app.py` | Main application window |
| `s3.py` | Storage connection logic |
| `app_config.py` | Settings and session management |
| `auth_store.py` | Local account database |
| `requirements.txt` | Python packages needed |
| `windows-build.ps1` | Windows build script |
| `build-linux.sh` | Linux build script |
