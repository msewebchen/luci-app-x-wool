local jd = "x-wool"
local uci = luci.model.uci.cursor()
local sys = require "luci.sys"

m = Map(jd)
-- [[ 薅羊毛Docker版-基本设置 ]]--

s = m:section(TypedSection, "global",
              translate("Base Config"))
s.anonymous = true

o = s:option(DummyValue, "", "")
o.rawhtml = true
o.template = "x-wool/cookie_tools"

o =s:option(Value, "jd_dir", translate("项目存放目录"))
o.default = ""
o.rmempty = false
o.description = translate("<br/>目录结尾不要带'/'")

o= s:option(DynamicList, "cookiebkye", translate("cookies"))
o.rmempty = false
o.description = translate("<br/>Cookie的具体形式：pt_key=xxxxxxxxxx;pt_pin=xxxx; <br/>由上到下第一个为cookie1<br/>注：cookies不要带有空格")

o= s:option(DynamicList, "nc_sharecode", translate("东东农场互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_fruit 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "zddd_sharecode", translate("种豆得豆互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_plantBean 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "pet_sharecode", translate("东东萌宠互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_pet 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "ddgc_sharecode", translate("东东工厂互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_jdfactory 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "jxgc_sharecode", translate("京喜工厂互助码"))
o.rmempty = false
o.description = translate("<br/>请到脚本根目录下的: log/jd_dreamFactory 查看日志文件,可以找到你的助力码")

o= s:option(DynamicList, "diyhz", translate("定义git_pull脚本各项参数"))
o.rmempty = false
o.description = translate("<br/>自定义git_pull.sh各项参数<br/>比如：<br/>coinToBeans=1000<br/>coinToBeans=\"抽纸\"<br/>注意有带引号的就把引号（英文）也加上去<br/>参数内不能出现空格和特殊字符")

o= s:option(DynamicList, "pdcron", translate("屏蔽脚本"))
o.rmempty = false
o.description = translate("<br/>请输入需要屏蔽的脚本名称，如京东签到的脚本为：jd_bean_sign.sh")

o= s:option(DynamicList, "crondiy", translate("定义脚本执行时间"))
o.rmempty = false
o.description = translate("<br/>格式跟脚本格式一样，支持五位Cron<br/>注：该功能只是增加没有删除默认执行时间，配合上面的【屏蔽脚本】功能使用<br/>例：0 9 * * * /root/shell/jd_bean_change.sh")

o =s:option(Value, "beansignstop", translate("定义每日签到的延迟时间"))
o.default = "0"
o.rmempty = false
o.description = translate("<br/>默认每个签到接口并发无延迟，如需要依次进行每个接口，请自定义延迟时间，单位为毫秒，延迟作用于每个签到接口, 如填入延迟则切换顺序签到(耗时较长)")

o = s:option(Value, "useragent", translate("定义User-Agent"))
o.rmempty = true
o.description = translate("<br/>没啥可说的，需要就自己改")

o = s:option(Flag, "cron_enable", translate("自动更换计划任务"))
o.rmempty = false
o.description = translate("打开则会自动将crontab.list任务添加到系统计划任务中<br/>关闭此项【屏蔽脚本】、【定义脚本执行时间】功能会一同失效<br/>自动更新时间：57 2-23 * * * ")

o = s:option(Flag, "gitupdate_enable", translate("自动更换git_pull"))
o.rmempty = false
o.description = translate("自动更换git_pull.sh 时间为：53 2-23 * * * 只有git_pull脚本有更新才会进行替换<br/>关闭此项【自动更换计划任务】一同失效，需手动点击【更新脚本参数】才会进行替换，在自动更换计划任务功能开启的情况下")

o = s:option(Flag, "sc_update", translate("定时上传互助码"))
o.rmempty = false
o = s:option(Value, "sc_updatetime", translate("定时上传互助码时间"))
o.rmempty = true
o.description = translate("<br/>定时上传互助码时间，支持五位Cron（分时日月周）其中 * 号请用 x 作为代替<br/>例：3 2 1,10,20 x x")

o = s:option(Flag, "sharecode_sc", translate("推送互助码上传状态"))
o.rmempty = false
o.description = translate("<br/>上传完成后会进行推送，看到success的字样代表上传成功（仅支持推动到 Server酱 或 Telegram）")

o = s:option(ListValue, "notify", translate("每日签到通知形式"))
o.default = 2
o.rmempty = false
o:value(0, translate("关闭通知"))
o:value(1, translate("简洁通知"))
o:value(2, translate("原始通知(默认)"))
o.description = translate("<br/>需要什么通知方式，在下面填写对应的通道参数即可，放空则不推送<br/>其余方式可使用【定义git_pull脚本各项参数】功能进行添加")

o = s:option(Value, "serverchan", translate("Server酱 SCKEY"))
o.rmempty = true
o.description = translate("<br/>微信推送，基于Server酱服务，请自行登录 http://sc.ftqq.com/ 绑定并获取 SCKEY (仅在自动签到时推送)")

o = s:option(Value, "tg_token", translate("TG_BOT_TOKEN"))
o = s:option(Value, "tg_id", translate("TG_USER_ID"))
o.rmempty = true
o.description = translate("<br/>Telegram 推送，如需使用，TG_BOT_TOKEN和TG_USER_ID必须同时赋值，教程：https://github.com/lxk0301/jd_scripts/blob/master/backUp/TG_PUSH.md")

o= s:option(DynamicList, "sdrun", translate("手动执行脚本列表"))
o.rmempty = false
o.description = translate("<br/>请输入需要执行的脚本名称，如京豆变动通知的脚本为：jd_bean_change.sh<br/>场景：当需要手动执行一个脚本的时候")

o = s:option(DummyValue, "", "")
o.rawhtml = true
o.template = "x-wool/update_service"

return m
