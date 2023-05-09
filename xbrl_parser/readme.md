# XBRLパーサーに関して
　xbrlファイルを解析する。すでにPythonに解析用のライブラリがあるそうなのでまずそれを使ってみる。

コンテナで環境を用意する。以下のコマンドを実行する。

```bash
docker compose up -d --build
```
 
　パーサーは以下。

- [arelle®](https://arelle.org/arelle/)

使い方は以下がざっくりと示してくれている。

- [XBRLタクソノミの表示リンクをOSSのArrele APIを使ってたどってみよう - Qiita](https://qiita.com/XBRLJapan/items/856cd4504b316f18b8b5)

とりあえずできることから始める。

xbrlファイルが不足している可能性があるので改めてダウンロードする。とりあえず代表として"トヨタ"と検索して一番上にきたものをダウンロードして配置する。

- [【Pythonで財務分析】XBRL解析のためにArelleをインストール｜ジコログ](https://self-development.info/%E3%80%90python%E3%81%A7%E8%B2%A1%E5%8B%99%E5%88%86%E6%9E%90%E3%80%91xbrl%E8%A7%A3%E6%9E%90%E3%81%AE%E3%81%9F%E3%82%81%E3%81%ABarelle%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB/)
- [XBRLタクソノミの表示リンクをOSSのArrele APIを使ってたどってみよう - Qiita](https://qiita.com/XBRLJapan/items/856cd4504b316f18b8b5)

まず、上記を参考にコードを書く。

疑問点がある。

- `logFileName='logToPrint'`とは何？`Cntlr.Cntlr(logFileName='logToPrint')`のところ。

とりあえず調べる。

- [Arelle/Cntlr.py at master · Arelle/Arelle · GitHub](https://github.com/Arelle/Arelle/blob/master/arelle/Cntlr.py)

Pythonの文法があまりわかっていないのでもう少し詳しく学ぶ。