---@class Game.Progress
---@field Music Game.Progress.Music
---@field SpellCards Game.Progress.SpellCards
---@field Story Game.Progress.Story
local M = {}

------------------------------------------------------------------------------------------------------------------

---@alias Game.Progress.EventListener.Type
---| '"music_unlock"'

---@class Game.Progress.EventListener
---@field id string
---@field type Game.Progress.EventListener.Type
---@field callback fun(args:any)

---@type Game.Progress.EventListener[]
local listeners = {}

---@param id string
---@param event_type Game.Progress.EventListener.Type
---@param callback fun(args:any)
function M.AddEventListener(id, event_type, callback)
    assert(type(id) == "string" and id:len() > 0)
    assert(type(callback) == "function")
    M.RemoveEventListener(id)
    table.insert(listeners, {
        id = id,
        type = event_type,
        callback = callback,
    } --[[@as Game.Progress.EventListener]])
end

function M.RemoveEventListener(id)
    assert(type(id) == "string" and id:len() > 0)
    for i = #listeners, 1, -1 do
        if listeners[i].id == id then
            table.remove(listeners, i)
        end
    end
end

---@param event_type Game.Progress.EventListener.Type
---@param args any
local function dispatchEvent(event_type, args)
    for _, l in ipairs(listeners) do
        if l.type == event_type then
            l.callback(args)
        end
    end
end

------------------------------------------------------------------------------------------------------------------
--- Music handler

---@class Game.Progress.Music
local music = {}

---@class Game.Progress.Music.MusicUnlockEventParameters
---@field name string

---@return table<string, boolean>
local function getMusicUnlockTable()
    local t = ScoreData.Music_Unlock
    if t then
        return t
    else
        t = {}
        ScoreData.Music_Unlock = t
        return t
    end
end

local function isPracticeOrReplay()
    if lstg.var and lstg.var.is_practice then
        return true
    end
    return false -- TODO: REPLACE WITH ext.replay.IsReplay()
end

local function isMenuOrStage()
    return (StageSystem.current_stage and StageSystem.current_stage.is_menu)
        or (not isPracticeOrReplay())
end

---@param name string
---@param force boolean?
function music.Unlock(name, force)
    if isMenuOrStage() or (force) then
        local t = getMusicUnlockTable()
        if not t[name] then
            ---@type Game.Progress.Music.MusicUnlockEventParameters
            local args = {
                name = name,
            }
            dispatchEvent("music_unlock", args)
        end
        t[name] = true
    end
end

---@param name string
---@return boolean
function music.IsUnlocked(name)
    local t = getMusicUnlockTable()
    return t[name]
end

Audio.AddMusicEventListener("Game.Progress.Music", "play", function(name)
    music.Unlock(name)
end)

M.Music = music

------------------------------------------------------------------------------------------------------------------
--- Spellcard handler

---@class Game.Progress.SpellCards
local spellcards = {}

---@alias Game.Progress.SpellCards.Database.SpellCardRecord table<string, number[]>

---@class Game.Progress.SpellCards.Database.PlayerRecord

local spellcard_database = nil