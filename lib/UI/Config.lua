---@class UI.UIConfig
UIConfig = {}

UIConfig.debug_mode = false
UIConfig.DisableLoadingScene = false
UIConfig.FadeInFrames = 30
UIConfig.FadeOutFrames = 30
UIConfig.ViewChangeFrames = 10
UIConfig.WaitOnLoading = 60 * 1.5

---@class UI.Global
local G = {}
UIGlobal = G

---@type '""' | '"start"' | '"practice"' | '"scene practice"' | '"replay"'
G.start_mode = ""

G.select_group = ""