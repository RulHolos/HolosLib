local patch = "lib/UI/title/"
Include(patch .. "Background.lua")
Include(patch .. "Main.lua")

---@class UI.Scene.MainTitle : StageSystem.Stage
local main_title = StageSystem.New("title", false, true)

local view_stack_manager = ViewStackManager.create()

function main_title:init()
    --Audio.LoadMusic("menu")

    self.Background = UIBackground.create()
    view_stack_manager:AddObjectWithName("UI.Menu.Background", self.Background)
    self.Main = UIMain.create()
    view_stack_manager:AddObjectWithName("UI.Menu.Main", self.Main)
    --self.SelectGameMode = UISelectGameMode.create()
    --view_stack_manager:AddObjectWithName("UI.Menu.SelectGameMode", self.SelectGameMode)

    Task.New(self, function()
        self.Background:enter()

        Task.Wait(UIConfig.FadeInFrames)
        --Audio.Singleton.PlayMusic("menu")

        view_stack_manager:PushView(self.Main, "both")

        if view_stack_manager:IsViewAtStackTop(self.Main) then
            view_stack_manager:PopView("both")
            self.Main:SetTypeFirstTime(true)
            view_stack_manager:PushView(self.Main)
            self.Main:SetTypeFirstTime(false)
        else
            --view_stack_manager:PushView(self.Void, "both")
            --view_stack_manager:PopView()
        end
    end)
end
function main_title:frame()
    view_stack_manager:frame()
end
function main_title:render()
    view_stack_manager:render()
end