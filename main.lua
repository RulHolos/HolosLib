--- Load files

lstg.DoFile("core/Resources.lua")
Include("core/Log.lua")
Include("core/Global.lua")
Include("core/Objects.lua")
Include("core/Task.lua")
Include("core/Input.lua")
Include("core/StageSystem.lua")
Include("core/Screen.lua")

local Debug = require("core.Debug")

--- Custom implementation

function DoFrame()
    lstg.SetTitle(string.format("%s | %.2f FPS | %d OBJs", GameName, lstg.GetFPS(), lstg.GetnObj()))

    GetInput()

    if StageSystem.next_stage then
        StageSystem.Change()
    end
    StageSystem.Update()

    ObjFrame()

    BoundCheck()
    CheckCollisions()
    UpdateXY()
    AfterFrame()
end

function CheckCollisions()
    CollisionCheck(GROUP_PLAYER, GROUP_ENEMY_BULLET)
    CollisionCheck(GROUP_PLAYER, GROUP_ENEMY)
    CollisionCheck(GROUP_PLAYER, GROUP_IMMORTAL)
    CollisionCheck(GROUP_ENEMY, GROUP_PLAYER_BULLET)
    CollisionCheck(GROUP_ENEMY, GROUP_BOMB)
    CollisionCheck(GROUP_ITEM, GROUP_PLAYER)
end

--- Built-in game loop

--- Game Entry Point. Called once.
function GameInit()
    Include('root.lua')

    InitAllClasses()
    --InitScoreData()

    --SetViewMode("world")
    if StageSystem.entry_stage == nil then
        error("Entry stage not defined.")
    end
    SetResourceStatus("stage")
end

--- Game Exit Point. Called once when the engine closes.
function GameExit()

end

--- Game Frame loop. Called every frame.
function FrameFunc()
    Debug.Update()
    DoFrame()
    Debug.Layout()
    return lstg.quit_flag or false
end

function BeforeRender()
end

--- Game Render loop. Called every frame.
function RenderFunc()
    if StageSystem.current_stage.timer >= 0 and StageSystem.next_stage == nil then
        BeginScene()
        UpdateScreenResources()
        BeforeRender()
        StageSystem.current_stage:render()
        ObjRender()
        AfterRender()
        Debug.Draw()
        EndScene()
    end
end

function AfterRender()
end

--- Game Event Loop. Not sure what that means.
function EventFunc()

end

--- Event: On window losing focus.
function FocusLoseFunc()

end

--- Event: On window gaining focus.
function FocusGainFunc()

end