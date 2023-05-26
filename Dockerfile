# ベースイメージとしてpython:3.9を使用
FROM python:3.8

# 環境変数の設定
ENV PYTHONUNBUFFERED=1
ENV POETRY_VERSION=1.5.0

# コードを配置するディレクトリを作成
RUN mkdir /code

# 作業ディレクトリの設定
WORKDIR /code

# Poetryのインストール
RUN pip install "poetry==$POETRY_VERSION"

# pyproject.tomlとpoetry.lockファイルをコピー
COPY pyproject.toml poetry.lock /code/

# 依存関係のインストール
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi
RUN pip install gunicorn

# アプリケーションのソースコードをコピー
COPY . /code/

# ポートの公開
EXPOSE 8080

# Gunicornを使用してアプリケーションを起動
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 myproject.wsgi:application
