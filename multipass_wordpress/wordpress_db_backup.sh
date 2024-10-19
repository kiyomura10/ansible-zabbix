#!/bin/bash

# パイプライン内で失敗したコマンドがあれば、それを捕捉
set -o pipefail 

DATE=$(date +'%Y%m%d')
DB_NAME="wordpress_db"
DUMP_OPTIONS="--single-transaction --default-character-set=utf8mb4"
BACKUP_FILE="/var/backups/mysql/wordpress_db_backup_$DATE.gz"

#wordpress_dbバックアップの取得
if mysqldump --login-path=backup $DUMP_OPTIONS $DB_NAME | gzip > $BACKUP_FILE; then
	echo "Backup completed: $BACKUP_FILE";
	
	#5日より前に作成されたファイルの削除
	find /var/backups/mysql/ -name "wordpress_db_backup_*.gz" -type f -mtime +5 -exec echo "Deleting {}" \; -exec rm {} \;
else
	echo "Backup failed";
fi
