local RollLogic = LibStub("AceAddon-3.0"):NewAddon("RollLogic", "AceConsole-3.0", "AceEvent-3.0")
local CloseButton = CreateFrame("Button", "CloseButton", MainFrame)
local ClearButton = CreateFrame("Button", "ClearButton", MainFrame)
local SortButton = CreateFrame("Button", "SortButton", MainFrame)
local t, Rolls, VERSION = {}, 1, "12.0.0.13"
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
  local cnt, l, modded = 1, {}, 0
  if sep == nil then
    sep = "%s"
  end
  
  if incStr == nil then
    return nil
  end 
  
  for str in string.gmatch(incStr, "([^"..sep.."]+)") do
    --print("SplitString[" .. cnt .. "]: <" .. str .. ">.  Trunc = " .. TruncStr(str))
    for x,y in pairs(t) do      
      if t[x][1] == TruncStr(str) then
        str = " * " .. str
        --print("Dual roll (tx1)" .. t[x][1])
        modded = 1
        break
      end
      if t[x][3] == TruncStr(str) then
        t[x][1] = " > " .. t[x][1]
        --print("Duplicate roll (tx3)" .. t[x][3])
        modded = 1
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
  local SwitchColor, color, fText, fname, pos, height, length = 1, "\124cFFFF0000", nil, "RFrame", 1, 160, 600
  local RollFrame = nil
  
  if task ~= 1 then
    MainFrame.text:SetText("")
    local children = { MainFrame:GetChildren() }
    for i, child in ipairs(children) do
      child.text:SetText("")
    end
    return
  end
  
  --print("1. Length = " .. length .. " and Height is " .. height)
  
  MainFrame:SetSize(length,height)
  
  table.sort(t, function(a,b) return tonumber(a[3]) < tonumber(b[3]) end)
  for x,y in pairs(t) do  
    RollFrame = CreateFrame("Frame",fname..x, MainFrame, BackdropTemplateMixin and "BackdropTemplate")
    if x > 3 and x < 7 then        -- x is 4, 5, 6
      color = "\124cFF00FF00" --Green
      if x == 6 then height = height + 30; MainFrame:SetSize(length,height) end
      --print("1. Length = " .. length .. " and Height is " .. height)
    elseif x > 6 and x < 10 then   -- x is 7, 8, 9
      color = "\124cFFFFA500" --Orange
      if x == 7 then height = height + 100; MainFrame:SetSize(length,height) end
      --print("2. Length = " .. length .. " and Height is " .. height)
    elseif x > 9 and x < 13 then   -- x is 10, 11, 12
      color = "\124cFFFFFF00" --Yellow
      if x == 10 then height = height + 100; MainFrame:SetSize(length,height) end
      --print("3. Length = " .. length .. " and Height is " .. height)
    elseif x > 12 and x < 16 then  -- x is 13, 14, 15
      color = "\124cFFC0C0C0" --Grey
      if x == 13 then height = height + 100; MainFrame:SetSize(length,height) end
      --print("4. Length = " .. length .. " and Height is " .. height)
    elseif x > 15 and x < 19 then  -- x is 16, 17, 18
      color = "\124cFF0000FF" --Blue      
      if x == 16 then height = height + 100; MainFrame:SetSize(length,height)  end
      --print("5. Length = " .. length .. " and Height is " .. height)
    end
    if x == 1 then 
      pos = 5 
    else 
      pos = pos + 31
    end
    
    RollFrame:SetPoint("TOPLEFT", 1, -1*pos)
    RollFrame:SetSize(length,64)
    RollFrame.text = RollFrame:CreateFontString(nil,"ARTWORK") 
    RollFrame.text:SetFont("Fonts\\ARIALN.ttf", 32, "OUTLINE")
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
    length = string.len(RollFrame.text:GetText()) * 11
    MainFrame:SetSize(length,height)
  end

  height = height + 50
  MainFrame:SetSize(length,height)
  pos = MainFrame:GetHeight() - 18
end

local function OnEvent(self, event, ...)
  local str = select(1,...)
  if string.find(str, " rolls ") then
    SplitString(str)
    SortButton:SetText("Sort [" .. tostring(Rolls) .. "]")
    Rolls = Rolls + 1
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

local function ResetData ()
  DoSort(0)
  t={}
  SortButton:SetText("Sort")
  Rolls = 1
  MainFrame.text:SetText(" \"*\" Player has multiple rolls. \">\" Rolls are duplicated.")
end

function RollLogic:OnCommand(input)
  if self:GetName() == "RollLogic" then  
    if input == "on" then
      print("RollLogic is on")
      _Enabled = 1;
      MainFrame:SetSize(600,120)
      MainFrame:SetPoint("CENTER", 1, 1)
      MainFrame:RegisterEvent("CHAT_MSG_SYSTEM")
      MainFrame:SetScript("OnEvent", OnEvent)
      MainFrame:Show()
      ClearButton:Show()
      CloseButton:Show()
      SortButton:Show()
    elseif input == "off" then
      _Enabled = 0
      MainFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
      t={}
      print("RollLogic is off")
      ClearButton:Hide()
      CloseButton:Hide()
      SortButton:Hide()
      MainFrame:Hide()
      DoSort(0)
    elseif input == "sort" or input == "s" then
      if _Enabled == 1 then 
        DoSort(1)
      else
        print("Sorry, RollLogic is not enabled!")
      end
    elseif input == "v" or input == "version" then
        print("Version: " .. VERSION)
    elseif input == "h" or input == "help" then
        print("\"/RollLogic on\" enables the roll logic.\n"   ..
      "        \"/RollLogic off\" disables the roll logic and resets the routines.\n" ..
      "        \"/RollLogic h\" or \"?\" or \"help\" shows valid commands.\n" ..
      "        \"/RollLogic v\" or \"version\" shows current version.\n")
    end
  end
