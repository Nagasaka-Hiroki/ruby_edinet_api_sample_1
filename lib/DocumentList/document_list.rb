require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'csv'

module DocumentList
    #ファイルバスを計算する
    def edinet_code_list_file_path
        #エディネットコードが記述されているファイルのパスを記述する。
        repository_dir_path+"/code_list/EdinetcodeDlInfo.csv"
    end

    #書類一覧API　JSONからHashに変換
    #show_document_list
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

    #エディネットコードを特定する。
    #find_edinet_code
    def find_edinet_code(name=nil)
        #コードと提出者の対応をとったハッシュを取得する。
        edinet_code_list=edinetcode_and_name_relationship(edinet_code_list_file_path)
    end

    #欲しい会社名のデータを見る。
    #探索期間は指定なしの場合実行時から一年前を範囲とする。
    def serch_data(name, period=Range.new(Date.today << 12, Date.today))
        #引数をもとにデータを取得し目的のデータを探す。
        #会社情報を見るためtype=2となる。
        data=show_document_list_in_range(period,2)

        #dataの中からほしいデータがあるか探す。
        #必要なのは日付（どれが最新か？）、会社名、書類管理番号である。これらを取り出していく。
        essence_data_list = data.map do |data_list|
            next if data_list[:metadata][:status]!="200" #取得に成功していなければ次へ。
            #いつ提出されたか知るために日付を取り出す。
            metadata_date=data_list[:metadata][:parameter][:date] #日付
            #書類管理IDがあればapiから書類を入手できるはずなので、docIDがnilかどうかを見る。
            result = data_list[:results].map do |res| #データ本体
                next unless res[:docID] #nilなら処理をしない
                next unless res[:filerName] #企業名が空白なら処理しない
                {docID: res[:docID], filerName: res[:filerName]}
            end
            #結果をまとめて返す。
            [metadata_date, result]
        end
    end

    private
    #エディネットのEDINETコードと提出者名の対応を取る。
    #EDINETコードは1列目、提出者名は7列目
    #csvファイルの2行目まではヘッダになっている。2行目がcsvのヘッダ。
    def edinetcode_and_name_relationship(file_path=nil)
        code_list=read_edinet_code_list(file_path)#一覧を取得する。
        code_list.slice!(0,1)                     #説明を取り除く。
        header=code_list.slice!(0,1)[0].parse_csv #ヘッダを取り出し、取り除く。
        #配列をCSV::Tableオブジェクトに変換する。
        csv_table=CSV::Table.new(code_list.map { |row| CSV::Row.new(header,row.parse_csv) })
        csv_table.by_col!              #カラムモードに変換する。
        table_header=csv_table.headers #ヘッダーを取り出す。
        table_header.each_index do |i| #ヘッダーの番号で繰り返す。
            next if i==0 || i==6       #列番号1と7のみ使うため除外しない。
            csv_table.delete_if { |col_name, val| col_name==table_header[i]} #指定の番号の列を削除する。
        end
        #EDINETコードを0、提出者名を1として配列にし、それをハッシュに変換する。
        csv_table.to_a.map { |record| [record[0].to_sym, record[1].to_sym] }.to_h #ハッシュに変換して返す。
    end
    #エディネットコードの一覧を取得する。
    def read_edinet_code_list(file_path=nil)
        File.open(file_path) do |f|
            f.readlines.map  do |line|
                line.encode(Encoding::UTF_8,Encoding::Windows_31J)
            end
        end
    end
    #リポジトリの絶対パスを計算する。
    def repository_dir_path
        File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))
    end
end