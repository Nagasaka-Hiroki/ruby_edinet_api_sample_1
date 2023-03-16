#Rubyのバージョンは3.1.3
#ディストリビューションはdebian系を選択する。
FROM ruby:3.1.3-bullseye

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

#ユーザを切り替える。
USER ${USER_NAME}
#作業ディレクトリをホームに設定する。
WORKDIR ${WORK_DIR}

CMD ["/bin/bash"]