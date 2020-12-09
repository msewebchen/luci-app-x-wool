#!/bin/sh

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets"
export LC_ALL=C
NAME=x-wool
CRON_FILE=/etc/crontabs/root

uci_get_by_type() {
    local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

## 种豆得豆互助码
ShareCodesBean=$(uci_get_by_type global zddd_sharecode)
## 东东农场互助码
ShareCodesFarm=$(uci_get_by_type global nc_sharecode)
## 东东萌宠互助码
ShareCodesPet=$(uci_get_by_type global pet_sharecode)
## 东东工厂互助码
ShareCodesDDFactory=$(uci_get_by_type global ddgc_sharecode)
## 京喜工厂互助码
ShareCodesJXFactory=$(uci_get_by_type global jxgc_sharecode)

## 如果你希望在向服务器提交互助码后反馈提交结果，请补充ServerChan的SCKEY
## 教程：http://sc.ftqq.com/3.version
## 我懒，只做了ServerChan的通知渠道，其他不想做
SCKEY=$(uci_get_by_type global serverchan)
sharecode_sc=$(uci_get_by_type global sharecode_sc)

sc_update=$(uci_get_by_type global sc_update)
tg_token=$(uci_get_by_type global tg_token)
tg_id=$(uci_get_by_type global tg_id)
################################## 以下勿动 ##################################
## 路径
ShellDir=$(cd $(dirname $0); pwd)
RootDir=$(cd $(dirname $0); cd ..; pwd)
ScriptsDir=${RootDir}/scripts
LogDir=${RootDir}/log
LogFile=${LogDir}/create_share_codes/create_share_codes.log
CreateURLBean="http://api.turinglabs.net/api/v1/jd/bean/create/"
CreateURLFarm="http://api.turinglabs.net/api/v1/jd/farm/create/"
CreateURLPet="http://api.turinglabs.net/api/v1/jd/pet/create/"
CreateURLJXFactory="http://api.turinglabs.net/api/v1/jd/jxfactory/create/"
CreateURLDDFactory="http://api.turinglabs.net/api/v1/jd/ddfactory/create/"
URLServerChan="https://sc.ftqq.com/"

## 删除旧的日志，创建新的日志
if [ ! -d ${LogDir}/create_share_codes ]; then
  mkdir -p ${LogDir}/create_share_codes
fi
cd ${LogDir}/create_share_codes/
rm -f ${LogFile}
touch ${LogFile}
# 提交种豆得豆互助码
function CreateCodesBean {
  echo -e "种豆得豆：\n\n" >> ${LogFile}
  for Code in ${ShareCodesBean}
  do
    sleep 10
    wget -q -O ${Code} ${CreateURLBean}${Code}
    echo -n "${Code}: " >> ${LogFile}
    cat ${Code} >> ${LogFile}
    echo -e "\n\n" >> ${LogFile}
    rm -f ${Code}
  done
  echo -e "\n\n" >> ${LogFile}
}


## 提交东东农场互助码
function CreateCodesFarm {
  echo -e "东东农场：\n\n" >> ${LogFile}
  for Code in ${ShareCodesFarm}
  do
    sleep 10
    wget -q -O ${Code} ${CreateURLFarm}${Code}
    echo -n "${Code}: " >> ${LogFile}
    cat ${Code} >> ${LogFile}
    echo -e "\n\n" >> ${LogFile}
    rm -f ${Code}
  done
  echo -e "\n\n" >> ${LogFile}
}

## 提交东东萌宠互助码
function CreateCodesPet {
  echo -e "东东萌宠：\n\n" >> ${LogFile}
  for Code in ${ShareCodesPet}
  do
    sleep 10
    wget -q -O ${Code} ${CreateURLPet}${Code}
    echo -n "${Code}: " >> ${LogFile}
    cat ${Code} >> ${LogFile}
    echo -e "\n\n" >> ${LogFile}
    rm -f ${Code}
  done
  echo -e "\n\n" >> ${LogFile}
}

## 提交东东工厂互助码
function CreateCodesDDFactory {
  echo -e "东东工厂：\n\n" >> ${LogFile}
  for Code in ${ShareCodesDDFactory}
  do
    sleep 10
    wget -q -O ${Code} ${CreateURLDDFactory}${Code}
    echo -n "${Code}: " >> ${LogFile}
    cat ${Code} >> ${LogFile}
    echo -e "\n\n" >> ${LogFile}
    rm -f ${Code}
  done
  echo -e "\n\n" >> ${LogFile}
}

## 提交京喜工厂互助码
function CreateCodesJXFactory {
  echo -e "京喜工厂：\n\n" >> ${LogFile}
  for Code in ${ShareCodesJXFactory}
  do
    sleep 10
    wget -q -O ${Code} ${CreateURLJXFactory}${Code}
    echo -n "${Code}: " >> ${LogFile}
    cat ${Code} >> ${LogFile}
    echo -e "\n\n" >> ${LogFile}
    rm -f ${Code}
  done
  echo -e "\n\n" >> ${LogFile}
}
echo -e "互助码上传脚本正在执行" > /www/x-wool.htm
## 向服务器提交互助码
if [ -n "${ShareCodesBean}" ]; then
  CreateCodesBean
fi

if [ -n "${ShareCodesFarm}" ]; then
  CreateCodesFarm
fi

if [ -n "${ShareCodesPet}" ]; then
  CreateCodesPet
fi

if [ -n "${ShareCodesDDFactory}" ]; then
  CreateCodesDDFactory
fi

if [ -n "${ShareCodesJXFactory}" ]; then
  CreateCodesJXFactory
fi

## 向方糖发送消息
if [ $sharecode_sc -eq 1 ]; then
  if [ -n "${SCKEY}" ]; then
	desp=$(cat ${LogFile})
	wget -q --output-document=/dev/null --post-data="text=互助码提交状态&desp=${desp}" ${URLServerChan}${SCKEY}.send
  fi
fi
if [ $sharecode_sc -eq 1 ]; then
  if [ -n "${tg_token}" ]; then
	desp=$(cat ${LogFile})
	wget -q --output-document=/dev/null --post-data="text=${desp}" https://api.telegram.org/bot${tg_token}/sendMessage?chat_id=${tg_id}
  fi
fi

echo -e "互助码上传脚本执行完成" >> ${LogFile}

cat ${LogFile} >> /www/x-wool.htm
