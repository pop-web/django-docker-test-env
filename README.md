hoge
# DjangoとDockerを用いた開発環境の構築とCloud Runへのデプロイ

Djangoを使用した開発を始めるにあたり、Dockerで開発環境と本番環境のセットアップを行いました。

## 前提条件

- Dockerがインストールされていること
- Docker Composeがインストールされていること

## クローン

1. まず、このリポジトリをクローンします：
```sh
git clone git@github.com:pop-web/django-docker-test-env.git
```

2. クローンしたディレクトリに移動します：
```sh
cd django-docker-test-env
```

3. ルートディレクトリに`.env`ファイルを作成し、以下の環境変数を設定します（必要に応じて値を変更してください）：
```
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=password
ALLOWED_HOSTS=localhost,127.0.0.1
```

## 設定ファイルの説明

開発環境と本番環境に対応した`Dockerfile`と`docker-compose.yml`を用意しています。

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

## アプリケーションの起動方法

アプリケーションの起動方法を説明します。

### ビルド
```sh
docker-compose -f docker-compose.dev.yml build
```

### プロジェクトの作成

プロジェクトを作成します。
```sh
docker-compose -f docker-compose.dev.yml run --rm web sh -c "django-admin startproject myproject ."
```

### アプリの作成
```sh
docker-compose -f docker-compose.dev.yml  run --rm web sh -c "python manage.py startapp myapp"
```


### settings.pyの編集

プロジェクトディレクトリ（myproject）の`settings.py`を編集していきます。

import周辺を以下のように変更します。

- 変更前
```py
from pathlib import Path
```
- 変更後
```py
import os
from pathlib import Path
from decouple import Csv, config

DEBUG = config("DEBUG", default=False, cast=bool)
```

ALLOWED_HOSTSを以下のように変更します。
```py
ALLOWED_HOSTS = config("ALLOWED_HOSTS", cast=Csv())
```

INSTALLED_APPSに`myapp`を追加します。
```py
INSTALLED_APPS = [
    "myapp",
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]
```

`DATABASES`を以下ように変更します。
```py
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": config("DB_NAME"),
        "USER": config("DB_USER"),
        "PASSWORD": config("DB_PASSWORD"),
        "HOST": "db",  # Docker Composeで指定したデータベースのサービス名
        "PORT": "5432",
    }
}
```

### 起動

Docker Composeを使用して開発環境のアプリケーションとデータベースを起動します：
```sh
docker-compose -f docker-compose.dev.yml up
```

コマンドを実行した後、ブラウザで`http://localhost:8000/`にアクセスすると、Djangoアプリケーションが表示されます。


### Hello Worldのページ作成

Hello Worldと表示させるページを新規作成します。

プロジェクトディレクトリ（myproject）の`urls.py`を新たに作成します。
```py
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("myapp/", include("myapp.urls")),
]
```

アプリディレクトリ（myapp）の`urls.py`へ`hello/`のパスを追加します。
```py
from django.urls import path

from . import views

urlpatterns = [
    path("hello/", views.hello_world, name="hello_world"),
]
```

アプリディレクトリ（myapp）の`views.py`を変更します。
```py
from django.shortcuts import render


def hello_world(request):
    return render(request, "myapp/hello_world.html", {"message": "Hello, World!"})
```

最後に、`myapp`へ以下のテンプレートを追加します
`myapp/templates/myapp/hello_world.html`

ファイルの内容は以下
```html
<!DOCTYPE html>
<html>
<head>
    <title>Hello, World!</title>
</head>
<body>
    <h1>{{ message }}</h1>
</body>
</html>
```


「control + c」で一度止めて、再スタートさせます。
```sh
docker-compose -f docker-compose.dev.yml up
```

以下のパスをブラウザで確認すると「Hello, World!」と表示されます。
```
http://localhost:8000/myapp/hello/
```

## Cloud Runへデプロイ

1. Google Cloud SDKのインストール

Google Cloud SDKをインストールすることで、コマンドラインからGoogle Cloudプロダクトを管理することが可能になります。インストールの手順は公式ドキュメントを参照してください。

2. Google Cloud SDKの初期設定

インストール後、gcloud init コマンドを使ってGoogle Cloud SDKを初期化します。このコマンドを実行すると、ログインを求められます。ログインに成功すると、プロジェクトとデフォルトの設定リージョンを選択するように求められます。
```sh
gcloud init
```

3. Dockerイメージのビルド

まず、Dockerfileが存在するディレクトリに移動します。次に、以下のコマンドを使ってDockerイメージをビルドします。ここではアプリケーション名として適切な名前を指定します。
```sh
docker build --platform linux/amd64 -f Dockerfile.prod -t asia-northeast1-docker.pkg.dev/my-project-id/my-project/my-image:tag .
```

4. Dockerイメージのプッシュ

Google Cloud SDKに含まれるDocker認証ヘルパーを使って、Google Artifact Registryにイメージをプッシュします。
```sh
docker push asia-northeast1-docker.pkg.dev/my-project-id/my-project/my-image:tag
```

5. Cloud Runへのデプロイ

以下のコマンドを使って、Cloud Runにアプリケーションをデプロイします。
```sh
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