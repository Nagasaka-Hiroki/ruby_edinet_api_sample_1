require 'minitest/autorun'
require 'date'
require 'json'
require_relative '../lib/DocumentList/document_list'
include DocumentList

#事前にダウンロードした内容を返すように設定したスタブの動作を確認する。
class DocumentListTest < Minitest::Test
    #スタブでメソッドを呼び出す。
    def test_show_document_list
        date="2019-04-01"

        #show_document_list(date)       #本物 ネットワークを経由してデータを取得する。
        #pseudo_show_document_list(date)#偽物 ネットワークにつながらない。事前にダウンロードしたファイルから展開。

        #スタブでオーバーライドする。
        #本物の名前で偽物を呼び出せる。
        DocumentList.stub :show_document_list, pseudo_show_document_list(date) do
            @list=show_document_list(date)
        end
        assert_equal @list, show_document_list(date), "show_document_listが期待した動作と異なります。"
    end

    #入れ子状態のメソッドのスタブ
    def test_show_document_list_in_period
        #事前にhttp_dummy/get_data_list.shを実行する。
        #日時の範囲を指定する。5日間のデータを対象にする。
        period=Range.new(Date.new(2019,4,1),Date.new(2019,4,5))
        #スタブでオーバーライドする。
        DocumentList.stub :show_document_list_in_range, pseudo_show_document_list_in_range(period) do
            @list=show_document_list_in_range(period)
        end
        assert_equal @list, show_document_list_in_range(period), "show_document_list_in_rangeが期待した動作と違います。"
    end

    private
    #ファイルを読み込んでjsonデータをRubyオブジェクトに変換する。
    #ファイルは http_dummyにlist_{日時}_{データの種類}.json　の形式で保存する。
    def pseudo_show_document_list(date,type=1)
        JSON.parse(
            File.open(File.dirname(File.dirname(
                File.expand_path(__FILE__)))+"/http_dummy/list_#{date}_#{type}.json") do |f|
                    f.readlines
            end.join(), 
        symbolize_names: true)
    end

    #ファイルを連続して読み込んでいく。
    def pseudo_show_document_list_in_range(period,type=1)
        period.map do |date|
            DocumentList.stub :show_document_list, pseudo_show_document_list(date) do
                show_document_list(date)
            end
        end
    end
end