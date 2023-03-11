#DocumentList moduleのテスト
#事前にネットワークを使用するところはスタブ化し、ここではすべてスタブ化したものを使用する。

require 'minitest/autorun'
require 'date'
require 'json'
require 'debug'
require_relative '../lib/DocumentList/document_list'
require_relative './DocumentListStub/stub_show_document_list'
include DocumentList
include DocumentListStub #←stub_show_document_list と stub_show_document_list_in_period を定義

class DocumentListTest < Minitest::Test
    def test_serch_data
        #事前にhttp_dummy/get_data_list.shを実行する。
        #期間を５日間にしてテスト。
        period=Range.new(Date.new(2019,4,1),Date.new(2019,4,2))
        #スタブを使うのでブロック内に記述する。
        #search_data内ではtype=2となる。
        stub_show_document_list_in_period(period,2) do
            result = DocumentList.serch_data(nil,period)
            pp result
        end
    end
end