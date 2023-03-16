#共通の処理を切り出す。

module Common
    #リポジトリの絶対パスを計算する。
    def repository_dir_path
        File.dirname(File.dirname(File.expand_path(__FILE__)))
    end
    module_function :repository_dir_path
end