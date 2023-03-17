require 'minitest/autorun'

require_relative '../lib/EdinetDocument/document_acquisition'

#ネットワークにつながる処理のため頻繁に実行しないこと。
class DocumentAcquisitionTest < Minitest::Test
    include EdinetDocument::DocumentAcquisition
    def test_downloads_path
        #ファイルをダウンロードするパスが正しいか確認する。
        #以下のテストはdocker
        assert_equal DOWNLOADS_PATH,
                     "/home/user01/ruby_edinet/zips", 
                     "パスが想定している値と異なります。コードまたは環境を確認してください。"
    end
    def test_make_download_dir
        #Linuxコマンドの挙動を確認する。
        assert make_download_dir
    end
    def test_get_document
        #書類を取得する。
        assert get_document("S100Q6YW")
    end
    def test_arrange_zip_dir
        #書類の取得、解凍、ディレクトリの移動を行う。
        arrange_zip_dir("S100FGXK")
    end
end