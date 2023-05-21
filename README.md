# Django Development Environment with Docker

このリポジトリはDockerを使用したDjangoの開発環境を提供します。PostgreSQLデータベースを利用しています。

## 前提条件

- Dockerがインストールされていること
- Docker Composeがインストールされていること

## 環境設定

1. このリポジトリをクローンします：
    ```
    git clone git@github.com:pop-web/django-docker-test-env.git
    ```

2. クローンしたディレクトリに移動します：
    ```
    cd yourrepository
    ```

3. `.env.local`ファイルを作成し、以下のように環境変数を設定します（適宜値を変更してください）：
    ```
    POSTGRES_PASSWORD=mysecretpassword
    ```

## 開始方法

Docker Composeを使用してアプリケーションとデータベースを起動します：

```
docker-compose up
```

その後、ブラウザで`http://localhost:8000/`にアクセスしてDjangoアプリケーションを確認できます。

## 注意

この環境は開発用途であり、本番環境でそのまま利用することは推奨されません。本番環境での使用にはセキュリティやパフォーマンスに関する追加の調整が必要です。

