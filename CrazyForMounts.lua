local addonName, phis = ...

local phisFrame = CreateFrame('Frame', 'phisCheckFrame', UIParent)
phisFrame:RegisterEvent('ADDON_LOADED')

-- controls whether non-flying mounts can be added to the table of flying mounts
local locked = true

-- controls the icons to indicate personal favorites
local personalFavoriteIcons = {}

-- key binding globals
BINDING_HEADER_CRAZYFORMOUNTS = addonName
BINDING_NAME_CRAZYFORMOUNTS_SUMMON_RANDOM = "Summon random mount"
BINDING_NAME_CRAZYFORMOUNTS_SUMMON_FLYING = "Summon random flying mount"
BINDING_NAME_CRAZYFORMOUNTS_SUMMON_GROUND = "Summon random ground mount"
BINDING_NAME_CRAZYFORMOUNTS_SUMMON_RIDING = "Summon random Skyriding mount"
CrazyForMountsGlobals = {}

-------------------------
--   AUXILIARY STUFF   --
-------------------------

local function getLength(tbl)
	length = 0
	for k,v in pairs(tbl) do
		length = length + 1
	end
	return length
end

local function hasValue(tbl, val)
	for _, v in ipairs(tbl) do
		if v == val then
			return true
		end
	end
	return false	
end

local function addonPrint(str)
	print('|cFF40C7EB'..addonName..':|r '..str)
end

-- checks whether the player has the respective spells to allow Skyriding in the Amirdrassil raid
function phis.HasSkyridingBuffs()
	-- Empowered Feather
	if C_UnitAuras.GetPlayerAuraBySpellID(422510) then
		return true
	end
	
	-- Blessing of the Emerald Dream
	if C_UnitAuras.GetPlayerAuraBySpellID(429226) then
		return true
	end

	return false
end

-- checks whether the player can actually fly
-- flyingLevel as argument because flying and Skyriding have different requirements
function phis.IsFlyableArea(flyingLevel)
	if flyingLevel == nil then
		flyingLevel = 20
	end
	-- default WoW check
	if not IsFlyableArea() then
		return false
	elseif UnitLevel("player") < flyingLevel then
		return false
	end
	
	-- no flying in Warfronts
	local _, instanceType = IsInInstance()
	if instanceType == 'scenario' then
		local _, _, _, _, _, _, _, _, _, scenarioType = C_Scenario.GetInfo()
		if scenarioType == LE_SCENARIO_TYPE_WARFRONT then
			return false
		end
	end
	
	return true
end

-- checks whether the player can actually use Skyriding
function phis.IsSkyridableArea()
	-- check if player has (no) mounts for Skyriding
	local collectedSkyridingMounts = C_MountJournal.GetCollectedDragonridingMounts() 
	if not collectedSkyridingMounts or getLength(collectedSkyridingMounts) == 0 then
		return false
	end
	
	-- check if the player has the Steady flight style buff active
	if C_UnitAuras.GetPlayerAuraBySpellID(404468) then
		return false
	end
	
	-- check if in instance -> https://warcraft.wiki.gg/wiki/API_IsInInstance
	-- make exceptions if the player has either 'Empowered Feather' or ''
	-- make exception if the player is in The Nokhud Offensive
	_, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	if IsInInstance() and not (phis.HasSkyridingBuffs() or instanceID == 2516) then
		return false
	end
	
	-- overwrite for TWW zones
	local skyridingZonesTWW = {
		[2248] = true, -- Isle of Dorn
		[2339] = true, -- Dornogal
		[2214] = true, -- The Ringing Deeps
		[2215] = true, -- Hallowfall
		[2255] = true, -- Azj-Kahet
	}
	local mapId = C_Map.GetBestMapForUnit("player")
	if skyridingZonesTWW[mapId] then
		return true
	end
	
	-- since Skyriding is available wherever flying is allowed, check whether the area is flyable
	return phis.IsFlyableArea(10)
end

-------------------------
--   FRAME FACTORIES   --
-------------------------

local function createInset(name, parent, w, h, anchor, ofsX, ofsY, label, content)
	local newInset = CreateFrame('Frame', name, parent, 'InsetFrameTemplate3')
	newInset:SetSize(w,h)
	newInset:SetPoint(anchor, ofsX, ofsY)
	
	newInset.content = newInset:CreateFontString(name..'ContentFontString', 'ARTWORK', 'GameFontHighlightSmall')
	newInset.content:SetPoint('RIGHT', -10, 0)
	newInset.content:SetJustifyH('RIGHT')
	newInset.content:SetText(content)
	
	newInset.label = newInset:CreateFontString(name..'LabelFontString', 'ARTWORK', 'GameFontNormalSmall')
	newInset.label:SetPoint('LEFT', 10, 0)
	newInset.label:SetPoint('RIGHT', newInset.content, 'LEFT', -3, 0)
	newInset.label:SetJustifyH('LEFT')
	newInset.label:SetText(label)
	
	return newInset
