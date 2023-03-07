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

また、上記で`S100Q6YW`をダウンロードしたが必要なデータが入っていないように見える。そのため書類一覧APIで中身が見れないか調べるのをやってみる。

## Rubyから
　上記まででおおよその操作の感覚はわかったのでRubyから操作してみる。しかし今回はWebからデータを取得するためテストなどで頻繁にアクセスすることは望ましくない。そのためRubyのMinitestの機能であるモックとスタブを使って見る。以下に示す。

- [ Mocks｜File: README — Documentation for minitest (5.18.0) ](https://www.rubydoc.info/gems/minitest#label-Mocks)

　スタブとモックについては以下が参考になったためリンクを示す。

- [[図解]スタブとモックの違い - Qiita](https://qiita.com/hirohero/items/3ab63a1cdbe32bbeadf1)
- [スタブとモックの違い - Qiita](https://qiita.com/k5trismegistus/items/10ce381d29ab62ca0ea6)

　上記の解説の内容からスタブを使うとネットワークに接続する部分のテストを偽物にすり替えることができるはずだ。また、逆にモックを使うことでネットワークに接続する部分をテストし適切な出力が得られるか検証することができるはずだ。しかしこの認識だとスタブは問題ないが、モックがアサーションと意味がかぶると考えられる。そのため作りながら認識を改めて行きたい。

### 書類一覧API
　第一歩として書類一覧APIを実装し情報がほしい企業の書類の番号を探す作業をしてみる。

はじめに書類一覧APIをRubyから実装する。形式はCLIとして実装する。

動作を確認するために使った以下の挙動をRubyから動かしていく。

```bash
$ curl "https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=2019-04-01"
{
  "metadata": {
    "title": "提出された書類を把握するためのAPI",
    "parameter": {
      "date": "2019-04-01",
      "type": "1"
    },
    "resultset": {
      "count": 511
    },
    "processDateTime": "2023-03-06 00:00",
    "status": "200",
    "message": "OK"
  }
```

上記の通りデータはjsonで入力されるためjsonからhashに変換する。

まずはirbで確認。以下を実行。

```ruby
irb(main):002:0> require 'net/http'
=> true
irb(main):003:0> require 'uri'
=> false
irb(main):006:0> Net::HTTP.get(URI.parse("https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=2019-04-01"))
=> "{\r\n  \"metadata\": {\r\n    \"title\": \"\xE6\x8F\x90\xE5\x87\xBA\xE3\x81\x95\xE3\x82\x8C\xE3\x81\x9F\xE6\x9B\xB8\xE9\xA1\x9E\xE3\x82\x92\xE6\x8A\x8A\xE6\x8F\xA1\xE3\x81\x99\xE3\x82\x8B\xE3\x81\x9F\xE3\x82\x81\xE3\x81\xAEAPI\",\r\n    \"parameter\": {\r\n      \"date\": \"2019-04-01\",\r\n      \"type\": \"1\"\r\n    },\r\n    \"resultset\": {\r\n      \"count\": 511\r\n    },\r\n    \"processDateTime\": \"2023-03-06 00:00\",\r\n    \"status\": \"200\",\r\n    \"message\": \"OK\"\r\n  }\r\n}"
irb(main):007:0> Net::HTTP.get(URI.parse("https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=
2019-04-01")).encoding
=> #<Encoding:ASCII-8BIT>
# str=Net::HTTP.get(URI.parse("https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=2019-04-01"))
irb(main):020:0> str.force_encoding(Encoding::UTF_8)
=> "{\r\n  \"metadata\": {\r\n    \"title\": \"提出された書類を把握するためのAPI\",\r\n    \"parameter\": {\r\n      \"date\": \"2019-04-01\",\r\n      \"type\": \"1\"\r\n    },\r\n    \"resultset\": {\r\n      \"count\": 511\r\n    },\r\n    \"processDateTime\": \"2023-03-06 00:00\",\r\n    \"status\": \"200\",\r\n    \"message\": \"OK\"\r\n  }\r\n}"
```

force_encodingとencodeの違いは正確にわからないが、とりあえずencodeの場合例外が発生する。

```ruby
irb(main):019:0> str.encode(Encoding::UTF_8)
(irb):19:in `encode': "\xE6" from ASCII-8BIT to UTF-8 (Encoding::UndefinedConversionError)
        from (irb):19:in `<main>'                                           
        from /home/hiroki/.rbenv/versions/3.1.3/lib/ruby/gems/3.1.0/gems/irb-1.4.1/exe/irb:11:in `<top (required)>'                                                                  
        from /home/hiroki/.rbenv/versions/3.1.3/bin/irb:25:in `load'        
        from /home/hiroki/.rbenv/versions/3.1.3/bin/irb:25:in `<main>'      
```

そのため今はforce_encodingを使う。

一度書いたコードをirbで確認する。

```ruby
require 'net/http'
require 'uri'
require 'json'

module DocumentList
    def show_document_list(search_period,type=nil)
        url="https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=#{search_period}"
        list=Net::HTTP.get(URI.parse(url))
        JSON.parse(list, symbolize_names: true)
    end
end

irb(main):014:0> include DocumentList
=> Object
irb(main):016:0> show_document_list("2019-04-01")
=> 
{:metadata=>                                                   
  {:title=>"提出された書類を把握するためのAPI",                
   :parameter=>{:date=>"2019-04-01", :type=>"1"},              
   :resultset=>{:count=>511},                                  
   :processDateTime=>"2023-03-07 00:04",                       
   :status=>"200",                          
   :message=>"OK"}}  
```

これでjsonデータをハッシュに変換できた。

---
Minitest::Mockの使い方を確認する。

- [ File: README — Documentation for minitest (5.18.0) ](https://www.rubydoc.info/gems/minitest#label-Mocks)
- [ Class: Minitest::Mock — Documentation for minitest (5.18.0) ](https://www.rubydoc.info/gems/minitest/Minitest/Mock#expect-instance_method)
- [BasicObject#\_\_send\_\_ (Ruby 3.2 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/method/BasicObject/i/__send__.html)

まずサンプルを自分がよく使う形式で書いて試してみる。

- [PHPUnitでスタブとモックを理解する！【テストダブル】](https://zenn.dev/shun57/articles/1fd956346c4381)
- [Mockito入門 ~モックとスタブ~ - Crieit](https://crieit.net/posts/Mockito)

スタブとモックについては以下。

- [TestDouble](https://www.martinfowler.com/bliki/TestDouble.html)

|原文(上記URLより引用)|訳|
|-|-|
|Stubs provide canned answers to calls made during the test, usually not responding at all to anything outside what's programmed in for the test.|スタブは、テスト中の呼び出しに対して定型的な回答を提供し、通常、テスト用にプログラムされた以外のものには全く反応しません。|
|Mocks are pre-programmed with expectations which form a specification of the calls they are expected to receive. They can throw an exception if they receive a call they don't expect and are checked during verification to ensure they got all the calls they were expecting.|モックは、あらかじめ期待値がプログラムされており、期待される呼び出しの仕様を形成しています。モックは、期待しない呼び出しがあった場合に例外を投げることができ、検証時には、期待する呼び出しがすべてあったことを確認するためにチェックされます。|

上記の内容は少し前の参考の図とは少し違う気がする。しかしMinitestのリファレンスについているドキュメントなのでこの内容のほうが信頼できる。そのため以下に自分の理解をまとめる。

|項目|説明|
|-|-|
|スタブ|入力と出力を一対一に定め、それ以外は何もしないもの。|
|モック|スタブに似ている。しかし呼び出し方についても検証でき、<br>期待する呼び出しがすべてあったかも確認できる。|

つまり、スタブは以下のリンクに示すように代用品ということ。スタブによって欲する出力をテスト対象に流して動作させる。それによって依存性を下げることができる。そのため主な用途としてはテスト対象に対する出力として使われる。

- [スタブ【stub】](https://e-words.jp/w/%E3%82%B9%E3%82%BF%E3%83%96.html)

モックは模造品という意味。意味的にはスタブに近い。モックはスタブの機能、つまり期待値を先にプログラムし期待される呼び出しに対する応答、仕様を定義している。そしてモックは呼び出しが正しくされたか検証する機能を有している。そのため主な用途としてはテスト対象が正しく呼び出されるかどうかを検証することに使われる。

- [モックアップ【mock-up】モック / mock](https://e-words.jp/w/%E3%83%A2%E3%83%83%E3%82%AF%E3%82%A2%E3%83%83%E3%83%97.html)

おおよそ上記のとおりだと思われる。

少し細かくまとめる。

```
#2つのモジュールで構成されるプログラムの完成形として以下を考える。 '→'は出力を表す。
module A →　module B →　結果
#最終的な結果を得るためにA, Bのモジュールを経由する。

#上記の構成のプログラムのうち、module Bのテストを考える。
#module Bはmodule Aの出力を受けて動作しする。
#そのためmodule Bはmodule Aに依存している。そのためmodule Bの正当性を判断するには、module Aの依存する部分を排除して考える必要がある。

#そこで以下を考える。
#module Bの処理内容テスト
stub A → module B →　結果

#module Bからの呼び出しテスト
Mock A → module B →　結果

#まずmodule Bの処理内容とmodule Aの出力は分けて考えることができる。なぜならmodule Aの出力内容を固定し、それが正しいことを約束すれば処理結果はmodule Bのみによって正当性が定まるからだ。そのためこの場合にはstubを使用する。
#次にmodule Bが他のモジュールを呼び出す場合、その呼び出し方が正しいか検証する必要がある。stubの場合にはmodule Bが受け取る内容のみに着目したが、mockの場合module Bがmodule Aを呼び出す方法も検証できる。また、すべて正しく呼び出されたかも検証できる。
```

少し長いがおおよそは上記の理解が現状。しかし、大いに間違っている可能性があるので注意すること。

下記に私の認識とほとんど同様のサイトがあったので記す。

- [スタブとモックの違い - Qiita](https://qiita.com/k5trismegistus/items/10ce381d29ab62ca0ea6#:~:text=%E3%82%B9%E3%82%BF%E3%83%96%E3%81%A8%E3%83%A2%E3%83%83%E3%82%AF%E3%81%AE%E6%9C%80%E5%A4%A7,%E3%81%84%E3%81%A3%E3%81%A6%E3%82%88%E3%81%84%E3%81%A7%E3%81%97%E3%82%87%E3%81%86%E3%80%82)

つまり、ざっくりまとめると。

1. スタブは、テスト対象本体の処理があっているか確かめるために使う。
1. モックは、テスト対象から呼び出されるメソッドの呼び出し方を検証するために使う。

という意味で、難しくはないはず。

---

探索区間はrangeが便利そう。以下参考。

- [class Range (Ruby 3.2 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/class/Range.html)

これで特定区間の検索ができるようになった。結果は配列にして返すように作る。

これで二つのスタブを作る準備ができた。スタブはメソッドをオーバーライドして作るそうなのでここからスタブ作成をしていく。

[ #stub ｜Class: Object — Documentation for minitest (5.18.0) ](https://www.rubydoc.info/gems/minitest/Object#stub-instance_method)

