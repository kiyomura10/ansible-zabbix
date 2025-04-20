#!/bin/bash

#コマンドが失敗したらスクリプト停止、未定義の変数を参照するとエラー 
set -eu 

DATE=$(date +'%Y%m%d')
DB_NAME="{{ DB_NAME }}"
DUMP_OPTIONS="--single-transaction --default-character-set=utf8mb4"
BACKUP_DIR="/var/backups/mysql"
BACKUP_FILE="/var/backups/mysql/${DB_NAME}${DATE}.gz"

# バックアップディレクトリがなければ作成
mkdir -p "$BACKUP_DIR"

#{{ DB_NAME }}バックアップの取得
mysqldump --login-path=backup $DUMP_OPTIONS $DB_NAME | gzip > $BACKUP_FILE;
echo "Backup completed: $BACKUP_FILE";
	
#5日より前に作成されたファイルの削除
rm /var/backups/mysql/${DB_NAME}_$(date -d "5 days ago" +"%Y%m%d").gz