end

local function createCheckbox(name, parent, anchor, relativeFrame, relativePoint, ofsX, ofsY, tooltip, bgPath)
	local newCheckbox = CreateFrame('CheckButton', name, parent, 'UICheckButtonTemplate')
	newCheckbox:SetPoint(anchor, relativeFrame, relativePoint, ofsX, ofsY)
	
	newCheckbox:SetHeight(38)
	newCheckbox:SetWidth(38)
	
	newCheckbox:SetScript('OnEnter', function()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetPoint('BOTTOMRIGHT', newCheckbox, 'TOPRIGHT', 0, 0);
		GameTooltip:SetText(tooltip)
		GameTooltip:Show()
	end)
	
	newCheckbox:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
	
	newCheckbox.background = newCheckbox:CreateTexture(name..'Texture', 'BACKGROUND')
	newCheckbox.background:SetWidth(24)
	newCheckbox.background:SetHeight(24)
	newCheckbox.background:SetTexture(bgPath)
	newCheckbox.background:SetPoint('CENTER',newCheckbox)

	return newCheckbox
end

local function createPersonalFavoriteIcon(name, parent)
	personalFavoriteIcon = parent:CreateTexture(addonName..name, 'OVERLAY', nil, 0)
	personalFavoriteIcon:SetAtlas('PetJournal-FavoritesIcon', true)
	personalFavoriteIcon:SetPoint('RIGHT', parent, 'RIGHT', -2, 0)
	personalFavoriteIcon:SetDesaturated(true)
	personalFavoriteIcon:SetVertexColor(0.250, 0.780, 0.921)

	return personalFavoriteIcon
end

-------------------------
--   ADDON FUNCTIONS   --
-------------------------
-- updates the list to star icons in the scroll frame on personal favorites
local function updateList()
	-- since frames get reused, hide all favorite icons before opening the journal to make sure that a frame which now shows a non favorite pet does not keep its icon
	for _, v in pairs(personalFavoriteIcons) do
		v:Hide()
	end

	if MountJournal:IsVisible() then
	
		local currentView = MountJournal.ScrollBox:GetView()
		local visibleMountCards = currentView:GetFrames()
		
		for k, v in pairs(visibleMountCards) do
			local mountID = v.mountID
			
			if personalFavoriteIcons[v] == nil then
				personalFavoriteIcons[v] = createPersonalFavoriteIcon('.visibleMountCards.personalFavoriteIcon', v)
			end
			personalFavoriteIcons[v]:Hide()
			
			-- only show the icon again if the frame contains a mount whose mountID is in the set of personal favorites
			if personalMountDB['ground'][mountID] ~= nil or personalMountDB['flying'][mountID] ~= nil or personalMountDB['riding'][mountID] ~= nil then
				personalFavoriteIcons[v]:Show()
			end
		end
	end
end