end

function RollLogic:OnInitialize()
  LibStub("AceConfig-3.0"):RegisterOptionsTable("RollLogic", options, {"RollLogic"})
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RollLogic", "RollLogic")
  LibStub("AceConfigDialog-3.0"):SetDefaultSize("RollLogic", 400, 250)
  self:RegisterChatCommand("RollLogic", "OnCommand")
  self:RegisterChatCommand("rol", "OnCommand")
  self.Db = LibStub("AceDB-3.0"):New("RollLogicContent", defaults, true)
end

function RollLogic:ADDON_LOADED()   
  AddonHasLoaded = true
  if self.Db.profile.vStatus == true then
    RollLogic:OnCommand("off")
  end
  MainFrame:SetPoint("CENTER", 1, 1)
  MainFrame:SetSize(600,120)
  MainFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  MainFrame:SetBackdropColor(0, 0, 1, .33)
  MainFrame.text = MainFrame:CreateFontString(nil,"ARTWORK") 
  MainFrame.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
  MainFrame.text:SetPoint("BOTTOM", 1, 25) 
  MainFrame.text:SetText(" \"*\" Player has multiple rolls. \">\" Rolls are duplicated.")
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

  --ClearButton:SetPoint("LEFT", MainFrame, "BOTTOM", 0, 10)
  ClearButton:SetPoint("BOTTOMLEFT", MainFrame, 0, 2)
  ClearButton:SetWidth(35)
  ClearButton:SetHeight(14)

  ClearButton:SetText("Clear")
  ClearButton:SetNormalFontObject("GameFontNormal")

  local cbntex = ClearButton:CreateTexture()
  cbntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
  cbntex:SetTexCoord(0, 0.625, 0, 0.6875)
  cbntex:SetAllPoints()	
  ClearButton:SetNormalTexture(cbntex)

  local cbhtex = ClearButton:CreateTexture()
  cbhtex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
  cbhtex:SetTexCoord(0, 0.625, 0, 0.6875)
  cbhtex:SetAllPoints()
  ClearButton:SetHighlightTexture(cbhtex)

  local cbptex = ClearButton:CreateTexture()
  cbptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
  cbptex:SetTexCoord(0, 0.625, 0, 0.6875)
  cbptex:SetAllPoints()
  ClearButton:SetPushedTexture(cbptex)

  ClearButton:SetScript("OnClick", function(self) ResetData() end)

  ClearButton:Hide()
  --------------------------------------------------------------------------
  --CloseButton:SetPoint("Right", MainFrame, "BOTTOM", 0, 10)
  CloseButton:SetPoint("BOTTOMRIGHT", MainFrame, 0, 2)
  CloseButton:SetWidth(35)
  CloseButton:SetHeight(14)

  CloseButton:SetText("Close")
  CloseButton:SetNormalFontObject("GameFontNormal")

  local clsNtx = CloseButton:CreateTexture()
  clsNtx:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
  clsNtx:SetTexCoord(0, 0.625, 0, 0.6875)
  clsNtx:SetAllPoints()	
  CloseButton:SetNormalTexture(clsNtx)

  local clsHtx = CloseButton:CreateTexture()
  clsHtx:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
  clsHtx:SetTexCoord(0, 0.625, 0, 0.6875)
  clsHtx:SetAllPoints()
  CloseButton:SetHighlightTexture(clsHtx)

  local clsPtx = CloseButton:CreateTexture()
  clsPtx:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
  clsPtx:SetTexCoord(0, 0.625, 0, 0.6875)
  clsPtx:SetAllPoints()
  CloseButton:SetPushedTexture(clsPtx)

  CloseButton:SetScript("OnClick", function(self) RollLogic:OnCommand("off") end)

  CloseButton:Hide()
  ---------------------------------------------------------------------------------------
  SortButton:SetPoint("Bottom", MainFrame, 0, 2)  -- , "BOTTOM", 0, 7)
  SortButton:SetWidth(65)
  SortButton:SetHeight(14)

  SortButton:SetText("Sort")
  SortButton:SetNormalFontObject("GameFontNormal")

  local srtNtx = SortButton:CreateTexture()
  srtNtx:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
  srtNtx:SetTexCoord(0, 0.625, 0, 0.6875)
  srtNtx:SetAllPoints()	
  SortButton:SetNormalTexture(srtNtx)

  local srtHtx = SortButton:CreateTexture()
  srtHtx:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
  srtHtx:SetTexCoord(0, 0.625, 0, 0.6875)
  srtHtx:SetAllPoints()
  SortButton:SetHighlightTexture(srtHtx)

  local srtPtx = SortButton:CreateTexture()
  srtPtx:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
  srtPtx:SetTexCoord(0, 0.625, 0, 0.6875)
  srtPtx:SetAllPoints()
  SortButton:SetPushedTexture(srtPtx)

  SortButton:SetScript("OnClick", function(self) RollLogic:OnCommand("sort") end)

  SortButton:Hide()

MainFrame:Hide()


