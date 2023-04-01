# XBRLに関して
　XBRLに関しての基礎を確認し、ファイルを解析する準備をする。

## 下調べ
　まずざっくりとWebを検索する大きく以下が出る。

1. [EDINETのXBRL用のPythonライブラリを作った - Parser編 - Qiita](https://qiita.com/shoe116/items/dd362ad880f2b6baa96f)
1. [一般社団法人 XBRL Japan - XBRL Japan Inc. - ](https://www.xbrl.or.jp/)
1. [一般社団法人 XBRL Japan - XBRL Japan Inc. - XBRLプログラミング　お役立ちサイト集](https://www.xbrl.or.jp/modules/pico7/index.php?content_id=20)

調べるとすでにPythonでは解析用のライブラリがあるそうだ。ArelleというのがPythonにあるそうだ。

1. [【Python】Arelle のインストール方法【XBRL 読み込みライブラリ】｜シラベルノート](https://srbrnote.work/archives/5588)
1. [GitHub - Arelle/Arelle: Arelle open source XBRL platform](https://github.com/Arelle/Arelle)
1. [arelle®](https://arelle.org/arelle/)

またXBRL Japanというところがブログを書いているそうだ。

1. [XBRLJapan - Qiita](https://qiita.com/XBRLJapan)

基礎的な内容については以下。

1. [XBRLを知ろう(1/10) - Qiita](https://qiita.com/XBRLJapan/items/cd6af5bff5f6ae11d774)
1. [XBRLをもっと知ろう(9/10) - Qiita](https://qiita.com/XBRLJapan/items/81d965bb40b8170d9e7f)

とりあえず下調べは以上。PythonではすでにArelleがあるのでそれをまず使う。

## Arelleを使ってみる。
　まず、Pythonのコードを書いてxbrlをパースしてみる。(rubyにもあるが、少し古いので自分で書いてみるための前準備。またはPythonのコードを利用できないか考えるための準備。)

以前までにダウンロードしていたものの中から一つ選んでサンプルとして使う。`sample.xbrl`という名前で保存してそれをここでは使用していく。

Pythonの環境をコンテナとして用意する。以下のコマンドを使う。

```bash
docker compose up -d --build
```

コンテナはバインドマウントをしているのでこのディレクトリにファイルを作成して作業できる。

Pythonの練習として以下を読む。

- [Python チュートリアル — Python 3.11.2 ドキュメント](https://docs.python.org/ja/3/tutorial/index.html)

arelleは以下だと思われる。

- [arelle-release · PyPI](https://pypi.org/project/arelle-release/)
- [GitHub - Arelle/Arelle: Arelle open source XBRL platform](https://github.com/Arelle/Arelle)

古い？ものは次。

- [arelle · PyPI](https://pypi.org/project/arelle/)

上記については以下のブログで紹介されている。

- [ゼロから始めないXBRL解析(Arelleの活用) - Qiita](https://qiita.com/xtarou/items/fb3cc72b1b600b4309db)

少し古い記事なのでその影響かもしれない。

とりあえず[arelle-release · PyPI](https://pypi.org/project/arelle-release/)を使う。

Dockerfileを作り直して使えるようにする。

使い方などのドキュメントは以下を参照。
- [arelle®](https://arelle.org/arelle/)