local function summonRandom(mountType)
	-- if addon not initialized
	if personalMountCount == nil or personalMountDB == nil then
		addonPrint('Addon not yet initialized. Open the mount journal...')
		return
	end

	-- if the player is currently mounted - dismount them
	if IsMounted() then
		Dismount()
		return
	end
	
	-- if mountType is nil select the appropriate mount table
	-- else select the table corresponding to the given argument
	-- prioritizes Skyriding mounts over flying mounts
	-- only combines flying and Skyriding mounts if no mountType is given
	local canFly = false
	local canRide = false
	if mountType == nil then
		canFly = phis.IsFlyableArea()
		canRide = phis.IsSkyridableArea()
	elseif mountType == 'flying' then
		canFly = true
	elseif mountType == 'riding' then
		canRide = true
	end
	
	if combineSkyridingAndFlyingFlag and mountType == nil and (canFly or canRide) then
		tmpMountDB = {}
		for k,v in pairs(personalMountDB.riding) do
			tmpMountDB[k] = v
		end
		for k,v in pairs(personalMountDB.flying) do
			tmpMountDB[k] = v
		end
		tmpCount = getLength(tmpMountDB)
	elseif canRide then
		tmpCount = (personalMountCount.riding or 0)
		tmpMountDB = (personalMountDB.riding or {})
	elseif canFly then
		tmpCount = (personalMountCount.flying or 0)
		tmpMountDB = (personalMountDB.flying or {})
	else
		tmpCount = (personalMountCount.ground or 0)
		tmpMountDB = (personalMountDB.ground or {})
	end
	
	-- add all mounts from the chosen table to an (ordinary) array to make unpack() work
	if tmpCount > 0 then
		local tmpIDs = {}
		for k in pairs(tmpMountDB) do
			table.insert(tmpIDs, k)
		end
		local mountID = tmpIDs[math.random(#tmpIDs)]
		C_MountJournal.SummonByID(mountID)
	else
		addonPrint('No personal '..(canRide and 'Skyriding' or (canFly and 'flying' or 'ground'))..' mounts set.')
	end
end
-- add to globals for keybindings
CrazyForMountsGlobals.summonRandom = summonRandom

-- mountIDs are used as keys for more efficient lookup
local function updateDB(mountID, mountType, addMount)
	-- mountType = flyable and 'flying' or 'ground'
	if addMount and personalMountDB[mountType][mountID] == nil then
		personalMountDB[mountType][mountID] = true
		personalMountCount[mountType] = personalMountCount[mountType] + 1
	elseif not addMount and personalMountDB[mountType][mountID] ~= nil then
		personalMountDB[mountType][mountID] = nil
		personalMountCount[mountType] = math.max(personalMountCount[mountType] - 1, 0)
	end
end

local function initAddon()
	--- SETUP VARIABLES ---
	
	if personalMountDB == nil then
		personalMountDB = {ground = {}, flying = {}, riding = {}}		
	end
	
	if personalMountDB.ground == nil then
		personalMountDB.ground = {}
	end
	
	if personalMountDB.flying == nil then
		personalMountDB.flying = {}
	end
	
	if personalMountDB.riding == nil then
		personalMountDB.riding = {}
	end
	
	if personalMountCount == nil then
		personalMountCount = {ground = 0, flying = 0, riding = 0}
		local playerName, playerRealm = UnitFullName('player')
		local _, playerClass = UnitClass('player')
		local _, _, _, classColor = GetClassColor(playerClass)
		addonPrint('Addon loaded for the first time on |c'..classColor..playerName..'|r-'..playerRealm..'.')
	end
	
	if combineSkyridingAndFlyingFlag == nil then
		combineSkyridingAndFlyingFlag = false
	end

	--- CREATE AND ATTACH FRAMES ---
	local groundMountInset = createInset('groundMountInset', MountJournal, 100, 20, 'BOTTOMRIGHT', -7, 5, 'Ground: ', personalMountCount.ground)
	local flyingMountInset = createInset('flyingMountInset', groundMountInset, 100, 20, 'LEFT', -110, 0, 'Flying: ', personalMountCount.flying)
	local ridingMountInset = createInset('ridingMountInset', flyingMountInset, 120, 20, 'LEFT', -130, 0, 'Skyriding: ', personalMountCount.riding)
	
	checkBoxCombineSkyridingAndFlying = createCheckbox('CrazyForMountsCheckBoxRiding', MountJournal, 'RIGHT', ridingMountInset, 'LEFT', -8, -1, 'Combine Skyriding and flying mounts', 'Interface\\Addons\\CrazyForMounts\\Icons\\union')
	checkBoxCombineSkyridingAndFlying:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		combineSkyridingAndFlyingFlag = checked
	end)
	checkBoxCombineSkyridingAndFlying:SetScale(0.8)
	
	-- icons are from (all with CC0 license):
	-- https://www.pngrepo.com/svg/307488/dragon-with-wings-monster-legend-myth
	-- https://www.pngrepo.com/svg/37053/flying-dove-bird-shape
	-- https://www.pngrepo.com/svg/140806/horse-jumping-silhouette
	-- https://www.pngrepo.com/svg/274318/combine-union
	
	local checkBoxGround = createCheckbox('CrazyForMountsCheckBoxGround', MountJournal.MountDisplay, 'TOPLEFT', MountJournal.MountDisplay, 'BOTTOMLEFT', 10, 52, 'Add this mount to your personal ground mounts', 'Interface\\Addons\\CrazyForMounts\\Icons\\horse')
	checkBoxGround:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local mountID = MountJournal.selectedMountID
		updateDB(mountID, 'ground', checked)
		updateList()
		groundMountInset.content:SetText(personalMountCount.ground)
	end)
	
	local checkBoxFlying = createCheckbox('CrazyForMountsCheckBoxFlying', MountJournal.MountDisplay, 'LEFT', checkBoxGround, 'RIGHT', 10, 0, 'Add this mount to your personal flying mounts', 'Interface\\Addons\\CrazyForMounts\\Icons\\bird')
	checkBoxFlying:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local mountID = MountJournal.selectedMountID
		updateDB(mountID, 'flying', checked)
		updateList()
		flyingMountInset.content:SetText(personalMountCount.flying)
	end)
	
	local checkBoxRiding = createCheckbox('CrazyForMountsCheckBoxRiding', MountJournal.MountDisplay, 'LEFT', checkBoxFlying, 'RIGHT', 10, 0, 'Add this mount to your personal Skyriding mounts', 'Interface\\Addons\\CrazyForMounts\\Icons\\dragon')
	checkBoxRiding:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local mountID = MountJournal.selectedMountID
		updateDB(mountID, 'riding', checked)
		updateList()
		ridingMountInset.content:SetText(personalMountCount.riding)
	end)
	
	hooksecurefunc('MountJournal_UpdateMountDisplay', function()
		local mountID = MountJournal.selectedMountID
		checkBoxGround:SetChecked(personalMountDB.ground[mountID] == true)
		checkBoxFlying:SetChecked(personalMountDB.flying[mountID] == true)
		checkBoxRiding:SetChecked(personalMountDB.riding[mountID] == true)
		
		local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		-- disable checking non-flying mounts as flying mounts
		checkBoxFlying:Enable()
		checkBoxFlying:SetAlpha(1)
		checkBoxRiding:Enable()
		checkBoxRiding:SetAlpha(1)
		-- 248 encompasses most flying mounts
		-- 402 encompasses (explicit) Dragonriding mounts
		-- 424 encompasses flying mounts which can potentially be used as Skyriding mounts (e.g. Nether Drakes)
		-- 437 encompasses amongst other things the disc like mounts
		if not hasValue({248, 402, 424, 437}, mountType) and locked then
			checkBoxFlying:SetAlpha(0.5)
			checkBoxFlying:Disable()
			checkBoxRiding:SetAlpha(0.5)
			checkBoxRiding:Disable()
		end
	end)
	
	hooksecurefunc('MountJournal_UpdateMountList',updateList)
	MountJournal.ScrollBox:HookScript('OnMouseWheel', updateList)
	
	personalMountCount.ground = getLength(personalMountDB.ground)
	personalMountCount.flying = getLength(personalMountDB.flying)
	personalMountCount.riding = getLength(personalMountDB.riding)
	checkBoxCombineSkyridingAndFlying:SetChecked(combineSkyridingAndFlyingFlag)
