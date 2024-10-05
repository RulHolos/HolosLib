lstg.quit_flag = false

lstg.paused = false

lstg.var = {}

function lstg.SetGlobal(key, value)
    lstg.var[key] = value
end

function lstg.GetGlobal(key)
    return lstg.var[key] or nil
end