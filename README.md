# PostgreSQL FTP Backup Example

Simple Bash scripts for:

- PostgreSQL backups every 12 hours
- Uploading backups to FTP storage
- Retention cleanup (14 days)
- Daily verification of remote backups

## Features

- Uses `pg_dump` for backups
- FTP mounting via `curlftpfs`
- Supports multiple databases (loop-based)
- Cron-friendly
- Skips overwriting existing backups

## Requirements

- Linux (Ubuntu recommended)
- PostgreSQL client tools
- FTP access

Install basic tools:

```bash
sudo apt update
sudo apt install -y git postgresql-client curlftpfs fuse
```

## Repository structure

```text
.
├── README.md
├── docs/
│   └── SETUP.md
├── scripts/
│   ├── backup_to_ftp.sh
│   └── check_remote_backup.sh
```

## Usage overview

1. Configure environment variables
2. Run backup script
3. Schedule with cron
4. Verify backups daily

## Setup instructions

👉 Full setup guide:

See: `docs/SETUP.md`

## Security note

- Do NOT store credentials in scripts
- Use environment variables or external config

## License

MIT