# Setup Guide

This guide explains how to install, configure, and run PostgreSQL FTP backups on Ubuntu.

---

## 1. Install dependencies

```bash
sudo apt update
sudo apt install -y git postgresql-client curlftpfs fuse msmtp msmtp-mta mailutils
```

Optional (for alternative mail setup):

```bash
sudo apt install -y postfix
```

---

## 2. Clone repository

```bash
cd /opt
sudo git clone https://github.com/your-user/postgresql-ftp-backup-example.git
sudo chown -R $USER:$USER /opt/postgresql-ftp-backup-example
cd /opt/postgresql-ftp-backup-example
```

---

## 3. Fix script permissions

```bash
chmod +x scripts/backup_to_ftp.sh
chmod +x scripts/check_remote_backup.sh
```

If you see `Permission denied`:

```bash
bash ./scripts/backup_to_ftp.sh
```

---

## 4. Create environment file

```bash
sudo vi /etc/pg-backup.env
```

Press `i` and paste:

```bash
export FTP_HOST="ftp.example.com"
export FTP_USER="your_ftp_user"
export FTP_PASS="your_ftp_pass"
export REMOTE_BACKUP_SUBDIR="pg"

export DATABASES="db1:user1:pass1 db2:user2:pass2"

export DB_HOST="127.0.0.1"
export DB_PORT="5432"
export LOCAL_BACKUP_DIR="/tmp/pg_backup"
export FTP_MOUNT_POINT="/mnt/ftp_backup"
```

Save:

```
Esc → :wq → Enter
```

Secure file:

```bash
sudo chmod 600 /etc/pg-backup.env
```

---

## 5. Load environment variables

```bash
source /etc/pg-backup.env
```

---

## 6. Test scripts manually

```bash
./scripts/backup_to_ftp.sh
./scripts/check_remote_backup.sh
```

---

# 📧 7. Email setup (REQUIRED for notifications)

Ubuntu does not send emails by default. Use **msmtp (recommended)**.

## Configure SMTP

```bash
sudo vi /etc/msmtprc
```

Press `i` and paste:

```ini
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account default
host smtp.gmail.com
port 587
from your-email@gmail.com
user your-email@gmail.com
password your-app-password
```

### Gmail users

You must use an App Password:

1. Enable 2FA
2. Go to Google → Security → App passwords
3. Generate password
4. Use it above

---

## Secure config

```bash
sudo chmod 600 /etc/msmtprc
```

---

## Test email

```bash
echo "Test email" | mail -s "Test" your-email@gmail.com
```

---

## Check logs

```bash
cat /var/log/msmtp.log
```

---

# ⏱️ 8. Setup cron jobs

```bash
sudo crontab -e
```

Recommended:

```cron
# Backup every 12 hours
0 */12 * * * . /etc/pg-backup.env && /opt/postgresql-ftp-backup-example/scripts/backup_to_ftp.sh >> /var/log/pg_backup.log 2>&1

# Daily check (email on failure)
0 8 * * * . /etc/pg-backup.env && /opt/postgresql-ftp-backup-example/scripts/check_remote_backup.sh >/tmp/pg_check.log 2>&1 || mail -s "Backup FAILED on $(hostname)" your-email@gmail.com < /tmp/pg_check.log
```

---

# 📄 9. Logs

```bash
tail -f /var/log/pg_backup.log
tail -f /tmp/pg_check.log
```

---

# 🔧 10. Troubleshooting

## Permission denied

```bash
chmod +x scripts/*.sh
```

## Test mail

```bash
echo "test" | mail -s "test" your-email@gmail.com
```

## Cron issues

```bash
grep CRON /var/log/syslog
```

## FTP issues

```bash
mkdir -p /mnt/ftp_backup
curlftpfs ftp://$FTP_HOST /mnt/ftp_backup -o user=$FTP_USER:$FTP_PASS
ls -la /mnt/ftp_backup
fusermount -u /mnt/ftp_backup
```

## Access denied (530)

```bash
curl -v --user "$FTP_USER:$FTP_PASS" ftp://$FTP_HOST/
```

---

# 🔐 11. Security tips

- Do not store credentials in scripts
- Keep env file outside repo
- Restrict access:

```bash
sudo chmod 600 /etc/pg-backup.env
```

---

# ✅ 12. Quick start

```bash
sudo apt install -y git postgresql-client curlftpfs fuse msmtp msmtp-mta mailutils

cd /opt
sudo git clone https://github.com/your-user/postgresql-ftp-backup-example.git
sudo chown -R $USER:$USER /opt/postgresql-ftp-backup-example
cd /opt/postgresql-ftp-backup-example

chmod +x scripts/*.sh

sudo vi /etc/pg-backup.env
sudo chmod 600 /etc/pg-backup.env

source /etc/pg-backup.env

./scripts/backup_to_ftp.sh

sudo crontab -e
```