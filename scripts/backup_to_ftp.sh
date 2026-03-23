#!/bin/bash
set -euo pipefail

FTP_HOST="${FTP_HOST:?FTP_HOST is required}"
FTP_USER="${FTP_USER:?FTP_USER is required}"
FTP_PASS="${FTP_PASS:?FTP_PASS is required}"
REMOTE_BACKUP_SUBDIR="${REMOTE_BACKUP_SUBDIR:?REMOTE_BACKUP_SUBDIR is required}"
DATABASES="${DATABASES:?DATABASES is required}"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
LOCAL_BACKUP_DIR="${LOCAL_BACKUP_DIR:-/tmp/pg_backup}"
FTP_MOUNT_POINT="${FTP_MOUNT_POINT:-/mnt/ftp_backup}"

REMOTE_BACKUP_DIR="${FTP_MOUNT_POINT}/${REMOTE_BACKUP_SUBDIR}"
CUR_DATE="$(date '+%Y-%m-%d-%H')"

mkdir -p "$LOCAL_BACKUP_DIR"
mkdir -p "$FTP_MOUNT_POINT"

cleanup() {
    if mountpoint -q "$FTP_MOUNT_POINT"; then
        fusermount -u "$FTP_MOUNT_POINT" 2>/dev/null || umount -l "$FTP_MOUNT_POINT" 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo "Mounting FTP..."
curlftpfs "ftp://${FTP_HOST}" "$FTP_MOUNT_POINT" -o "user=${FTP_USER}:${FTP_PASS}"

if ! mountpoint -q "$FTP_MOUNT_POINT"; then
    echo "ERROR: FTP mount failed"
    exit 1
fi

if [ ! -d "$REMOTE_BACKUP_DIR" ]; then
    echo "ERROR: Remote directory not found: $REMOTE_BACKUP_DIR"
    echo "FTP root contents:"
    ls -la "$FTP_MOUNT_POINT" || true
    exit 1
fi

backup_database() {
    local db_name="$1"
    local db_user="$2"
    local db_pass="$3"

    local local_file="${LOCAL_BACKUP_DIR}/${db_name}-${CUR_DATE}.tar"
    local remote_file="${REMOTE_BACKUP_DIR}/${db_name}-${CUR_DATE}.tar"

    echo "Backing up database: ${db_name}"

    export PGPASSWORD="$db_pass"
    /usr/bin/pg_dump \
        --host="$DB_HOST" \
        --port="$DB_PORT" \
        --username="$db_user" \
        --format=tar \
        --no-owner \
        --no-comments \
        --verbose \
        --file="$local_file" \
        "$db_name"

    if [ ! -f "$remote_file" ]; then
        cp "$local_file" "$REMOTE_BACKUP_DIR/"
        echo "Uploaded: $(basename "$local_file")"
    else
        echo "Skipping existing file: $remote_file"
    fi
}

for entry in $DATABASES; do
    IFS=":" read -r db_name db_user db_pass <<< "$entry"

    if [ -z "$db_name" ] || [ -z "$db_user" ] || [ -z "$db_pass" ]; then
        echo "ERROR: Invalid DATABASES entry: $entry"
        echo "Expected format: database_name:database_user:database_password"
        exit 1
    fi

    backup_database "$db_name" "$db_user" "$db_pass"
done

echo "Deleting remote backups older than 14 days..."
find "$REMOTE_BACKUP_DIR" -type f -mtime +14 -delete

echo "Deleting local backups older than 14 days..."
find "$LOCAL_BACKUP_DIR" -type f -mtime +14 -delete

echo "Backup process completed successfully."