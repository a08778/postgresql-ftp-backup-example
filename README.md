# PostgreSQL FTP Backup Example

Example Bash scripts for:

- creating PostgreSQL backups every 12 hours
- uploading them to a remote FTP server
- deleting old local and remote backups
- verifying once per day that recent remote backups exist
- optionally sending daily email reports through cron

> This repository uses placeholder names and environment variables only. Do not commit real credentials.

## Features

- PostgreSQL backups in `.tar` format
- FTP upload using `curlftpfs`
- backup filenames include date and hour
- supports multiple databases through a loop
- deletes local and remote files older than 14 days
- daily verification of backups

## Requirements

```bash
sudo apt update
sudo apt install postgresql-client curlftpfs fuse bsd-mailx
```

## Configuration

Create environment file:

```bash
sudo nano /etc/pg-backup.env
```

Example:

```bash
export FTP_HOST="ftp.example.com"
export FTP_USER="your_ftp_username"
export FTP_PASS="your_ftp_password"
export REMOTE_BACKUP_SUBDIR="pg"

export DATABASES="app_db_1:db_user_1:db_pass_1 app_db_2:db_user_2:db_pass_2"
```

Secure it:

```bash
sudo chmod 600 /etc/pg-backup.env
```

Load variables:

```bash
source /etc/pg-backup.env
```

## Usage

```bash
./scripts/backup_to_ftp.sh
./scripts/check_remote_backup.sh
```

## Cron setup

```cron
MAILTO="you@example.com"

0 */12 * * * . /etc/pg-backup.env && /path/to/scripts/backup_to_ftp.sh
0 8 * * * . /etc/pg-backup.env && /path/to/scripts/check_remote_backup.sh
```

## Retention

- Deletes backups older than 14 days (local and remote)

## Security

- Do NOT store credentials in scripts
- Use environment variables or secret storage

## License

MIT License