#!/bin/bash
#
NAME=x-wool
LOG_HTM=/www/x-wool.htm

uci_get_by_name() {
    local ret=$(uci get $NAME.$1.$2 2>/dev/null)
    echo ${ret:=$3}
}

uci_get_by_type() {
    local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

cancel() {
    if [ $# -gt 0 ]; then
        echo "$1"
    fi
    exit 1
}

    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2/shell
    sed -n '/Version/p' git_pull.sh | while read linea
    do
    old=${linea#*Version： v}
    echo $old
    sed -n '/Version/p' git_pull.sh.sample | while read lineb
    do
    new=${lineb#*Version： v}
    echo $new
    if [ "$old" = "$new" ];then
    echo "未检测到更新"
    else
    echo "检测到新版本......"
	echo "......执行git_pull更换命令......"
	/usr/share/x-wool/newapp.sh -a
    fi
    done
    done






