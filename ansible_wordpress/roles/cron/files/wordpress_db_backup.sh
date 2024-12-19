#!/bin/bash

#コマンドが失敗したらスクリプト停止、未定義の変数を参照するとエラー 
set -eu 

DATE=$(date +'%Y%m%d')
DB_NAME="wordpress_db"
DUMP_OPTIONS="--single-transaction --default-character-set=utf8mb4"
BACKUP_FILE="/var/backups/mysql/wordpress_db_backup_$DATE.gz"

#wordpress_dbバックアップの取得
mysqldump --login-path=backup $DUMP_OPTIONS $DB_NAME | gzip > $BACKUP_FILE;
echo "Backup completed: $BACKUP_FILE";
	
#5日より前に作成されたファイルの削除
rm /var/backups/mysql/wordpress_db_backup_$(date -d "5 days ago" +"%Y%m%d").gz