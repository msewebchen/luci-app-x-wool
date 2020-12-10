#!/bin/bash
#
#本人比较懒，直接修改自 <jerrykuku@qq.com>的京东签到脚本，额，我更懒，改自ChongshengB之后的脚本
#

NAME=x-wool
TEMP_SCRIPT=/tmp/JD_DailyBonus.js
LOG_HTM=/www/x-wool.htm
usage() {
    cat <<-EOF
		Usage: app.sh [options]
		Valid options are:

		    -a                      B Run
			-c                      Runsh			
		    -n                      Check 
		    -r                      Run Script
		    -u                      Update Script From Server
		    -s                      Save Cookie And Add Cron
		    -w                      Background Run With Wechat Message
		    -h                      Help
EOF
    exit $1
}

# Common functions

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

# Run Script
run() {
	jd_dir2=$(uci_get_by_type global jd_dir)
	echo "初始化......" >$LOG_HTM 2>&1
	echo "删除宿主目录......" >>$LOG_HTM 2>&1
	rm -rf $jd_dir2
	echo "停止名为jd的容器......" >>$LOG_HTM 2>&1
	docker stop jd
    echo "删除名为jd的容器......" >>$LOG_HTM 2>&1
	docker rm jd
    echo "删除名为evinedeng/jd-base的镜像......（如果装有共存版，请手动删除镜像" >>$LOG_HTM 2>&1
	docker rmi evinedeng/jd-base
	echo "开始拉取镜像......" >>$LOG_HTM 2>&1
	echo "默认容器内存限制：512M" >>$LOG_HTM 2>&1
	echo "注：如果拉取失败请开启全局梯子" >>$LOG_HTM 2>&1
	docker run -dit -v $jd_dir2:/root --name jd -m 512m --hostname jd --restart always --network host evinedeng/jd-base:latest >>$LOG_HTM 2>&1
	echo "初始化完毕" >>$LOG_HTM 2>&1
}

b_run() {
#检测git_pull脚本
	jd_dir2=$(uci_get_by_type global jd_dir)
	[ ! -f "$jd_dir2/shell/git_pull.sh.sample" ] && echo "哼 你猜我现在怎么滴了" > $LOG_HTM && exit 1
	cd $jd_dir2/shell
    echo "复制git_pull.sh" >$LOG_HTM 2>&1
	cp -R git_pull.sh.sample git_pull.sh
    echo "启用日志清理脚本" >>$LOG_HTM 2>&1
	cp -R rm_log.sh.sample rm_log.sh
    if [ -f $jd_dir2/crontab.list ]
    then
    echo "已存在crontab.list无需替换" >>$LOG_HTM 2>&1
	else
    echo "复制crontab.list" >>$LOG_HTM 2>&1
	cp $jd_dir2/shell/crontab.list.sample $jd_dir2/crontab.list	
    fi
# 对脚本文件夹赋予可执行权限
	chmod -R 777 $jd_dir2
	echo "运行git_pull.sh" >>$LOG_HTM 2>&1
	docker exec -i jd bash /root/shell/git_pull.sh  >$LOG_HTM 2>&1
	up_code
}

#更新cookies
up_code() {
	jd_dir2=$(uci_get_by_type global jd_dir)
	sckey=$(uci_get_by_type global serverchan)
	stop=$(uci_get_by_type global beansignstop)
	ua=$(uci_get_by_type global useragent)
	notify=$(uci_get_by_type global notify)
	crondiyo=$(uci_get_by_type global crondiy)
	ua=$(uci_get_by_type global useragent)
	gitupdate_enable=$(uci_get_by_type global gitupdate_enable)
    tg_token=$(uci_get_by_type global tg_token)
	tg_id=$(uci_get_by_type global tg_id)
	sc_update=$(uci_get_by_type global sc_update)
	
	cd $jd_dir2/shell
	j=1
	for ck in $(uci_get_by_type global cookiebkye)
	do
	sed -i 's/^Cookie'$j'=.*$/Cookie'$j'=\"'$ck'"/g' git_pull.sh
	echo "写入cookies$j到git_pull.sh" >>$LOG_HTM 2>&1
	let j++
	done
	j=`expr $j - 1`
	sed -i "s/^UserSum=.*$/UserSum=$j/g" $jd_dir2/shell/git_pull.sh
	
	#设置推送方式
	sed -i 's/^SCKEY=.*$/SCKEY=\"'$sckey'"/g' $jd_dir2/shell/git_pull.sh
	sed -i 's/^TG_BOT_TOKEN=.*$/TG_BOT_TOKEN=\"'$tg_token'"/g' $jd_dir2/shell/git_pull.sh
	sed -i 's/^TG_USER_ID=.*$/TG_USER_ID=\"'$tg_id'"/g' $jd_dir2/shell/git_pull.sh
	chmod +x *.sh
	docker exec -i jd bash /root/shell/git_pull.sh >>$LOG_HTM 2>&1
	chmod -R 777 $jd_dir2
}

