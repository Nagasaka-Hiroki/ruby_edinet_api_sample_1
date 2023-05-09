#Pythonのバージョンは3.11.2
#ディストリビューションはdebian系を選択する。
FROM python:3.11.2-slim-bullseye

#シェルをbashにする。
SHELL ["/bin/bash","-c"]

#docker compose file経由で.envファイルの変数を参照する。
ARG GROUP_ID
ARG GROUP_NAME
ARG USER_ID
ARG USER_NAME
#一般ユーザを追加する。
RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} \
 && useradd -m -s /bin/bash -u ${USER_ID} -g ${GROUP_ID} ${USER_NAME}

#GUI環境を有効にするためのツールをインストールする。
RUN apt-get update && apt-get upgrade -y \
 && apt-get install python3-tk tk-dev -y

#ツールを追加する。
RUN apt-get update && apt-get upgrade -y \
 && apt-get install curl git vim -y

#ユーザを切り替える。
USER ${USER_NAME}

#外部ライブラリをインストールする。
RUN pip install --upgrade pip \
 && pip install numpy \
 && pip install matplotlib \
 && pip install arelle-release

#プロンプトの色を有効にする。
RUN sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' ~/.bashrc

#作業ディレクトリをホームに設定する。
WORKDIR ${WORK_DIR}

CMD ["/bin/bash"]