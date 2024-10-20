local cjson = require("cjson")

---@class Audio
---@field Singleton Audio.Singleton
local M = {}

---@alias Audio.MusicEventListener.Type
---| '"play"'

---@class Audio.MusicEventListener
---@field id string
---@field type Audio.MusicEventListener.Type
---@field callback fun(name:string)

---@type Audio.MusicEventListener[]
local listeners = {}

--- Register a music event listener to listen to events such as playback, which is used to unlock music rooms, achievements, etc.
---@param id string
---@param type_ Audio.MusicEventListener.Type
---@param callback fun(name:string)
function M.AddMusicEventListener(id, type_, callback)
    assert(type(id) == "string" and id:len() > 0)
    assert(type_ == "play")
    assert(type(callback) == "function")

    M.RemoveMusicEventListener(id)
    table.insert(listeners, {
        id = id,
        type = type_,
        callback = callback,
    }) --[[@as Audio.MusicEventListener]]
end

function M.RemoveMusicEventListener(id)
    assert(type(id) == "string" and id:len() > 0)

    for i = #listeners, 1, -1 do
        if listeners[i].id == id then
            table.remove(listeners, i)
        end
    end
end

---@param type Audio.MusicEventListener.Type
---@param name string
local function dispatchMusicEvent(type, name)
    for _, l in ipairs(listeners) do
        if l.type == type then
            l.callback(name)
        end
    end
end

---@class Audio.MusicLoopRange
---@field start_in_seconds number?
---@field end_in_seconds number?
---@field length_in_seconds number?
---@field start_in_samples number?
---@field end_in_samples number?
---@field length_in_samples number?

---@class Audio.MusicMetadata
---@field unlocked boolean?

---@class Audio.MusicAsset
---@field name string
---@field path string
---@field loop Audio.MusicLoopRange?
---@field metadata Audio.MusicMetadata?

---@type table<string, Audio.MusicAsset>
local music_resource_records = {}

---@param name string
---@param path string
---@param loop Audio.MusicLoopRange?
---@param metadata Audio.MusicMetadata?
function M.AddMusicAsset(name, path, loop, metadata)
    assert(type(name) == "string" and name:len() > 0)
    assert(type(path) == "string" and path:len() > 0)
    if loop then
        assert(type(loop) == "table")
    end

    ---@type Audio.MusicAsset
    local data = {
        name = name,
        path = path,
    }
    ---@type Audio.MusicLoopRange
    local loop_copy = {}
    if loop then
        for k, v in pairs(loop) do
            loop_copy[k] = v
        end
        data.loop = loop_copy
    end
    ---@type Audio.MusicMetadata
    local metadata_copy = {}
    if metadata then
        for k, v in pairs(metadata) do
            metadata_copy[k] = v
        end
        data.metadata = metadata_copy
    end
    music_resource_records[name] = data
end

function M.LoadMusicAssets()
    local music_assets_path = "resources/music/"
    local index_file_path = music_assets_path .. "index.json"
    local index_file_text = lstg.LoadTextFile(index_file_path)
    assert(type(index_file_text) == "string" and index_file_text:len() > 0, ("Failed to load music asset index file '%s'."):format(index_file_path))

    ---@type Audio.MusicAsset[]
    local index_json = cjson.decode(index_file_text)
    for _, v in ipairs(index_json) do
        assert(type(v.name) == "string" and v.name:len() > 0)
        assert(type(v.path) == "string" and v.path:len() > 0)
        M.AddMusicAsset(v.name, music_assets_path .. v.path, v.loop, v.metadata)
    end
end

function M.MusicAssetExists(name)
    local data = music_resource_records[name]
    if not data then
        return false
    end
    return lstg.FileManager.FileExist(data.path, true)
end

---@return Audio.MusicMetadata
function M.GetMusicAssetMeta(name)
    local data = assert(music_resource_records[name], ("Music resource '%s' is not found."):format(name))
    return data.metadata or {}
end

function M.LoadMusic(name)
    local data = assert(music_resource_records[name], ("Music resource '%s' is not found."):format(name))
    if not lstg.CheckRes(4, name) then
        lstg.LoadMusic(name, data.path, 0, 0)
        lstg.SetMusicLoopRange(name, data.loop)
    end
end

---@param name string
---@param volume number?
---@param position number?
function M.PlayMusic(name, volume, position)
    M.LoadMusic(name)
    lstg.PlayMusic(name, volume or 1.0, position or 0)
    dispatchMusicEvent("play", name)
end

--- Singleton

---@class Audio.Singleton
local S = {}

---@param callback fun(name: string)?
---@return string?
local function getStageSingletonBackgroundMusicName(callback)
    if type(lstg.var._core_audio_singleton_background_music_name) == "string" then
        if callback then
            callback(lstg.var._core_audio_singleton_background_music_name)
        end
        return lstg.var._core_audio_singleton_background_music_name
    else
        return nil
    end
end

local function setStageSingletonBackgroundMusicName(name)
    lstg.var._core_audio_singleton_background_music_name = name
end

---@param name string
---@param volume number?
---@param position number?
function S.PlayMusic(name, volume, position)
    S.StopMusic()
    M.PlayMusic(name, volume, position)
    setStageSingletonBackgroundMusicName(name)
end

function S.PauseMusic()
    getStageSingletonBackgroundMusicName(function(name)
        lstg.PauseMusic(name)
    end)
end

function S.ResumeMusic()
    getStageSingletonBackgroundMusicName(function(name)
        lstg.ResumeMusic(name)
    end)
end

function S.StopMusic()
    getStageSingletonBackgroundMusicName(function(name)
        lstg.StopMusic(name)
    end)
end

M.Singleton = S

Audio = M

return M