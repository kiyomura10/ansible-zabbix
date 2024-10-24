# MultipassでWordPressの環境構築手順

## ユーザーの作成


```
useradd —m -s /bin/bash menta 
```
ユーザー「menta」を追加、-mオプションでホームディレクトリ「/home/menta」を作成、-sオプションでデフォルトシェルを「bash」にする。

## sshで接続できるようにする
ローカルで鍵の作成
```
ssh-keygen -t rsa -f ~/.ssh/menta-key
```
-tで暗号化タイプrsaを指定、-fでファイル名の指定、「menta-key」でキーペアの作成。

公開鍵:menta-key.pub
秘密鍵:menta-key
が作成される。

公開鍵を仮想サーバーの~/.ssh/authorized_keysに設置する。

sshで接続
```
ssh -i ~/.ssh/menta-key menta@192.168.64.3
```


## nginxのインストールとバーチャルホストの設定
Nginxのインストール
```
sudo apt install nginx
```

・nginxの設定ファイル  
メイン設定ファイル：/etc/nginx/nginx.conf  
仮想ホストの設定ファイル：/etc/nginx/sites-available/  
有効化された仮想ホスト（シンボリックリンクを配置する）：/etc/nginx/sites-enabled/  


・設定ファイルの編集

/etc/nginx/sites-available/に設定ファイルdev.menta.me.confを作成。  
ドキュメントルートは /var/www/dev.menta.meに設定　
また、php-fpmとの連携の設定も記述しておく。

```
sudo vi /etc/nginx/sites-available
```

```
server {

        listen 80;

        #バーチャルホストのホスト名
        server_name dev.menta.me;

        #ドキュメントルート
        root /var/www/dev.menta.me;
        index index.php index.html;
        #アクセスログ、エラーログの出力先を指定
        access_log /var/log/nginx/dev.menta.me.log custom_log;
        error_log /var/log/nginx/dev.menta.me.error.log;

        #リクエストされたuriと同じファイル、同じディレクトリがあるかを探す。どちらも存在しない場合はindex.phpへ処理を渡す。
        $argsはnginxの変数、クエリを渡すために使用する。
        location / {
        try_files $uri $uri/ /index.php?$args;
        }

        # PHP-FPM の設定拡張子phpのファイルに以下の振る舞いをする
        location ~ \.php$ {
        #使用するパラメータnginxのインストール時に提供されるファイルを使用
        include fastcgi_params;
        #処理するファイル名
        fastcgi_index index.php;
        #php-fpmのunixソケットのファイルパスを指定す。
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        #ドキュメントルート内のリクエストされたPHPファイルを探索し、PHP-FPMに正しいファイルパス（フルパス）を伝える設定
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
}
```

設定ファイルを有効化するために/etc/nginx/sites-enabled/ディレクトリへのシンボリックリンクを作成
```
sudo ln -s /etc/nginx/sites-available/dev.menta.me.conf /etc/nginx/sites-enabled/
```
ドキュメントルート /var/www/dev.menta.meh配下にテスト用のファイルindex.htmlを配置

nginx 構文チェック　
```
nginx -t
```

問題なければnginx再起動

```
sudo systemctl restart nginx.service 
```

・ローカルのhostsファイルの設定
/etc/hostsに以下の内容を追記
```
192.168.64.3 dev.menta.me
```

ブラウザでhttp://dev.menta.me にアクセスできるか確認する

#　phpのインストールと設定

リポジトリの設定
```
sudo add-apt-repository ppa:ondrej/php
```

パッケージのインデックスの更新
```
sudo apt update
```


## PHPと必要なモジュールのインストール
```
sudo apt install -y php php-fpm php-json php-mysql php-curl php-xml php-igbinary php-imagick php-intl php-mbstring php-zip
```

WordPressの動作に必要なphpの拡張機能は以下を参照(WordPressの公式ドキュメント)
https://make.wordpress.org/hosting/handbook/server-environment/#php-extensions

・php-fpmの設定
```
設定ファイル
/etc/php/8.3/fpm/pool.d/pool.d
```
以下の設定に変更
```
pm = static
pm.max_children = 10
pm.max_requests = 1000
user = www-data
group = www-data
listen = /run/php/php8.3-fpm.sock
listen.owner = www-data
listen.group = www-data
```

## MySQL8のインストール

MySQLのインストール

```
sudo apt install mysql-server
```

MySQLの起動とステータスの確認
```
sudo systemctl start mysql
sudo systemctl status mysql
```

・MySQLの設定ファイル
メイン（インクルードが記載）：/etc/mysql/my.cnf  
通常設定を記載するファイル：/etc/mysql/mysql.conf.d/mysqld.cnf  
特定の機能やカスタム設定：/etc/mysql/conf.d/  
ユーザーごとの設定：~/.my.cnf  


文字コードの設定
/etc/mysql/mysql.conf.d/mysqld.cnf に記載

```
character-set-server = utf8mb4 
collation-server = utf8mb4_general_ci
```

ユーザー権限の設定
MySQLサーバーに接続
rootユーザで接続（OSのユーザー認証）
```
mysql -u root -p
```

wordpress DB作成
```
CREATE DATABASE wordpress_db;
```

ユーザー作成
```
CREATE USER 'menta'@'localhost' IDENTIFIED BY 'menta123';
```

ユーザーへ権限の付与
```
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'menta'@'localhost';
```

権限の反映
```
FLUSH PRIVILEGES;
```

パスワードの管理はmysql_config_editorファイルを使用する

接続情報を登録
```
mysql_config_editor set --login-path=backup --host=localhost --user=menta --password
```

~/配下に.mylogin.cnfに接続情報が保存される

以下で接続情報を確認できる
```
mysql_config_editor print --all
```

これによりmysqlに接続するときに以下のコマンドで接続可能になる
```
mysql --login-path=backup
```

データベースバックアップ用のスクリプトの作成
(第５世代/5日分)
```
vi wordpress_db_backup.sh
```

## WordPressのインストール

/var/www/dev.menta.meにインストール

```
cd /var/www/dev.menta.me
```

ワードプレスのダウンロード

```
sudo wget https://wordpress.org/latest.tar.gz
```

ダウンロードしたファイルの解凍
```
tar -xzvf latest.tar.gz
```

設定ファイルのサンプルからコピーして名前を変更
```
cp wp-config-sample.php wp-config.php
```

設定ファイルを編集
```
vi wp-config.php
```

WordPressで使用するデータベースの設定
```
define( 'DB_NAME', 'wordpress_db' );
define( 'DB_USER', 'menta' );
define( 'DB_PASSWORD', 'menta123' );
define( 'DB_HOST', 'localhost' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );
```

ユーザー、パーミッションの変更（nginxのユーザはwww-data）

```
sudo chown -R www-data:www-data /var/www/dev.menta.me
sudo chmod -R 755 /var/www/dev.menta.me 
```

サービスの再起動

```
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm.service
sudo systemctl restart mysql
```

以下にアクセスする
http://dev.menta.me

ワードプレスで投稿できれば構築完了

<img width="1440" alt="スクリーンショット 2024-10-19 14 38 27" src="https://github.com/user-attachments/assets/6f9ee6ec-1ca4-4664-9a69-5e6bd6063a54">

