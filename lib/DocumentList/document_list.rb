require 'net/http'
require 'uri'
require 'json'
require 'date'

module DocumentList
    #show_document_list
    #書類一覧API　JSONからHashに変換
    #第一引数：日時
    #第二引数：取得情報（1 or 空白でメタデータ、2で書類一覧とメタデータ）
    def show_document_list(date, type=nil)
        #URLの末尾を作成する
        data_type= ((type && "&type=#{type}") || "").to_s # type ? "&type=#{type}" : "" と同義
        url="https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date=#{date}"+data_type
        #データを取得する。
        list=Net::HTTP.get(URI.parse(url))
        #jsonを解析する。今回のデータだとHashになる。
        JSON.parse(list, symbolize_names: true)
    end

    #探索区間を設定して反復して調べる。
    #show_document_list_in_range
    #第一引数：検索区間 class Range
    #第二引数：所得情報
    def show_document_list_in_range(search_period, type=nil)
        #ネットワークに接続して情報を取得
        #配列を返す。
        search_period.map do |date|
            show_document_list(date,type)
        end
    end

    #
end