---Log values
LOG_DEBUG = 1
LOG_INFO = 2
LOG_WARNING = 3
LOG_ERROR = 4
LOG_FATAL = 5

---Logging wrapper
---@param level number
---@vararg string
function Log(level, ...)
    local arg = {...}
    for k, v in ipairs(arg) do
        arg[i] = tostring(v)
    end
    local msg = table.concat(arg, "\t")
    lstg.Log(level, msg)
end

function MessageBoxWarn(msg)
    local ret = lstg.MessageBox("Warning", tostring(msg), 1 + 48)
    if ret == 2 then
        lstg.quit_flag = true
    end
end

function MessageBoxError(msg, exit)
    local ret = lstg.MessageBox("Error", tostring(msg), 0 + 16)
    if ret == 1 and exit then
        lstg.quit_flag = true
    end
end