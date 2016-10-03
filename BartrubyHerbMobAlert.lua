BartrubyHerbMobAlert = LibStub("AceAddon-3.0"):NewAddon("BartrubyHerbMobAlert", "AceConsole-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("BartrubyHerbMobAlert")
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("sound", "HerbAlert", [[Interface\Addons\BartrubyHerbMobAlert\alert.ogg]])

local HERBMOBS = { }
HERBMOBS[L["Withered Hungerer"]] = true
HERBMOBS[L["Nightmare Creeper"]] = true

function BartrubyHerbMobAlert:OnInitialize()
 local defaults = {
  profile = {
   alertWait = 10,
   alertSound = "HerbAlert",
  },
 }
 
 self.db = LibStub("AceDB-3.0"):New("BartrubyHerbMobAlertDB", defaults, true)
 LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("BartrubyHerbMobAlert", self:GenerateOptions())
 self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BartrubyHerbMobAlert", "BartrubyHerbMobAlert")
 
 self.lastAlert = 0
end

function BartrubyHerbMobAlert:OnEnable()
 self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
 --self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")  Will trigger on any spawns not just ours
end

function BartrubyHerbMobAlert:OnDisable()
 self:UnregisterAllEvents()
end

function BartrubyHerbMobAlert:NAME_PLATE_UNIT_ADDED(event, name)
 self:ProcessMob(UnitName(name), event)
end

function BartrubyHerbMobAlert:COMBAT_LOG_EVENT_UNFILTERED(event, a, b, c, d, sourceName)
 self:ProcessMob(sourceName, event)
end

function BartrubyHerbMobAlert:ProcessMob(name, event)
 if (HERBMOBS[name] and (GetTime() > self.lastAlert)) then
  UIErrorsFrame:AddMessage(name .. " Spawned!")
  PlaySoundFile(LSM:Fetch("sound", self.db.profile.alertSound), "MASTER")
  self.lastAlert = GetTime() + self.db.profile.alertWait
 end
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
  },
 }
 return options
end