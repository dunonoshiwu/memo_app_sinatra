# メモアプリ（sinatra)
sinatraで作ったメモアプリです。メモの作成、編集、削除ができます。
# ローカルでの立ち上げ方
**MacOSにHomebrewとPostgresSQLがインストールしてあることを前提にしてます。**
1. PostgreSQLのテーブルを作成
```
# サーバーの起動
brew services start postgresql
# postgresデータベースにログイン
psql -U user_name postgres
# データベースの作成
create database sinatra_memo_app;
# 作ったデータベースに接続
\c sinatra_memo_app;
# テーブルの作成
CREATE TABLE memos
(id CHAR(36) NOT NULL,
title VARCHAR(50) NOT NULL,
content TEXT NOT NULL,
PRIMARY KEY (id));
# テーブル構造の確認
\d memos
```
2. アプリのインストール
```
$ bundle install
$ bundle exec ruby memo.rb
```
ブラウザで下記のURLを開きます
[http://localhost:4567](http://localhost:4567)へアクセスする
# 使い方
`メモ追加`ボタンでメモを新規作成します
`変更`ボタンで既存のメモの編集をします
`削除`ボタンでメモの削除を実行します
