#!/bin/bash
#開始日時
start=20190401
#終了日時
end=20190405
#入手するデータを切り替える
type=2

#データを指定した日時で取得する。
for((D=start; D<=end; D=$(date -d "${D} + 1days" +%Y%m%d))); do
    #年月月を取り出す。
    year=$( echo $D | sed -e "s/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1/g")
    month=$(echo $D | sed -e "s/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\2/g")
    day=$(  echo $D | sed -e "s/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\3/g")
    echo "\"https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date="$year-$month-$day"&type="$type"\"をダンロードします。"
    curl "https://disclosure.edinet-fsa.go.jp/api/v1/documents.json?date="$year-$month-$day"&type="$type > "./list_"$year-$month-$day"_"$type".json"
    sleep 10 #一定時間待つ。
done