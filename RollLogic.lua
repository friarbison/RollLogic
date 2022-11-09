local RollLogic = LibStub("AceAddon-3.0"):NewAddon("RollLogic", "AceConsole-3.0", "AceEvent-3.0")
local t={}
local MainFrame = CreateFrame("Frame","MFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
--local RollFrame = nil
local _Enabled = 0

local function TruncStr(str)
  while string.sub(str, -1) == ' '
  do
    str = string.sub(str, 1, (#str) - 1)
  end  
  return str
end

local function SplitString (incStr, sep, f )
  local cnt, l= 1, {}
  if sep == nil then
    sep = "%s"
  end
  
  if incStr == nil then
    return nil
  end 
  
  for str in string.gmatch(incStr, "([^"..sep.."]+)") do
    --print("SplitString[" .. cnt .. "]: <" .. str .. ">.")
    for x,y in pairs(t) do
      if t[x][1] == TruncStr(str) then
        str = "* ".. str
        --print("Duplicate entry")
        break
      end
      if t[x][3] == TruncStr(str) then
        t[x][1] = "> ".. t[x][1]
        --print("Duplicate entry")
        break
      end
    end
    table.insert(l, TruncStr(str))    
    cnt = cnt + 1
  end
  table.insert(t, l)
  cnt = cnt -1 
  --print("SplitString: Finished w/" .. cnt .. " total entries.")
end

local function DoSort(task)
  local SwitchColor, color, fText, fname, pos, height, length = 1, "\124cFFFF0000", nil, "RFrame", 1, 120, 300
  local RollFrame = nil
  
  if task ~= 1 then
    MainFrame.text:SetText("")
    local children = { MainFrame:GetChildren() }
    for i, child in ipairs(children) do
      child.text:SetText("")
    end
    return
  end
  
  MainFrame:SetSize(length,height)
  
  table.sort(t, function(a,b) return tonumber(a[3]) < tonumber(b[3]) end)
  for x,y in pairs(t) do  
    RollFrame = CreateFrame("Frame",fname..x, MainFrame, BackdropTemplateMixin and "BackdropTemplate")
    if x > 3 and x < 7 then        -- x is 4, 5, 6
      color = "\124cFF00FF00" --Green
    elseif x > 6 and x < 10 then   -- x is 7, 8, 9
      color = "\124cFFFFA500" --Orange
      if x == 7 then height = height + 40; MainFrame:SetSize(length,height) end
    elseif x > 9 and x < 13 then   -- x is 10, 11, 12
      color = "\124cFFFFFF00" --Yellow
      if x == 10 then height = height + 80; MainFrame:SetSize(length,height) end
    elseif x > 12 and x < 16 then  -- x is 13, 14, 15
      color = "\124cFFC0C0C0" --Grey
      if x == 13 then height = height + 120; MainFrame:SetSize(length,height) end
    elseif x > 15 and x < 19 then  -- x is 16, 17, 18
      color = "\124cFF0000FF" --Blue      
      if x == 16 then height = height + 160; MainFrame:SetSize(length,height)  end
    end
    if x == 1 then 
      pos = 5 
    else 
      pos = pos + 21
    end
    
    RollFrame:SetPoint("TOPLEFT", 1, -1*pos)
    RollFrame:SetSize(length,21)
--    RollFrame:SetBackdrop({
--      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
--      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
--      edgeSize = 10,
--    insets = { left = 1, right = 1, top = 1, bottom = 1 },
--    })
--    RollFrame:SetBackdropColor(0, 0, 1, .33)
    RollFrame.text = RollFrame:CreateFontString(nil,"ARTWORK") 
    RollFrame.text:SetFont("Fonts\\ARIALN.ttf", 16, "OUTLINE")
    RollFrame.text:SetPoint("LEFT", 0, 0)
    
    --print(" "..x..". "..color..t[x][1] .." rolled a "..t[x][3].." in range "..t[x][4].."\124r")
    if fText ~= nil then
      fText = fText.."\n"..x..". "
      fText = fText..color..t[x][1] .." rolled a "..t[x][3].." in range "..t[x][4].."\124r"
    else
      fText = x..". "
      fText = fText..color..t[x][1].." rolled a "..t[x][3].." in range "..t[x][4].."\124r"
    end
    RollFrame.text:SetText(" "..x..". "..color..t[x][1] .." rolled a "..t[x][3].." in range "..t[x][4].."\124r")
    RollFrame:Show()
    length = string.len(RollFrame.text:GetText()) * 6
    MainFrame:SetSize(length,height)
  end

  height = height + 40
  MainFrame:SetSize(length,height)
  pos = MainFrame:GetHeight() - 22
  
  RollFrame = CreateFrame("Frame","Legend", MainFrame, BackdropTemplateMixin and "BackdropTemplate")
  RollFrame:SetPoint("TOPLEFT", 1, -1*pos)
  RollFrame:SetSize(length,21)
--    RollFrame:SetBackdrop({
--      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
--      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
--      edgeSize = 10,
--    insets = { left = 1, right = 1, top = 1, bottom = 1 },
--    })
--    RollFrame:SetBackdropColor(0, 0, 1, .33)
  RollFrame.text = RollFrame:CreateFontString(nil,"ARTWORK") 
  RollFrame.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
  RollFrame.text:SetPoint("LEFT", 0, 0)
  RollFrame.text:SetText(" \"*\" Player has multiple rolls. \">\" Rolls are duplicated.")
  --MainFrame.text:SetText(fText)
end

local function OnEvent(self, event, ...)
  local str = select(1,...)
  if string.find(str, " rolls ") then
    SplitString(str)
  end
end

local options = {
  name = "RollLogic",
  handler = RollLogic,
  type = 'group',
  args = {
    intro = {
      order = 1,
      type = "description",
      name = "\"/RollLogic on\" enables the roll logic.\n"   ..
      "        \"/RollLogic off\" disables the roll logic and resets the routines.\n" ..
      "        \"/RollLogic h\" or \"?\" or \"help\" shows valid commands.\n" ..
      "        \"/RollLogic v\" or \"version\" shows current version.\n"
    }
  },
}

local defaults = {
  profile = {
    vStatus = false,
  }
}

function RollLogic:OnCommand(input)
  if self:GetName() == "RollLogic" then  
    if input == "on" then
      print("RollLogic is on")
      _Enabled = 1;
      MainFrame:SetSize(300,96)
      MainFrame:SetPoint("CENTER", 1, 1)
      MainFrame:RegisterEvent("CHAT_MSG_SYSTEM")
      MainFrame:SetScript("OnEvent", OnEvent)
      MainFrame:Show()
    elseif input == "off" then
      _Enabled = 0
      MainFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
      t={}
      print("RollLogic is off")
      MainFrame:Hide()
      DoSort(0)
    elseif input == "sort" or input == "s" then
      if _Enabled == 1 then 
        DoSort(1)
      else
        print("Sorry, RollLogic is not enabled!")
      end
    elseif input == "v" or input == "version" then
        print("Version: 1.0.0.2")
    elseif input == "h" or input == "help" then
        print("\"/RollLogic on\" enables the roll logic.\n"   ..
      "        \"/RollLogic off\" disables the roll logic and resets the routines.\n" ..
      "        \"/RollLogic h\" or \"?\" or \"help\" shows valid commands.\n" ..
      "        \"/RollLogic v\" or \"version\" shows current version.\n")
--    else if input == nil
--      if _Enabled == 1 
--        RollLogic:OnCommand("on")
--      else 
--        RollLogic:OnCommand("off")
--      end
    end
  end
end

function RollLogic:OnInitialize()
  LibStub("AceConfig-3.0"):RegisterOptionsTable("RollLogic", options, {"RollLogic"})
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RollLogic", "RollLogic")
  LibStub("AceConfigDialog-3.0"):SetDefaultSize("RollLogic", 400, 250)
  self:RegisterChatCommand("RollLogic", "OnCommand")
  self:RegisterChatCommand("rl", "OnCommand")
  self.Db = LibStub("AceDB-3.0"):New("RollLogicContent", defaults, true)
end

function RollLogic:ADDON_LOADED()   
  AddonHasLoaded = true
  if self.Db.profile.vStatus == true then
    RollLogic:OnCommand("off")
  end
  MainFrame:SetPoint("CENTER", 1, 1)
  MainFrame:SetSize(300,96)
  MainFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  MainFrame:SetBackdropColor(0, 0, 1, .33)
  MainFrame.text = MainFrame:CreateFontString(nil,"ARTWORK") 
  MainFrame.text:SetFont("Fonts\\ARIALN.ttf", 16, "OUTLINE")
  MainFrame.text:SetPoint("TOPLEFT", -2, -10)
  MainFrame.text:SetText("")
  MainFrame:Hide()
  self:UnregisterEvent("ADDON_LOADED")
end

function RollLogic:OnEnable()
  self:RegisterEvent("ADDON_LOADED")
  MainFrame:Hide()
end

function RollLogic:OnDisable()
  print("RollLogic is disabled.")
  self:RegisterEvent("ADDON_LOADED")
end

MainFrame:Hide()


