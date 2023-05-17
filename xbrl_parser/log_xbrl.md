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


## 作業再開
　一時作業を中断していた。作業を再開する。

1. [2023年版EDINETタクソノミの公表について：金融庁](https://www.fsa.go.jp/search/20221108.html)

arelleとxbrlのファイルを読んだところ。arelle側にタグ（xbrl的にはタクソノミ）は定義されていないようだ。なので、タクソノミ一覧はEDINET側の仕様書を読み込むと出てくるかもしれない。

- [EDINET](https://disclosure2dl.edinet-fsa.go.jp/guide/static/disclosure/WZEK0110.html)

上記の中から以下を確認した。

1. タクソノミ要素リスト
1. 勘定科目リスト
1. 国際会計基準タクソノミ要素リスト

このリストを読むとブログに書かれていた`FilerNameInJapaneseDEI`があったので、これを参照すればいいと思う。

しかし、以下が不明。

```python
cntrl=Cntlr.Cntlr()
model_manager=ModelManager.initialize(cntrl)
model_xbrl=model_manager.load(filename)

for fact in model_xbrl.facts: #<ーここの部分
    print(fact.value)
```

タクソノミがわかったので、コードを読む。

1. [Arelle/ModelXbrl.py at 1f46df71ee985237b9297c31ad72cc9322a5e262 · Arelle/Arelle · GitHub](https://github.com/Arelle/Arelle/blob/1f46df71ee985237b9297c31ad72cc9322a5e262/arelle/ModelXbrl.py#L202)

ここにfactsが書いている。

factsの中身についてはリストになっていて、配列の要素は`ModelFact`クラスになっている。なので`value`で値を取り出せる。以下参照。

1. [Arelle/ModelInstanceObject.py at 1f46df71ee985237b9297c31ad72cc9322a5e262 · Arelle/Arelle · GitHub](https://github.com/Arelle/Arelle/blob/1f46df71ee985237b9297c31ad72cc9322a5e262/arelle/ModelInstanceObject.py#LL363C28-L363C28)

---

一度Python APIの公式ドキュメントを読んで整理した。以下に示す。
1. [ API, Python](https://arelle.org/arelle/documentation/api/)
1. [ruby_edinet_api_sample_1/check_python_api.md at topic_xbrl_parser · Nagasaka-Hiroki/ruby_edinet_api_sample_1 · GitHub](https://github.com/Nagasaka-Hiroki/ruby_edinet_api_sample_1/blob/topic_xbrl_parser/xbrl_parser/check_python_api.md)

読んだ感想として、どうやら`CntlrCmdLine.py`にサンプル的な内容が書かれているそうなのでそれを確認する。（独習Pythonも読んだが、`main`関数にモジュールなどのサンプルコードが書かれているそうなのでそこを重点的に読むといいかもしれない）

- [Arelle/CntlrCmdLine.py at master · Arelle/Arelle · GitHub](https://github.com/Arelle/Arelle/blob/master/arelle/CntlrCmdLine.py)

上記の`def main`のところがサンプルになっているはず。（→長いので要点を抑えることを意識して読まないとだめなのが注意点）

また、結局モデルマネージャーがキモになっていると思うのでそのクラスをしっかりと読む。これを次の目標とする（もちろん並行してEDINET側の仕様も確認する）
- [Arelle/ModelManager.py at master · Arelle/Arelle · GitHub](https://github.com/Arelle/Arelle/blob/master/arelle/ModelManager.py)

---