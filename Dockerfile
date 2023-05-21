# 使用する基本イメージ
FROM python:3.9

# バッファリングされたstdoutとstderr出力を強制的にフラッシュすることで、Dockerログに即時出力させる
ENV PYTHONUNBUFFERED 1

# コードを配置するディレクトリを作成
RUN mkdir /code

# 作業ディレクトリを指定
WORKDIR /code

# requirements.txtを/code/ディレクトリにコピー
COPY requirements.txt /code/

# requirements.txtに記載されたパッケージをインストール
RUN pip install -r requirements.txt

# ローカルのファイルを/code/ディレクトリにコピー
COPY . /code/