end

-- checks if both the addon itself and the Blizzard Collections addon are loaded
local function checkInit(self, event, addon)
	if addon == addonName then
		_, isLoaded = C_AddOns.IsAddOnLoaded('Blizzard_Collections')
		if isLoaded then
			initAddon()
			phisFrame:UnregisterEvent('ADDON_LOADED')
		end
	elseif addon == 'Blizzard_Collections' then
		initAddon()
		phisFrame:UnregisterEvent('ADDON_LOADED')
	end
end

-------------------------
--    SLASH COMMANDS   --
-------------------------

SLASH_CFM1 = '/crazyformounts'
SLASH_CFM2 = '/cfm'

SlashCmdList['CFM'] = function(msg)
	local arg1, arg2 = strsplit(' ', msg)
	if arg1:lower() == 'toggle' then
		locked = not locked
		addonPrint('Setting non-flying mounts as flying or Skyriding mounts is now '..(locked and 'locked' or 'unlocked')..'.')
		if MountJournal then
			MountJournal_UpdateMountDisplay(true)
		end
	elseif arg1:lower() == 'lock' then
		locked = true
		addonPrint('Setting non-flying mounts as flying or Skyriding mounts is now locked.')
		if MountJournal then
			MountJournal_UpdateMountDisplay(true)
		end
	elseif arg1:lower() == 'unlock' then
		locked = false
		addonPrint('Setting non-flying mounts as flying or Skyriding mounts is now unlocked.')
		if MountJournal then
			MountJournal_UpdateMountDisplay(true)
		end
	elseif arg1:lower() == 'flying' then
		summonRandom('flying')
	elseif arg1:lower() == 'ground' then
		summonRandom('ground')
	elseif arg1:lower() == 'riding' then
		summonRandom('riding')
	else
		summonRandom()
	end
end


phisFrame:SetScript('OnEvent', checkInit)