# EDINET APIを使う
　財務諸表を効率よく読むためにコードを作成する。EDINETについては以下。

- [EDINET](https://disclosure2dl.edinet-fsa.go.jp/guide/static/disclosure/WZEK0110.html)

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
