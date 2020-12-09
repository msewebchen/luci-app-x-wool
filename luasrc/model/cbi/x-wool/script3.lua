local fs = require "nixio.fs"
local jd = "x-wool"
local conffile = "/www/x-wool-cron.htm"

log = SimpleForm("logview")
log.submit = false
log.reset = false

-- [[ 日志显示 ]]--
t = log:field(TextValue, "1", nil)
t.rmempty = true
t.rows = 30
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end
t.readonly="readonly"

return log