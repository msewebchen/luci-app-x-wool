require "luci.model.uci"
local fs = require "nixio.fs"
local jd = "x-wool"

local uciType = 'servers'
local ucic = luci.model.uci.cursor()
local jd_dir = ucic:get_first(jd, 'global', 'jd_dir', '/opt/jd')

s = SimpleForm("scriptview")

view_cfg = s:field(TextValue, "conf")
view_cfg.rmempty = false
view_cfg.rows = 43

function sync_value_to_file(value, file)
    value = value:gsub("\r\n?", "\n")
    local old_value = fs.readfile(file)
    if value ~= old_value then fs.writefile(file, value) end
end

function view_cfg.cfgvalue()
    return fs.readfile(jd_dir .. "/shell/git_pull.sh") or ""
end
function view_cfg.write(self, section, value)
    sync_value_to_file(value, jd_dir .."/shell/git_pull.sh")
end

return s

