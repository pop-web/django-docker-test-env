# DjangoとDockerを用いた開発環境の構築とCloud Runへのデプロイ

Djangoを使用した開発を始めるにあたり、Dockerで開発環境と本番環境のセットアップを行いました。

## 前提条件

- Dockerがインストールされていること
- Docker Composeがインストールされていること

## 環境設定手順

1. まず、このリポジトリをクローンします：
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
    ALLOWED_HOSTS=localhost,127.0.0.1
    ```

## アプリケーションの起動方法

開発環境と本番環境に対応した`Dockerfile`と`docker-compose.yml`を用意しました。

開発環境用の設定ファイル
```
Dockerfile.dev
docker-compose.dev.yml
```
本番環境用の設定ファイル
```
Dockerfile.prod
docker-compose.prod.yml
```

### 開発環境の起動

Docker Composeを使用して開発環境のアプリケーションとデータベースを起動します：

```
docker-compose -f docker-compose.dev.yml build
docker-compose -f docker-compose.dev.yml up
```

これらのコマンドを実行した後、ブラウザで`http://localhost:8000/myapp/hello/`にアクセスすると、Djangoアプリケーションが表示されます。

## Cloud Runへデプロイ

1. Google Cloud SDKのインストール

    Google Cloud SDKをインストールすることで、コマンドラインからGoogle Cloudプロダクトを管理することが可能になります。インストールの手順は公式ドキュメントを参照してください。

2. Google Cloud SDKの初期設定

    インストール後、gcloud init コマンドを使ってGoogle Cloud SDKを初期化します。このコマンドを実行すると、ログインを求められます。ログインに成功すると、プロジェクトとデフォルトの設定リージョンを選択するように求められます。

    ```
    gcloud init
    ```

3. Dockerイメージのビルド

    まず、Dockerfileが存在するディレクトリに移動します。次に、以下のコマンドを使ってDockerイメージをビルドします。ここではアプリケーション名として適切な名前を指定します。

    ```
    docker build --platform linux/amd64 -f Dockerfile.prod -t asia-northeast1-docker.pkg.dev/my-project-id/my-project/my-image:tag .
    ```

4. Dockerイメージのプッシュ

    Google Cloud SDKに含まれるDocker認証ヘルパーを使って、Google Artifact Registryにイメージをプッシュします。

    ```
    docker push asia-northeast1-docker.pkg.dev/my-project-id/my-project/my-image:tag
    ```

5. Cloud Runへのデプロイ

    以下のコマンドを使って、Cloud Runにアプリケーションをデプロイします。

    ```
    gcloud run deploy django-project --image asia-northeast1-docker.pkg.dev/my-project-id/my-project/my-image:tag --platform managed --region asia-northeast1
    ```
6. GitHub Actionsでデプロイを自動化

さらに、デプロイの自動化する場合は以下を参照して下さい。

https://zenn.dev/minnanowp/articles/8a11f336c96768

## 注意事項

本番環境への適用には、セキュリティやパフォーマンスに関する追加の対策や調整が必要となります。具体的には以下のようなことを考慮する必要があります：

- DEBUGモードは無効化する（本番環境ではFalseに設定する）
- SECRET_KEYは安全に管理する
- データベースは本番用のものを設定する
- 適切なロギング設定を行う
- 本番環境に適したWebサーバ（Gunicornなど）を使用する

さらに、Cloud Runへのデプロイを行う際はDockerfile.prodとdocker-compose.prod.ymlを使用してビルドとデプロイを行います。Dockerfile.prodではGunicornを使用してアプリケーションを実行します。

また、Djangoの静的ファイルの扱いには注意が必要です。Djangoはデフォルトでは静的ファイルを提供しないため、本番環境では適切な方法で静的ファイルを扱う必要があります。Djangoの`collectstatic`コマンドを使用するか、Cloud Storageなどを使用する方法があります。

以上がDjangoとDockerを使用した開発環境のセットアップ方法になります。より深く理解するためには、公式ドキュメンテーションを読んだり、具体的な問題に直面したときには適切なリソースを探すことを推奨します。