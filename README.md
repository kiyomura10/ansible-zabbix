# ansible-zabbix-grafana

Ansibleを使って、WordPressスタックとZabbix + Grafanaによる監視スタックを自動構築するためのプレイブック集です。

## 📦 構成概要（Environment Overview）

### ✅ WordPress スタック

| コンポーネント | バージョン |
|----------------|------------|
| Webサーバー     | Nginx（latest） |
| PHP           | 8.3       |
| データベース    | MySQL 8.0.40 |

### ✅ 監視スタック

| コンポーネント | バージョン |
|----------------|------------|
| Zabbix Server  | 5.0.x    |
| Grafana        | latest     |

---

## 🌐 アクセス情報

- **Webサイト**: [http://hostname/](http://hostname/)
- **Grafana**: [http://hostname:3000/](http://hostname:3000/)（初期ユーザー: `admin`, パスワード: `admin`）

---

## ▶️ Playbook 実行方法

```bash
ansible-playbook playbook.yml
