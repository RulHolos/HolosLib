---@class lstg.LocalUserData
local M = {}
lstg.LocalUserData = M

local dir_root = "scoredata"
local dir_snapshots = dir_root .. "/snapshots"
local dir_replays = dir_root .. "/replays"
local dir_score = dir_root .. "/score"

function M.CreateDirectories()
    lstg.FileManager.CreateDirectory(dir_root)
    lstg.FileManager.CreateDirectory(dir_snapshots)
    lstg.FileManager.CreateDirectory(dir_replays)
    lstg.FileManager.CreateDirectory(dir_score)
end

---@return string
function M.GetRootDirectory()
    return dir_root
end

---@return string
function M.GetSnapshotsDirectory()
    return dir_snapshots
end

---@return string
function M.GetReplaysDirectory()
    return dir_replays
end

---@return string
function M.GetScoreDirectory()
    return dir_score
end

function M.Snapshot()
    local file_name = string.format("%s/%s.jpg", dir_snapshots, os.date("%d-%m-%Y-%H-%M-S"))
    lstg.Snapshot(file_name)
end

M.CreateDirectories()