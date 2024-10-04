--- Load files

lstg.DoFile("lib/Resources.lua")

--- Custom implementation

function DoFrame()
    lstg.SetTitle(string.format("%s | %.2f FPS | %d OBJs", game_name, lstg.GetFPS(), lstg.GetnObj()))

    GetInput()

    if stage.NextStageExist() then
        stage.Change()
    end
    stage.Update()

    ObjFrame()

    BoundCheck()

    UpdateXY()
    AfterFrame()
end

--- Built-in game loop

local Debug = require("lib.Debug")

--- Game Entry Point. Called once.
function GameInit()
    Include('root.lua')

    InitAllClasses()
    InitScoreData()

    SetViewMode("world")
    if stage.next_stage == nil then
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

--- Game Render loop. Called every frame.
function RenderFunc()
    if stage.current_stage.timer >= 0 and stage.next_stage == nil then
        BeginScene()
        UpdateScreenResources()
        BeforeRender()
        stage.current_stage:render()
        ObjRender()
        AfterRender()
        Debug.Draw()
        EndScene()
    end
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