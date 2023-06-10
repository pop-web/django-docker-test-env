# Dockerを使用したDjango開発環境：CRUD操作とCloud Runへのデプロイ可能

このリポジトリでは、Dockerを利用したDjangoの開発環境を提供します。ここでは、CRUD操作が可能なアプリケーションの実行環境をセットアップし、Google Cloud Runへのデプロイが可能な設定を含めています。

## 前提条件

- Dockerがインストールされていること
- Docker Composeがインストールされていること

## 環境設定手順

1. このリポジトリをクローンします：
    ```
    git clone git@github.com:pop-web/django-docker-test-env.git
    ```

2. クローンしたディレクトリに移動します：
    ```
    cd django-docker-test-env
    ```

3. ルートディレクトリに`.env`ファイルを作成し、以下の環境変数を設定します（必要に応じて値を変更してください）：
    ```
    DB_NAME=postgres
    DB_USER=postgres
    DB_PASSWORD=password
    ```

## アプリケーションの起動方法

Docker Composeを使用してアプリケーションとデータベースを起動します：

```
docker-compose build
docker-compose up
```

起動後、ブラウザで`http://localhost:8000/myapp`にアクセスすると、Djangoアプリケーションが表示されます。

## 注意事項

この環境は開発用途のみを想定しています。そのまま本番環境で利用することは推奨されません。本番環境への適用には、セキュリティやパフォーマンスに関する追加の対策や調整が必要となります