#stub_show_document_list_test.rb をモジュールでまとめたものに置き換える。

require 'minitest/autorun'
require 'date'
require 'json'
require_relative '../lib/DocumentList/document_list'
require_relative './DocumentListStub/stub_show_document_list'
include DocumentList
include DocumentListStub

class DocumentListTest < Minitest::Test
    #スタブでメソッドを呼び出す。
    def test_show_document_list
        #ドキュメントを参考に以下を選択
        date="2019-04-01"
        #DocumentListStubのスタブを使う。
        stub_show_document_list(date) do
            @list=DocumentList.show_document_list(date)
        end
        pp @list #時間に依存する箇所があるのでここは目視で確認する。
    end

    #入れ子状態のメソッドのスタブ
    def test_show_document_list_in_range
        #事前にhttp_dummy/get_data_list.shを実行する。
        #日時の範囲を指定する。5日間のデータを対象にする。
        period=Range.new(Date.new(2019,4,1),Date.new(2019,4,5))
        #DocumentListStubのスタブを使う。
        stub_show_document_list_in_range(period) do
            @list=DocumentList.show_document_list_in_range(period)
        end
        pp @list #時間に依存する箇所があるのでここは目視で確認する。
    end
end
