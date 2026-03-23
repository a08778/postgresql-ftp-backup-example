# PostgreSQL FTP Backup Example

Simple Bash scripts for:

- PostgreSQL backups every 12 hours
- Uploading backups to FTP storage
- Retention cleanup (14 days)
- Daily verification of remote backups
- Optional email notifications

> This repository uses placeholder values only. Do not commit real credentials.

---

## Features

- Uses `pg_dump` for backups
- FTP mounting via `curlftpfs`
- Supports multiple databases (loop-based)
- Cron-friendly automation
- Skips overwriting existing backups
- Email alerts on failure

---

## Requirements

Install required packages:

```bash
sudo apt update
sudo apt install -y git postgresql-client curlftpfs fuse msmtp msmtp-mta mailutils
```

---

## Repository structure

```text
.
├── README.md
├── docs/
│   └── SETUP.md
├── scripts/
│   ├── backup_to_ftp.sh
│   └── check_remote_backup.sh
├── examples/
│   ├── env.example
│   └── cron.example
```

---

## Usage overview

1. Configure environment variables
2. Run backup script manually
3. Schedule backups via cron
4. Verify backups daily
5. Receive email alerts on failure

---

## Configuration

The scripts use environment variables (not hardcoded credentials).

Example:

```bash
export FTP_HOST="ftp.example.com"
export FTP_USER="your_ftp_user"
export FTP_PASS="your_ftp_pass"
export REMOTE_BACKUP_SUBDIR="pg"

export DATABASES="db1:user1:pass1 db2:user2:pass2"
```

---

## Backup naming

Backups are created as:

```text
database-YYYY-MM-DD-HH.tar
```

Example:

```text
app_db-2026-03-23-12.tar
```

---

## Setup instructions

👉 Full setup guide:

```
docs/SETUP.md
```

This includes:

- Git installation
- Permissions setup
- Environment configuration
- Email (SMTP) setup
- Cron scheduling
- Troubleshooting

---

## Security

- Never store credentials in scripts
- Use environment variables or external config
- Keep `/etc/pg-backup.env` outside repository
- Restrict permissions (chmod 600)

---

## License

MIT License