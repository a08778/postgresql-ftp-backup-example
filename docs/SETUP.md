# Setup Guide

This guide explains how to configure PostgreSQL FTP backup scripts on Ubuntu.

## 1. Install required packages

```bash
sudo apt update
sudo apt install postgresql-client curlftpfs fuse bsd-mailx
```

## 2. Create FTP directory

Ensure your FTP server has a directory (e.g. `pg`) where backups will be stored.

## 3. Create environment file

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

export DB_HOST="127.0.0.1"
export DB_PORT="5432"
export LOCAL_BACKUP_DIR="/tmp/pg_backup"
export FTP_MOUNT_POINT="/mnt/ftp_backup"
```

Secure the file:

```bash
sudo chmod 600 /etc/pg-backup.env
```

## 4. Test scripts manually

```bash
source /etc/pg-backup.env

./scripts/backup_to_ftp.sh
./scripts/check_remote_backup.sh
```

## 5. Setup cron jobs

Edit root cron:

```bash
sudo crontab -e
```

Add:

```cron
MAILTO="you@example.com"

# Backup every 12 hours
0 */12 * * * . /etc/pg-backup.env && /path/to/scripts/backup_to_ftp.sh

# Daily verification
0 8 * * * . /etc/pg-backup.env && /path/to/scripts/check_remote_backup.sh
```

## 6. Logging (optional)

```cron
0 */12 * * * . /etc/pg-backup.env && /path/to/scripts/backup_to_ftp.sh >> /var/log/pg_backup.log 2>&1
0 8 * * * . /etc/pg-backup.env && /path/to/scripts/check_remote_backup.sh >> /var/log/pg_backup_check.log 2>&1
```

## 7. Email setup

Install postfix:

```bash
sudo apt install postfix
```

Test email:

```bash
echo "Test email" | mail -s "Test" you@example.com
```

## 8. Troubleshooting

### FTP mount issues
```bash
mkdir -p /mnt/ftp_backup
curlftpfs ftp://$FTP_HOST /mnt/ftp_backup -o user=$FTP_USER:$FTP_PASS
ls -la /mnt/ftp_backup
fusermount -u /mnt/ftp_backup
```

### Access denied (530)
- Check FTP credentials
- Verify FTP protocol

### Backup missing
- Check cron logs
- Verify database access

## 9. Security tips

- Never store credentials in scripts
- Use restricted env file
- Consider using .pgpass for DB passwords

## 10. Summary

1. Install packages
2. Create FTP directory
3. Configure env file
4. Test scripts
5. Setup cron
6. Monitor logs and email