# EDINET APIを使う
　財務諸表を効率よく読むためにコードを作成する。EDINETについては以下。

- [EDINET](https://disclosure2dl.edinet-fsa.go.jp/guide/static/disclosure/WZEK0110.html)

## 環境について
　動作環境と開発環境についてメモする。以下に示す。

|項目|バージョンなど|
|-|-|
|OS|Ubuntu 22.04|
|docker|23.0.1|
|docker compose|v2.16.0|
|Rubyコンテナ|ruby:3.1.3-bullseye|

Rubyスクリプトの中にLinuxコマンドが入っているのでdockerで動かせば問題なく動作すると考えられる。
（特にWindowsで動かす場合はDockerでないと動かないことが予想される。）

以下のコマンドでコンテナを作成できるようにしている。
```bash
docker compose up -d --build
```
上記コマンドで`ruby-bullseye:3.1.3`のコンテナイメージが新しく作成される。

## コマンドラインから使う。
　例えば、書類管理番号`S-XXXXXX`の書類一式（zipファイル）を取得するには以下を実行する。

```bash
curl "https://disclosure.edinet-fsa.go.jp/api/v1/documents/S-XXXXXX?type=1" --output S-XXXXXX.zip
```

これによりzipファイルを入手できる。単純に開くだけなら以下を実行。

```bash
unzip S-XXXXXX.zip
```

この中にある`xbrl`の拡張子のファイルが目的のファイル。

## プログラムから使う
　プログラムを使って利用する。

### 書類一覧API
　取得したい書類の情報を得るプログラムを作成した。rubyのmoduleとして作成した。以下に概要を示す。

|Module#method|入力|出力|
|-|-|-|
|EdinetDocument::ListViewer#arrange_search_data|提出者名、探索期間|エディネットコードごとに分けた書類情報を配列で返却|
|EdinetDocument::ListViewer#show_doc_info_table|提出者名、探索期間|EdinetDocument::ListViewer#arrange_search_dataの結果をターミナルに表示する。|