# Setup Guide

## 1. Install dependencies

```bash
sudo apt update
sudo apt install -y git postgresql-client curlftpfs fuse bsd-mailx
```

Optional (for email support):

```bash
sudo apt install -y postfix
```

---

## 2. Clone repository

```bash
cd /opt
sudo git clone https://github.com/a08778/postgresql-ftp-backup-example.git
sudo chown -R $USER:$USER /opt/postgresql-ftp-backup-example
cd /opt/postgresql-ftp-backup-example
```

---

## 3. Fix permissions

```bash
chmod +x scripts/backup_to_ftp.sh
chmod +x scripts/check_remote_backup.sh
```

If you see "Permission denied":

```bash
bash ./scripts/backup_to_ftp.sh
```

---

## 4. Create environment file

```bash
sudo vi /etc/pg-backup.env
```

Press `i`, paste:

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

Save with:

```
Esc → :wq → Enter
```

Secure file:

```bash
sudo chmod 600 /etc/pg-backup.env
```

---

## 5. Load variables

```bash
source /etc/pg-backup.env
```

---

## 6. Test scripts

```bash
./scripts/backup_to_ftp.sh
./scripts/check_remote_backup.sh
```

---

## 7. Setup cron

```bash
sudo crontab -e
```

Add:

```cron
MAILTO="you@example.com"

0 */12 * * * . /etc/pg-backup.env && /opt/postgresql-ftp-backup-example/scripts/backup_to_ftp.sh
0 8 * * * . /etc/pg-backup.env && /opt/postgresql-ftp-backup-example/scripts/check_remote_backup.sh
```

---

## 8. Email test

```bash
echo "Test" | mail -s "Test mail" you@example.com
```

---

## 9. Logs (optional)

```cron
>> /var/log/pg_backup.log 2>&1
```

---

## Done

Backups now:
- run every 12 hours
- verified daily
