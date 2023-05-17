# Arelle公式ドキュメントを読む。
　公式ドキュメントを一度しっかりと読む。訳に近いものを作るが、どちらかというと自分の言葉で言い換えた文章でまとめることに努める。

- [ API, Python](https://arelle.org/arelle/documentation/api/)

# 目次
1. モデルマネージャー
1. モデルマネージャーの初期化。
1. ファイルソース
1. 小数を推論する計算リンク検証の選択
1. 精度を推論する計算リンク検証の選択
1. 開示制度規則検証の有無の選択
1. 開示制度規則の選択
1. 検証操作で使用するユニット型レジストリの選択
1. ファイルソースのロード
1. エントリーポイントに適応される検証の実行
1. エントリーポイントを閉じる
1. バージョニングレポートの作成
1. 開発環境

# 本編
## 1.モデルマネージャー
　ArelleのPython APIを利用するためには、モデルマネージャーから利用する必要があるそうだ。
モデルマネージャーを取り扱うためにはコントローラーが必要で、コントローラーはCntlr.pyのサブクラスとして定義されている。
コントローラーは`addToLog`と`showStatus`の２つのメソッドを持たなければならない。
CntlrCmdLine.pyは最小のAPIを試すために説明される。

## 2.モデルマネージャーの初期化。
　モデルマネージャーを初期化する。初期化には`addToLog`と`showStatus`の呼び出しに必要なインスタンス`(self)`を引数に渡す。

```python
modelManager = ModelManager.initialize(self)
```

## 3.ファイルソース
　対象となるファイルは、通常のファイルやアーカイブ化されたものである。アーカイブ化されたファイルとは例えば、zip、xfd、frm等を指している。ファイルが通常である場合、単純にファイルパスを指定すれば良い。アーカイブ化されたものであれば、`filesourse.select`メソッドで指定することができる。

例えば以下のように指定する。

```python
filesource = FileSource.FileSource(“c:\test\abc.xsd”)
```

## 4.小数を推論する計算リンク検証の選択
　検証操作によって実行される、小数を推論する計算リンクの検証を選択できる。
<br>
（参考：[https://qiita.com/XBRLJapan/items/81d965bb40b8170d9e7f](https://qiita.com/XBRLJapan/items/81d965bb40b8170d9e7f))

　以下で選択する。

```python
self.modelManager.validateInferDecimals
```

## 5.精度を推論する計算リンク検証の選択
　検証操作によって実行される、精度を推論する計算リンクの検証を選択できる。

以下で設定する。
```python
self.modelManager.validateInferPrecision
```

## 6.開示制度規則検証の有無の選択
　開示制度規則の検証が必要な場合、その検証をモデルマネージャーに通知するように設定することができる。エントリーポイントドキュメントを読み込む前に設定する必要があります。現在、Edgar Filing ManualとGlobal Filing Manualが実装されている。

以下で設定する。
```python
modelManager.validateDisclosureSystem = True
```

## 7.開示制度規則の選択
　開示制度規則を適切に選択する必要があります。例えば日本だと、FSAになります。選択するパラメータは`lib/disclosuresystems.xml`ファイル内の開示制度のどれかと一致する必要がある。
例えば、ファイルエントリの名前が、`Japan FSA`、`jp-fsa`、`fsa`のいづれかの場合、`Japan FSA`のルールを選択することを意味している。

　設定は以下で行う。

```python
modelManager.disclosureSystem.select(“efm”)
```

## 8.検証操作で使用するユニット型レジストリの選択
　検証操作で使用するユニット型レジストリの選択する。（現状内容がわかっていないが文面だけをまとめる。）

```python
self.modelManager.validateUtr
```

## 9.ファイルソースのロード
　ファイルソースで指定されたエントリーポイントをモデルマネージャーを使ってロードする。ロードに成功すれば第二引数で指定されたプロンプトがshowStatusのコールバックメソッドに表示される。

以下で実装する。

```python
modelManager.load(filesource, “subsequent action”)
```

## 10.エントリーポイントに適応される検証の実行
　エントリーポイントに適応される検証を実行する。エラーやその他のメッセージはaddToLogのコールバックメソッドに提供される。

以下で実行する。

```python
modelManager.validate()
```

## 11.エントリーポイントを閉じる
　最後に開いたエントリーポイントを閉じて、リソースを解放する。

```python
modelManager.close()
```

## 12.バージョニングレポートの作成
　2つのDTSを比較してバージョニングレポートを作成するには、`modelManager.validate()`ではなく、以下のメソッドに置き換えて実行する。

```python
modelManager.load(diffFilesource, _(“views loading”))
modelManager.compareDTSes(versioningReportFileName)
```

`modelManager.load`の引数について、１つ目は`fromDTS`を表し、２つ目は`toDTS`を表している。<br>
`modelManager.compareDTSes`の引数のファイル名は保存するレポートのファイル名を表している。

２つのエントリポイントがロードされるのでそれぞれについて`modelManager.close()`を呼び出す必要がある。
また、対応するロードされたエントリーを閉じるためにLIFO方式で動作することに注意しなければならない。

## 13.開発環境
　Pythonベースの優れた開発環境はたくさんある。多くのXBRLを取り扱う一はJavaを用いてきた。Javaを使ってきた一のためのArelleと互換性のあるPython(pydev)用に設定されたEclipseを利用することができる。

# まとめ終了
　とりあえず日本語に書き直したが一部正確に理解できてないところがある。その点に注意したい。その原因としてXBRLについての知識が不足していることが挙げられるため、少しづつその点を解決していきたいと思う。