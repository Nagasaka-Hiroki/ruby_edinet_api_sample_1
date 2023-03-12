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
    def test_arrange_data
        #事前にhttp_dummy/get_data_list.shを実行する。
        #期間を2日間にしてテスト。
        period=Range.new(Date.new(2019,4,1),Date.new(2019,4,2))
        #スタブを使うのでブロック内に記述する。
        #search_data内ではtype=2となる。
        stub_show_document_list_in_range(period,2) do
            result = DocumentList.arrange_data(period)
            pp result
        end
    end

    def test_search_data
        #期間を2日間にしてテスト。
        period=Range.new(Date.new(2019,4,1),Date.new(2019,4,2))
        stub_show_document_list_in_range(period,2) do
            #binding.break
            result = DocumentList.search_data("三井",period)
            result.each do |x|
                puts "#{x[0]}"
                x[1].each do |y|
                    y.each do |z| #同一のedinetコードに対応する報告書は複数ある。
                        puts "#{z}"
                    end
                end
            end
        end
    end

    def test_arrange_search_data
        #期間を2日間にしてテスト。
        period=Range.new(Date.new(2019,4,1),Date.new(2019,4,2))
        stub_show_document_list_in_range(period,2) do
            pp DocumentList.arrange_search_data("三井",period)
        end
    end

    def test_show_doc_info_table
        #期間を2日間にしてテスト。
        period=Range.new(Date.new(2019,4,1),Date.new(2019,4,2))
        stub_show_document_list_in_range(period,2) do
            DocumentList.show_doc_info_table("三井",period)
        end
    end
end