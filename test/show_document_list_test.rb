require 'minitest/autorun'
require 'date'
require_relative '../lib/EdinetDocument/list_viewer'
include EdinetDocument::ListViewer

#目視で確認。
#ネットワークに接続するので頻繁に実行しないこと。
class DocumentListTest < Minitest::Test
    def test_show_document_list
        pp show_document_list("2019-04-01")
        #pp show_document_list("2019-04-01",2)
    end

    def test_show_document_list_in_range
        #区間を繰り返しする。
        period=Range.new(Date.new(2019,4,1),Date.new(2019,4,2))
        pp show_document_list_in_range(period)
    end
end