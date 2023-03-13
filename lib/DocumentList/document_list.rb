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

    #エディネットコードの候補を探す。
    #find_edinet_code
    def find_edinet_code_candidate(name=nil) #nameはstring
        #コードと提出者の対応をとったハッシュを取得する。
        #ファイルが大きいので再実行されないようにする。
        @edinet_code_list||=edinetcode_and_name_relationship(edinet_code_list_file_path)

        #引数に指定したワードに近いものをリストアップする。
        #パターンを作成する。
        pattern=Regexp.new(name)
        #返り値は配列。マッチしなければ空の配列が入る。
        matched_list=@edinet_code_list.find_all { |record| pattern.match(record[1].to_s) }
        matched_list.map do |ar|
            { edinetCode: ar[0].to_sym, filerName: ar[1].to_sym }
        end
    end

    #メタデータを取得して扱いやすく整形する。
    #探索期間は指定なしの場合実行時から一年前を範囲とする。
    def arrange_data(period=Range.new(Date.today << 12, Date.today))
        #引数をもとにデータを取得し目的のデータを探す。
        #会社情報を見るためtype=2となる。
        data=show_document_list_in_range(period,2)

        #dataの中からほしいデータがあるか探す。
        #必要なのは日付（どれが最新か？）、会社名、書類管理番号、EDINETコードである。これらを取り出していく。
        essense_data = data.map do |data_list|
            next if data_list[:metadata][:status]!="200" #取得に成功していなければ次へ。
            #いつ提出されたか知るために日付を取り出す。
            metadata_date=data_list[:metadata][:parameter][:date] #日付
            #書類管理IDがあればapiから書類を入手できるはずなので、docIDがnilかどうかを見る。
            result = data_list[:results].map do |res| #データ本体
                next unless res[:docID] #nilなら処理をしない
                next unless res[:filerName] #企業名が空白なら処理しない
                #有価証券報告書、四半期報告書、半期報告書のみを今回表示する。
                next unless res[:docTypeCode].to_i==120 || res[:docTypeCode].to_i==140 || res[:docTypeCode].to_i==160 
                { 
                  docID:          res[:docID].to_sym,         #書類管理番号
                  seqNumber:      res[:seqNumber],            #連番、ファイル日付ごとの連番
                  xbrlFlag:       res[:xbrlFlag].to_i,        #xbrl形式ファイルがあるか？(1ならある)
                  docTypeCode:    res[:docTypeCode].to_i,     #書類種別コード
                  docDescription: res[:docDescription],       #提出書類概要
                  submitDateTime: res[:submitDateTime],       #提出日時
                  filerName:      res[:filerName].to_sym,     #提出者名
                  edinetCode:     res[:edinetCode].to_sym     #提出者 EDINETコード
                }
            end
            #結果をまとめて返す。
            [metadata_date, result]
        end
        #nilを除外する。
        essense_data.each { |ar| ar[1].compact! }
    end

    #find_edinet_code_candidateとarrange_dataをもとに書類管理番号を取得する。
    #別に一つである必要は無いが、一つに対する機能にして繰り返しをして複数に対応する。
    def search_data(name=nil, period=nil)
        #書類一覧APIでperiodの区間のデータを取得する。
        data_list=arrange_data(period)
        #調べたい企業名or提出者名を指定してEDINETコードの候補を出す。
        edinet_code_list=find_edinet_code_candidate(name)
        #EDINETコードの候補からメタデータを絞り込む。
        data_list.map do |data|
            matched_list=edinet_code_list.map do |code|
                data[1].find_all do |res|
                    res[:edinetCode]==code[:edinetCode]
                end
            end
            matched_list.delete([]).flatten!
            [data[0], matched_list]
        end
    end

    #search_dataを使って書類管理医番号と書類概要、書類種別、提出者名などをEDINETコードを主体として整理する。
    def arrange_search_data(name=nil, period=nil)
        #絞り込んだデータを取得する。
        searched_data=search_data(name, period)
        #エディネットコードのリストを取得する。
        edinet_code_list=searched_data.map do |x| #u[0] はクエリの日付が入っている。
            x[1].map do |y|
                y.map do |z|
                    z[:edinetCode]
                end
            end
        end.flatten.uniq
        #EDINETコードをキーとしてその他のデータを整理したハッシュを作成する。
        searched_data=edinet_code_list.map do |edinet_code|
            document_info=searched_data.map do |x|
                x[1].map do |y|
                    y.find_all do |z|
                        z[:edinetCode]==edinet_code
                    end
                end
            end.flatten.delete_if { |ar| ar.empty? }
            [edinet_code, document_info]
        end.to_h
        #ハッシュを整理する。arrange_dataでも整理したが、ここではより小さくする。
        edinet_code_list.map do |edinet_code|
            #書類取得APIで使用するdocIDと、提出日、提出者、書類概要、書類種別を整理する。
            res=searched_data[edinet_code].map do |doc_data|
                next unless doc_data[:xbrlFlag]==1 #XBRLファイルがない場合取得しないので除外。
                doc_type_name=if doc_data[:docTypeCode]==120
                                  "有価証券報告書"
                              elsif doc_data[:docTypeCode]==140
                                  "四半期報告書"
                              elsif doc_data[:docTypeCode]==160
                                  "半期報告書"
                              else
                                  "その他"
                              end
                {
                    docDescription: doc_data[:docDescription], #書類概要
                    docTypeName:    doc_type_name,             #書類種別
                    docID:          doc_data[:docID],          #書類管理番号
                }
            end
            [ [edinet_code.to_sym,@edinet_code_list[edinet_code]], res ]
        end
    end

    #書類一覧APIの結果を見やすく整理する。
    def show_doc_info_table(name=nil, period=nil)
        table_data=arrange_search_data(name,period)
        #|EDINET_CODE|filerName|docDescription|docTypeName|docID| の順で表示する。
        
        table_data.each do |ar|
            puts "|提出者：#{ar[0][1]}(#{ar[0][0]})|"
            puts "|-------------------------------------"
            puts "|書類概要|書類種別|書類ID|"
            ar[1].each do |x|
                puts "|#{x[:docDescription]}|#{x[:docTypeName]}|#{x[:docID]}|"
            end
            puts ""
        end
    end
    
    private
    #エディネットのEDINETコードと提出者名の対応を取る。
    #EDINETコードは1列目、提出者名は7列目
    #csvファイルの2行目まではヘッダになっている。2行目がcsvのヘッダ。
    #比較的重いので頻繁に実行しない。nilガードで代入を防ぐなどで減らす。
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