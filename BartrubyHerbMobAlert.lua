BartrubyHerbMobAlert = LibStub("AceAddon-3.0"):NewAddon("BartrubyHerbMobAlert", "AceConsole-3.0", "AceEvent-3.0")

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("sound", "HerbAlert", [[Interface\Addons\BartrubyHerbMobAlert\alert.ogg]])

local HERBMOBS = { }
HERBMOBS["98232"] = true -- Withered Hungerer (Azsuna)
HERBMOBS["98233"] = true -- Withered Hungerer (Suramar)
HERBMOBS["98234"] = true -- Nightmare Creeper (Val'sharah)
HERBMOBS["98235"] = true -- Frenzied Fox (Highmountain)  Requires friendly nameplates to be visible

function BartrubyHerbMobAlert:OnInitialize()
 local defaults = {
  profile = {
   alertWait = 10,
   alertSound = "HerbAlert",
   customFont = false,
   fontSize = 32,
   fontType = "Friz Quadrata TT",
  },
 }
 
 self.db = LibStub("AceDB-3.0"):New("BartrubyHerbMobAlertDB", defaults, true)
 LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("BartrubyHerbMobAlert", self:GenerateOptions())
 self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BartrubyHerbMobAlert", "BartrubyHerbMobAlert")
 
 self.lastAlert = 0
end

function BartrubyHerbMobAlert:OnEnable()
 self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end

function BartrubyHerbMobAlert:OnDisable()
 self:UnregisterAllEvents()
end

function BartrubyHerbMobAlert:NAME_PLATE_UNIT_ADDED(event, unit)
 local _, _, _, _, _, npc_id, _ = strsplit("-", UnitGUID(unit))
 
 if (HERBMOBS[npc_id] and (GetTime() > self.lastAlert)) then
  --if (UnitIsTapDenied(unit)) then self:Print("UNIT IS TAP DENIED:",unit) end
  if (self.db.profile.customFont) then
   self:CustomMessage((UnitName(unit)) .. " Spawned!")
  else  
   UIErrorsFrame:AddMessage((UnitName(unit)) .. " Spawned!")
  end
  PlaySoundFile(LSM:Fetch("sound", self.db.profile.alertSound), "MASTER")
  self.lastAlert = GetTime() + self.db.profile.alertWait
 end
end

function BartrubyHerbMobAlert:CustomMessage(message)
 if (not self.message) then
  self.message = CreateFrame("Frame", nil, UIParent)
  self.message.text = self.message:CreateFontString(nil, 'OVERLAY')
  self.message.text:SetAllPoints(true)
  self.message:SetWidth(200)
  self.message:SetHeight(40)
  self.message:SetPoint("BOTTOM", UIErrorsFrame, "TOP", 0, 0)
  
  self.message:SetScript("OnShow", function(self)
									self:SetWidth((self.text:GetStringWidth() or 10) + 10)
                                   end)
								   
  self.message:SetScript("OnUpdate", function(self)
                                      local now = GetTime()
									  local percent = (now - self.timeStart) / 7
									  percent = 1 - percent
									  
                                      self:SetAlpha(percent)
									  if (percent <= 0) then
									   self:Hide()
									  end
                                     end)
 end
 self.message:Hide()
 
 self.message.text:SetFont(LSM:Fetch("font", self.db.profile.fontType), self.db.profile.fontSize, "")
 self.message.text:SetText(message)
 self.message.timeStart = GetTime()
 self.message:Show()
 self.message:SetAlpha(1)
end

function BartrubyHerbMobAlert:GenerateOptions()
 local options = {
  name = "BartrubyHerbMobAlert",
  type = "group",
  get = function(i) return self.db.profile[i[1]] end,
  set = function(i, v) self.db.profile[i[1]] = v end,
  args = {
   alertWait = {
    name = "Time between alerts",
    type = "range",
	order = 1,
    min = 1, max = 60, step = 1,
   },
   alertSound = {
    name = "Alert Sound",
    type = "select",
	order = 2,
    values = LSM:HashTable("sound"),
    dialogControl = "LSM30_Sound",
   },
   customFont = {
    name = "Use Custom Font",
	type = "toggle",
	order = 4,
   },
   fontType = {
    name = "Font",
    order = 4.1,
    type = "select",
    values = LSM:HashTable("font"),
    dialogControl = "LSM30_Font",
   },
   fontSize = {
    name = "Font Size",
    type = "range",
	order = 4.2,
    min = 8, max = 64, step = 1,
   },
  },
 }
 return options
end