#csvファイルを読み込むテスト
require 'minitest/autorun'
require 'debug'
require_relative '../lib/EdinetDocument/list_viewer'
include EdinetDocument::ListViewer

#エディネットコードの検索をテストする。
class DocumentListTest < Minitest::Test
    def test_find_edinet_code
        #引数の文字列を含む行を表示する。
        pp find_edinet_code_candidate("トヨタ")
    end
end