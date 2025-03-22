# 🎮 Savefile Manager Scripts

This repository contains a collection of Bash scripts designed to automate the management of local savefiles by interacting with a remote API. It supports full CRUD operations on both savefiles and consoles.

These scripts were built from scratch during an internship in Maribor, Slovenia, with no prior Laravel experience, and were fully developed, tested, and deployed in under a month.

## 🚀 Features

- **Savefile Management**: Upload, download, update, and delete local or remote savefiles.
- **Console Management**: Register and manage console configurations.
- **Crawling Modes**: Flexible crawling logic with auto-update, force-update, and ignore-existing options.
- **Authentication**: Full login/logout/session management.
- **Logging**: Detailed logs for monitoring and debugging (auto-cleaned after 1 day).

## 📦 Requirements

- Bash 4.0 or higher
- `curl` for API requests
- `jq` for JSON parsing

### Installing Dependencies

**Debian/Ubuntu:**

```bash
sudo apt install curl jq
```

**macOS (Homebrew):**

```bash
brew install curl jq
```

## ⚙️ Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/GiakyWasTaken/Savefile-Manager-Scripts.git
   cd Savefile-Manager-Scripts
   ```

2. Make scripts executable:

   ```bash
   chmod +x *.sh
   chmod +x Auth_Scripts/*.sh
   chmod +x Console_Scripts/*.sh
   chmod +x Save_Scripts/*.sh
   ```

3. Configure the environment variables:
   - Copy `.env.example` to `.env`:

     ```bash
     cp .env.example .env
     ```

   - Edit `.env` with your values:
     - `API_URL`: Base URL of the backend API
     - `EMAIL`: Your login email
     - `PASSWORD`: Your password
     - `CONSOLE_NAMES`: Array of console names to manage
     - `SAVES_PATHS`: Corresponding savefile paths

## ▶️ Usage

### Savefile Crawler (Upload)

Crawls local directories and uploads savefiles to the remote API.

```bash
./savefile_crawler.sh [options]
```

| Option | Description |
| ------ | ----------- |
| `-a`, `--auto-update` | Auto-update existing files only if the local file is newer |
| `-f`, `--force-update` | Force update existing files even if remote is newer |
| `-i`, `--ignore-existing` | Skip updating already existing files |
| `-v`, `--verbose` | Enable verbose output |
| `-vv` | Enable very verbose output |

### Savefile Downloader

Downloads savefiles from the remote API to local directories.

```bash
./savefile_downloader.sh [options]
```

| Option           | Description                                          |
|------------------|------------------------------------------------------|
| `-f`, `--force`  | Force overwrite local files regardless of timestamps |
| `-v`, `--verbose`| Enable verbose output                                |

### Utility Scripts

- `./log_cleaner.sh` - Cleans log files older than 1 day
- `./http_codes.sh <code>` - Displays the meaning of an HTTP status code

## 📁 Project Structure

```text
├── Auth_Scripts/        # Login/logout API scripts
├── Console_Scripts/     # Console CRUD operations
├── Save_Scripts/        # Savefile CRUD operations
├── log/                 # Log files (auto-cleaned)
├── savefile_crawler.sh  # Main upload script
├── savefile_downloader.sh # Main download script
├── log_cleaner.sh       # Log cleanup utility
├── http_codes.sh        # HTTP code reference
└── .env                 # Environment configuration
```

## 🔐 Environment Variables

These are configured in the `.env` file:

| Variable        | Description                         |
|-----------------|-------------------------------------|
| `API_URL`       | Base URL of the API server          |
| `API_TOKEN`     | Authentication token (set by login) |
| `EMAIL`         | Email used for login                |
| `PASSWORD`      | Password used for login             |
| `CONSOLE_NAMES` | Array of consoles to manage         |
| `SAVES_PATHS`   | Local paths to your savefiles       |

## 📝 Logs

Logs are stored in the `log/` directory and automatically cleaned up after 1 day.

## 🌐 Backend

Looking for the backend to interact with these scripts? Check out the companion repo:

👉 [GiakyWasTaken/Savefile-Manager](https://github.com/GiakyWasTaken/Savefile-Manager)

---
