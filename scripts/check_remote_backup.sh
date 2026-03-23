#!/bin/bash
set -euo pipefail

FTP_HOST="${FTP_HOST:?FTP_HOST is required}"
FTP_USER="${FTP_USER:?FTP_USER is required}"
FTP_PASS="${FTP_PASS:?FTP_PASS is required}"
REMOTE_BACKUP_SUBDIR="${REMOTE_BACKUP_SUBDIR:?REMOTE_BACKUP_SUBDIR is required}"
DATABASES="${DATABASES:?DATABASES is required}"

FTP_MOUNT_POINT="${FTP_MOUNT_POINT:-/mnt/ftp_backup}"
REMOTE_BACKUP_DIR="${FTP_MOUNT_POINT}/${REMOTE_BACKUP_SUBDIR}"
HOSTNAME_VALUE="$(hostname)"

mkdir -p "$FTP_MOUNT_POINT"

cleanup() {
    if mountpoint -q "$FTP_MOUNT_POINT"; then
        fusermount -u "$FTP_MOUNT_POINT" 2>/dev/null || umount -l "$FTP_MOUNT_POINT" 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo "Mounting FTP for verification..."
curlftpfs "ftp://${FTP_HOST}" "$FTP_MOUNT_POINT" -o "user=${FTP_USER}:${FTP_PASS}"

if ! mountpoint -q "$FTP_MOUNT_POINT"; then
    echo "CRITICAL: could not mount FTP on $HOSTNAME_VALUE"
    exit 2
fi

if [ ! -d "$REMOTE_BACKUP_DIR" ]; then
    echo "CRITICAL: remote backup directory missing: $REMOTE_BACKUP_DIR"
    exit 2
fi

missing=()

check_recent_backup() {
    local pattern="$1"
    find "$REMOTE_BACKUP_DIR" -maxdepth 1 -type f -name "$pattern" -mtime -1 | grep -q .
}

for entry in $DATABASES; do
    IFS=":" read -r db_name db_user db_pass <<< "$entry"

    if [ -z "$db_name" ]; then
        echo "ERROR: Invalid DATABASES entry: $entry"
        exit 1
    fi

    if ! check_recent_backup "${db_name}-*.tar"; then
        missing+=("$db_name")
    fi
done

if [ ${#missing[@]} -eq 0 ]; then
    echo "OK: recent remote backups exist for all configured databases within the last 24 hours on $HOSTNAME_VALUE"
    exit 0
fi

echo "FAILED: no recent remote backup found within the last 24 hours for:"
printf ' - %s\n' "${missing[@]}"
exit 1