back_run() {
# 自动替换git_pull文件
    if [ $gitupdate_enable -eq 1 ]; then
	sed -i '/x-wool\/git_pull_update/d' /etc/crontabs/root
	echo "53 2-23 * * * /usr/share/x-wool/git_pull_update.sh" >>/etc/crontabs/root
	else
	sed -i '/x-wool\/git_pull_update/d' /etc/crontabs/root
	fi
# 定义每日签到的通知形式
	sed -i 's/^NotifyBeanSign=.*$/NotifyBeanSign=/g' $jd_dir2/shell/git_pull.sh
	sed -i 's/^NotifyBeanSign=.*$/NotifyBeanSign='$notify'/g' $jd_dir2/shell/git_pull.sh
# 自定义ua信息
    ua="${ua//\//\\/}"
	sed -i 's/^UserAgent=.*$/UserAgent=\"\"/g' $jd_dir2/shell/git_pull.sh
    sed -i "s/^UserAgent=.*$/UserAgent=\"$ua\"/g" $jd_dir2/shell/git_pull.sh
# 定义脚本各项参数
    for diyhz in $(uci_get_by_type global diyhz)
    do
    hh=${diyhz%=*}
    mm=${diyhz#*=}
    sed -i "s/^$hh=.*$/$hh=$mm/g" $jd_dir2/shell/git_pull.sh
    done
# 设置签到延迟时间
	sed -i 's/^BeanSignStop=.*$/BeanSignStop=/g' $jd_dir2/shell/git_pull.sh
	sed -i 's/^BeanSignStop=.*$/BeanSignStop='$stop'/g' $jd_dir2/shell/git_pull.sh
	chmod -R 777 $jd_dir2
    docker exec -i jd bash /root/shell/git_pull.sh >$LOG_HTM 2>&1
# 对脚本文件夹赋予可执行权限
	chmod -R 777 $jd_dir2
}

# 手动执行脚本
runsh() {
	jd_dir2=$(uci_get_by_type global jd_dir)
    for sh in $(uci_get_by_type global sdrun)
	do
    rm -rf $jd_dir2/shell/sdrun.sh
    echo 'bash /root/shell/'$sh''  >>$jd_dir2/shell/sdrun.sh
	echo "开始执行..." >$LOG_HTM 2>&1
    docker exec -i jd bash /root/shell/sdrun.sh
	echo "shell脚本更新完成-手动执行脚本" >$LOG_HTM 2>&1
	done
}

# 计划任务
kkk() {
	cron_enable=$(uci_get_by_type global cron_enable)
	sc_update=$(uci_get_by_type global sc_update)
    jd_dir2=$(uci_get_by_type global jd_dir)
	time=$(date "+%Y-%m-%d %H:%M:%S")
# 是否写入自定义脚本
    sed -i '/更新时间/d' $jd_dir2/crontab.list
	if [ $cron_enable -eq 1 ]; then
	cat $jd_dir2/crontab.list >$jd_dir2/crontabs.sample
# 注释脚本
    for pd in $(uci_get_by_type global pdcron)
    do
    sed -i '/'$pd'/ s/^/#/g' $jd_dir2/crontabs.sample
    done
# 定义脚本执行时间
    grep "list crondiy" /etc/config/x-wool >$jd_dir2/log/crondiy.log
    sed -i "s/\'//g" $jd_dir2/log/crondiy.log
    sed -i "s/list crondiy//g" $jd_dir2/log/crondiy.log
    sed -i 's/^[ \t]*//g' $jd_dir2/log/crondiy.log
	echo "# 以下是自定义执行列表" >>$jd_dir2/crontabs.sample
    cat $jd_dir2/log/crondiy.log >> $jd_dir2/crontabs.sample
    rm -rf $jd_dir2/log/crondiy.log
# 增加更新日期显示
	sed -i '/更新时间/d' $jd_dir2/crontab.list
	echo "# 更新时间：$time" >>$jd_dir2/crontabs.sample
	docker exec jd crontab /root/crontabs.sample
	docker exec -i jd cp /etc/crontabs/root /root/dockercrontabs.log
	sed -i '/x-wool\/newapp/d' /etc/crontabs/root
	echo "57 2-23 * * * sleep 34s; /usr/share/x-wool/newapp.sh -n" >>/etc/crontabs/root
    echo "shell脚本更新完成-计划任务更新" >>$LOG_HTM 2>&1
	cp $jd_dir2/dockercrontabs.log /www/x-wool-cron.htm
	rm -rf $jd_dir2/dockercrontabs.log
	else
	sed -i '/更新时间/d' $jd_dir2/crontab.list
	echo "# 更新时间：$time" >>$jd_dir2/crontab.list
	docker exec jd crontab /root/crontab.list
	docker exec -i jd cp /etc/crontabs/root /root/dockercrontabs.log
	cp $jd_dir2/dockercrontabs.log /www/x-wool-cron.htm
    echo "shell脚本更新完成-计划任务更新" >>$LOG_HTM 2>&1
	rm -rf $jd_dir2/dockercrontabs.log
	fi
# 创建互助码自动上传任务
    if [ $sc_update -eq 1 ]; then
	uptime=$(uci_get_by_type global sc_updatetime)
    uptime=${uptime//x/\*}
    sed -i '/x-wool\/create_share_codes/d' /etc/crontabs/root
	echo "$uptime /usr/share/x-wool/create_share_codes.sh" >>/etc/crontabs/root
    else
	sed -i '/x-wool\/create_share_codes/d' /etc/crontabs/root
	fi
}
while getopts ":alnruswh" arg; do
    case "$arg" in
    a)
        b_run
		up_code
		back_run
		kkk
        exit 0
        ;;
    l)
        runsh
        exit 0
        ;;
    n)
        kkk
        exit 0
        ;;
    r)
        run
		a_run
        exit 0
        ;;
    u)
        up_code
        exit 0
        ;;
    s)
        save
        exit 0
        ;;
    w)
        back_run
        exit 0
        ;;
    h)
        usage 0
        ;;
    esac
done
