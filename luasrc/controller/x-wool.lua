-- Copyright (C) 2020 jerrykuku <jerrykuku@gmail.com>
-- Licensed to the public under the GNU General Public License v3.
module("luci.controller.x-wool", package.seeall)
function index() 
    if not nixio.fs.access("/etc/config/x-wool") then 
        return 
    end
    
    entry({"admin", "services", "x-wool"}, alias("admin", "services", "x-wool", "client"), _("JD_DOCKER"), 10).dependent = true -- 首页
    entry({"admin", "services", "x-wool", "client"}, cbi("x-wool/client"),_("Client"), 10).leaf = true -- 基本设置
    entry({"admin", "services", "x-wool", "log"},form("x-wool/log"),_("Log"), 50).leaf = true -- 日志页面
    entry({"admin", "services", "x-wool", "script"},form("x-wool/script"),_("参数配置"), 20).leaf = true -- 直接配置脚本
	entry({"admin", "services", "x-wool", "script2"},form("x-wool/script2"),_("定时任务列表"), 30).leaf = true -- 直接配置脚本
	entry({"admin", "services", "x-wool", "script3"},form("x-wool/script3"),_("Docker任务列表"), 40).leaf = true -- 直接配置脚本
    entry({"admin", "services", "x-wool", "run"}, call("run")) -- 执行程序
    entry({"admin", "services", "x-wool", "update"}, call("update")) -- 执行更新
    entry({"admin", "services", "x-wool", "check_update"}, call("check_update")) -- 检查更新
end


-- 执行程序

function run()
	local up_code = luci.http.formvalue("good")
	if up_code == "up_code" then
		luci.sys.call("/usr/share/x-wool/newapp.sh -u &")
	elseif up_code == "up_server" then
        luci.sys.call("/usr/share/x-wool/newapp.sh -r &")
	elseif up_code == "cn_update" then
        luci.sys.call("/usr/share/x-wool/newapp.sh -n &")
	elseif up_code == "dy_run" then
        luci.sys.call("/usr/share/x-wool/newapp.sh -l &")
	elseif up_code == "up_scode" then
        luci.sys.call("/usr/share/x-wool/create_share_codes.sh &")
	elseif up_code == "up_pull" then
		luci.sys.call("/usr/share/x-wool/newapp.sh -a &")
	end
end
