require 'net/http'
require 'uri'
require 'date'
require_relative '../common'

module EdinetDocument
    #書類取得APIで書類を取得する。
    module DocumentAcquisition
        #ダウンロードパスを取得する。
        DOWNLOADS_PATH="#{Common.repository_dir_path}/downloads"
        #書類取得APIのURLを記述する。
        GET_DOCUMENT_API="https://disclosure.edinet-fsa.go.jp/api/v1/documents/"

        #書類取得APIを実行して書類を取得する。
        def get_document(docID, type=1)
            #ディレクトリがあるか？無いなら作る。
            make_download_dir unless Dir.exist?(DOWNLOADS_PATH)
            #指定の書類管理IDのzipファイルがあるか確認する。
            return false if File.exist?(DOWNLOADS_PATH+"/#{docID}.zip") #存在するか確認。存在すればfalseとして返す。
            #動作状況を表示する。
            puts "[ファイルのダウンロードを開始します。-----------------------------------------]"
            #ファイルをダウンロードする。
            get_file(docID, type)
            #終了を通知する。
            puts "[ファイルのダウンローが完了しました。-----------------------------------------]"
        end
        #zipファイルを解凍して読めるようにする。ディレクトリの構造が深いのでそれを解消する。
        def arrange_zip_dir(docID)
            #この関数の前にzipファイルを入手する。
            #docID.zipがない場合取得する。
            get_document(docID) unless File.exist?("#{DOWNLOADS_PATH}/#{docID}.zip")
            #解凍がまだの場合は解答する。
            unzip_zipfile(docID) unless Dir.exist?("#{DOWNLOADS_PATH}/#{docID}")
            #ファイルの移動がされていない場合は移動する。
            move_file(docID) unless File.exist?("#{DOWNLOADS_PATH}/#{docID}-1.xbrl")
        end

        private
        #xbrlファイルの名前を取得する。
        def xbrl_file_name(path)
            pattern=%r{\.xbrl} #拡張子のパターンを記述。
            #ファイルの一覧を取得する。
            file_list=Dir.glob("#{path}/*")
            #xbrlの拡張子のファイルがあるか確認する。
            xbrl_files=file_list.map do |file_name| #xbrlファイルのリストを返す。
                file_name if pattern.match(file_name)
            end.compact
        end
        #linuxコマンドでファイルを動かす。
        def move_file(docID)
            #xbrlファイル名を取得する。
            origin_file_name=xbrl_file_name("#{DOWNLOADS_PATH}/#{docID}/XBRL/PublicDoc")
            #ファイルの名前を変更する。
            origin_file_name.each_index do |i|
                File.rename("#{origin_file_name[i]}",               #変更前
                            "#{DOWNLOADS_PATH}/#{docID}-#{i}.xbrl") #変更後
            end
        end
        #ファイルをapiで入手する。
        def get_file(docID,type=1)
            #urlを作る。
            url=GET_DOCUMENT_API+"#{docID}?type=#{type}"
            #linuxコマンドでzipファイルをダウンロードする
            system("curl #{url} --output #{DOWNLOADS_PATH}/#{docID}.zip") if type==1 #type=1はzipファイル
        end
        #zipファイルを取得したあとは解凍する。
        def unzip_zipfile(docID=nil)
            #unzipコマンドは.zipを短縮して実行できる。
            system("unzip #{DOWNLOADS_PATH}/#{docID} -d #{DOWNLOADS_PATH}/#{docID}")
        end
        #ディレクトリのセットアップ mkdirが実行できる環境で
        def make_download_dir
            system("mkdir -pv #{DOWNLOADS_PATH}")
        end
    end
end