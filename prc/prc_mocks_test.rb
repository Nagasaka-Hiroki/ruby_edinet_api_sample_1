#参考は以下。
#https://www.rubydoc.info/gems/minitest#label-Mocks

require 'minitest/autorun'

#テスト対象
class MemeAsker #memeは噂という意味らしい
    def initialize(meme)
        @meme = meme #モックを仕込む場所
    end

    def ask(question)
        method=question.tr(' ','_')+"?"
        @meme.__send__(method)
    end

    def will_it_blend?
        false
    end
end

class MemeAskerTest < Minitest::Test
    def test_meme_ask
        #モックを作る
        @meme=Minitest::Mock.new #テスト対象からの出力を受ける（Mockの定義)
        #モックを初期化に使ったMemeAskerクラスのインスタンス
        @meme_asker=MemeAsker.new @meme
        
        #モックを使って呼び出す。
        p @meme.expect :will_it_blend?, :return_value #期待する動作を記述する
        p @meme_asker.ask "will it blend" #テスト対象のメソッドを起動しmockを動かす
        p @meme.verify #きちんとモックが動いたか確認する。
    end
end