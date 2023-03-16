#スタブをまとめる。
#スタブはブロックの間だけ関数を入れ替えるためブロックを引数として渡す関数を作る。

require 'minitest/autorun'
require 'date'
require 'json'
require_relative '../../lib/EdinetDocument/list_viewer'

module ListViewerStub
    #モジュールを組み込む
    include EdinetDocument::ListViewer
    #ListViewer.show_document_list のスタブ
    def stub_show_document_list(date,type=1,&block)
        EdinetDocument::ListViewer.stub :show_document_list, pseudo_show_document_list(date,type), &block
    end

    #ListViewer.show_document_list_in_range のスタブ
    def stub_show_document_list_in_range(period,type=1,&block)
        EdinetDocument::ListViewer.stub :show_document_list_in_range, pseudo_show_document_list_in_range(period,type), &block
    end

    private
    #ファイルを読み込んでjsonデータをRubyオブジェクトに変換する。
    #ファイルは http_dummyにlist_{日時}_{データの種類}.json　の形式で保存する。
    def pseudo_show_document_list(date,type=1)
        JSON.parse(
            File.open(File.dirname(File.dirname(File.dirname(
                File.expand_path(__FILE__))))+"/http_dummy/list_#{date}_#{type}.json") do |f|
                    f.readlines
            end.join(), 
        symbolize_names: true)
    end

    #ファイルを連続して読み込んでいく。
    def pseudo_show_document_list_in_range(period,type=1)
        period.map do |date|
            EdinetDocument::ListViewer.stub :show_document_list, pseudo_show_document_list(date,type) do
                EdinetDocument::ListViewer.show_document_list(date,type)
            end
        end
    end
end