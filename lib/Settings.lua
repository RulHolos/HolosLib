Default_Settings = {
    UserName = "Player",
    Locale = "en_us",
    ResX = 1600,
    ResY = 900,
    Windowed = true,
    VSync = false,
    SEVolume = 25,
    BGMVolume = 40,
    Keybinds = {
        Up = KEY.UP,
		Down = KEY.DOWN,
		Left = KEY.LEFT,
		Right = KEY.RIGHT,
		Focus = KEY.SHIFT,
		Shoot = KEY.W,
		Spell = KEY.X,
		Special = KEY.C,
    },
    SystemKeybinds = {
		ReplayFast = KEY.CTRL,
		ReplaySlow = KEY.SHIFT,
		Menu = KEY.ESCAPE,
		Snapshot = KEY.HOME,
		Retry = KEY.R,
	}
}

---@param str string
---@return string
local function format_json(str)
	local ret = ''
	local indent = '	'
	local level = 0
	local in_string = false
	for i = 1, #str do
		local s = string.sub(str, i, i)
		if s == '{' and (not in_string) then
			level = level + 1
			ret = ret .. '{\n' .. string.rep(indent, level)
		elseif s == '}' and (not in_string) then
			level = level - 1
			ret = string.format(
				'%s\n%s}', ret, string.rep(indent, level))
		elseif s == '"' then
			in_string = not in_string
			ret = ret .. '"'
		elseif s == ':' and (not in_string) then
			ret = ret .. ': '
		elseif s == ',' and (not in_string) then
			ret = ret .. ',\n'
			ret = ret .. string.rep(indent, level)
		elseif s == '[' and (not in_string) then
			level = level + 1
			ret = ret .. '[\n' .. string.rep(indent, level)
		elseif s == ']' and (not in_string) then
			level = level - 1
			ret = string.format(
				'%s\n%s]', ret, string.rep(indent, level))
		else
			ret = ret .. s
		end
	end
	return ret
end

string.format_json = format_json

local function get_settings_file()
    return lstg.LocalUserData.GetRootDirectory() .. "/settings.json"
end

---Serializes a table(object) into json.
---@param str table The table to serialize into json.
function Serialize(obj)
    if type(obj) == 'table' then
        function visitTable(t)
            local ret = {}
            if getmetatable(t) and getmetatable(t).data then
                t = getmetatable(t).data
            end
            for k, v in pairs(t) do
                if type(v) == 'table' then
                    ret[k] = visitTable(v)
                else
                    ret[k] = v
                end
            end
            return ret
        end

        obj = visitTable(obj)
    end
    return cjson.encode(obj)
end

---Deserializes a string into a table(object).
---@param str string The string to deserialize.
function Deserialize(str)
    return cjson.decode(str)
end

function LoadSettings()
    local f, msg
    f, msg = io.open(get_settings_file(), 'r')
    if f == nil then
        settings = Default_Settings
    else
        settings = Deserialize(f:read('*a'))
        f:close()
    end
end

function SaveSettings()
    local f, msg
    f, msg = io.open(get_settings_file(), 'w')
    if f == nil then
        error(msg)
    else
        f:write(format_json(Serialize(settings)))
        f:close()
    end
end

LoadSettings()