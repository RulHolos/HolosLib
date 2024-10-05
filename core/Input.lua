KeyState = {}
PreviousKeyState = {}

function GetInput()
    for k, v in pairs(Settings.Keybinds) do
        PreviousKeyState[k] = KeyState[k]
        KeyState[k] = GetKeyState(v)
    end
end

---@param key string
function IsKeyDown(key)
    return KeyState[key]
end

---@param key string
function IsKeyPressed(key)
    return KeyState[key] and (not PreviousKeyState[key])
end

function KeyCodeToName()
    local key2name = {}

    for k, v in pairs(lstg.Input.Keyboard or KEY) do
        if type(v) == "number" then
            key2name[v] = k
        end
    end

    for i = 0, 255 do
        key2name[i] = key2name[i] or string.format("0x%X", i)
    end
    return key2name
end