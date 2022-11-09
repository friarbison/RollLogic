local RollLogic = LibStub("AceAddon-3.0"):NewAddon("RollLogic", "AceConsole-3.0", "AceEvent-3.0")
local t={}
local f = CreateFrame("Frame")
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
        print("Duplicate entry")
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

local function DoSort()
  local SwitchColor, color = 1, "\124cFFFF0000"

  table.sort(t, function(a,b) return tonumber(a[3]) < tonumber(b[3]) end)
  for x,y in pairs(t) do        
    print(color..t[x][1] .." rolled a "..t[x][3].." in range "..t[x][4])

    if x % 3 == 0 then
      if SwitchColor == 1 then 
        color = "\124cFF00FF00"
        SwitchColor = 0
      else
        color = "\124cFFFF0000"
        SwitchColor = 1
      end         
    end
  end
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
      f:RegisterEvent("CHAT_MSG_SYSTEM")
      f:SetScript("OnEvent", OnEvent)
    elseif input == "off" then
      _Enabled = 0
      f:UnregisterEvent("CHAT_MSG_SYSTEM")
      t={}
      print("RollLogic is off")
    elseif input == "sort" or input == "s" then
      if _Enabled == 1 then 
        DoSort()
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
  self:UnregisterEvent("ADDON_LOADED")
end

function RollLogic:OnEnable()
  self:RegisterEvent("ADDON_LOADED")
end

function RollLogic:OnDisable()
  print("RollLogic is disabled.")
  self:RegisterEvent("ADDON_LOADED")
end


