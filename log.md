# EDINET APIを使う(作業記録)
　財務諸表を効率よく読むためにコードを作成する。EDINETについては以下。

- [EDINET](https://disclosure2dl.edinet-fsa.go.jp/guide/static/disclosure/WZEK0110.html)

## コマンドから
　curlなどを使ってコマンドラインから動作を確認する。

### 書類一覧API
以下をターミナルに入力して実行する。下記はEDINETの仕様書のサンプルである。

```bash
curl "https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=2019-04-01"
curl "https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=2019-04-01&type=2"
```

上記のコマンドでjsonデータが取得できる。リクエストパラメータは下記の通り。

|パラメータ名|項目名|説明|
|-|-|-|
|date|ファイル日付|必ず指定する。`YYYY-MM-DD`で指定する。|
|type|取得情報|`=1`でメタデータのみ。デフォルト。<br>`=2`で書類一覧とメタデータを取得できる。|

少し厄介なのが証券コードで検索ができないこと。証券コードは`secCode`から取得できる。しかし、ターミナルを見ると`secCode`が必ずしもセットされているわけではないようだ。会社名で指定するのが無難だろうか。この点は要検討である。

### 書類取得API
　サンプルのURLがエラーになるので試しにトヨタ自動車のデータをとってみる。

まず存在を確認する。

```bash
curl "https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=2023-02-13&type=2" | grep "トヨタ自動車"
```

OK存在はする。しかし複数ある。一度ファイルに保存して検索する。

```bash
curl "https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=2023-02-13&type=2" > list_2023-02-13.json
```

以下が存在した。
```
S100Q6YW
S100Q71I
S100Q71E
```

とりあえず`S100Q6YW`からデータを取得する。

以下を実行する。

```bash
curl "https://disclosure.edinet-fsa.go.jp/api/v1/documents/S100Q6YW?type=1" --output S100Q6YW.zip
```

`type=1`なのでzipとして保存する。以下のコマンドで解凍する。

```bash
unzip S100Q6YW.zip
```

とりあえずファイルは入手できた。中でも`.xbrl`の拡張子のファイルが重要だと仕様書を読んで感じた。この形式のファイルを解析する必要がある。

---
小ネタ：  
RubyスクリプトからLinuxコマンドを実行するには以下を参考。
- [Kernel.#system (Ruby 3.2 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/method/Kernel/m/system.html)

---

zipファイルのディレクトリ構造を確認する。仕様書の44ページにディレクトリ構造について言及されていた。おおよそ以下の通り。

```
zipファイル
    |- PublicDoc
    ...
    |- XBRL
        |- PublicDoc ←これが重要だと思われる。
        ...
```

上記を参考にダウンロードしたサンプルを読む。構造は`zipファイル/XBRL/PublicDoc`の構造で、`PublicDoc`のディクトリに書類が色々入っていた。

重要な書類はXBRL形式でその拡張子のファイルは一つだけだったのでこのサンプルの場合は判定は容易だった。全て見たわけではないので必ず一つとは限らない。しかし一つだと一旦仮定して作業を勧めていこうと思う。
