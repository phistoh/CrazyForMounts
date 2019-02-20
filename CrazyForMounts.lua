local addonName, phis = ...

local phisFrame = CreateFrame('Frame', 'phisCheckFrame', UIParent)
phisFrame:RegisterEvent('ADDON_LOADED')

-- controls whether non-flying mounts can be added to the table of flying mounts
local locked = true

-------------------------
--   AUXILIARY STUFF   --
-------------------------

function phis.getLength(tbl)
	length = 0
	for k,v in pairs(tbl) do
		length = length + 1
	end
	return length
end

function phis.print(str)
	print('|cFF40C7EBCrazy for Mounts:|r '..str)
end

-- checks whether the player can actually fly
function phis.IsFlyableArea()
	-- default WoW check
	if not IsFlyableArea() then
		return false
	-- flying requires Level 60
	elseif UnitLevel("player") < 60 then
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
	
	newCheckbox:SetScript('OnEnter', function()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetPoint('BOTTOMRIGHT', newCheckbox, 'TOPRIGHT', 0, 0);
		GameTooltip:SetText(tooltip)
		GameTooltip:Show()
	end)
	
	newCheckbox:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
	
	newCheckbox.background = newCheckbox:CreateTexture(nil, 'BACKGROUND')
	newCheckbox.background:SetWidth(20)
	newCheckbox.background:SetHeight(20)
	newCheckbox.background:SetTexture(bgPath)
	newCheckbox.background:SetPoint('CENTER',newCheckbox)

	return newCheckbox
end

-------------------------
--   ADDON FUNCTIONS   --
-------------------------

local function summonRandom(mountType)
	-- if the player is currently mounted - dismount them
	if IsMounted() then
		Dismount()
		return
	end
	
	
	-- if mountType is nil select the appropriate mount table
	-- else select the table corresponding to the given argument
	local canFly = false
	if mountType == nil then
		canFly = phis.IsFlyableArea()
	else if mountType == 'flying' then
		canFly = true
	end
	
	if canFly then
		tmpCount = personalMountCount.flying
		tmpMountDB = personalMountDB.flying
	else
		tmpCount = personalMountCount.ground
		tmpMountDB = personalMountDB.ground
	end
	
	-- add all mounts from the chosen table to an (ordinary) array to make unpack() work
	if tmpCount > 0 then
		local tmpIDs = {}
		for k in pairs(tmpMountDB) do
			table.insert(tmpIDs, k)
		end
		local mountID = GetRandomArgument(unpack(tmpIDs))
		C_MountJournal.SummonByID(mountID)
	else
		phis.print('No personal '..(canFly and 'flying' or 'ground')..' mounts set.')
	end
end

-- mountIDs are used as keys for more efficient lookup
local function updateDB(mountID, flyable, addMount)
	mountType = flyable and 'flying' or 'ground'
	if addMount and personalMountDB[mountType][mountID] == nil then
		personalMountDB[mountType][mountID] = true
		personalMountCount[mountType] = personalMountCount[mountType] + 1
	elseif not addMount and personalMountDB[mountType][mountID] ~= nil then
		personalMountDB[mountType][mountID] = nil
		personalMountCount[mountType] = math.max(personalMountCount[mountType] - 1, 0)
	end
end

-- -- attaches icons to every mount in personalMountDB
-- local function updateMountList()
	-- local scrollFrame = MountJournal.ListScrollFrame
	-- local buttons = scrollFrame.buttons
	-- local offset = HybridScrollFrame_GetOffset(scrollFrame)
	-- local numMounts = C_MountJournal.GetNumDisplayedMounts()
	
	-- for i=1, #buttons do
		-- button = buttons[i]
		
		-- button.personalFavoriteGround = button:CreateTexture(nil, 'OVERLAY')
		-- button.personalFavoriteGround:Hide()
		-- button.personalFavoriteGround:SetTexture('Interface\\MINIMAP\\TRACKING\\StableMaster')
		-- button.personalFavoriteGround:SetSize(22,22)
		-- button.personalFavoriteGround:SetPoint('CENTER', button, 'TOPRIGHT', -12, -12)
		
		-- displayIndex = i + offset
		-- if displayIndex <= numMounts and numMounts > 0 then
			-- _, _, _, _, _, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(displayIndex)
			-- if personalMountDB.ground[mountID] then
				-- button.personalFavoriteGround:Show()
			-- else
				-- button.personalFavoriteGround:Hide()
			-- end
			-- if personalMountDB.flying[mountID] then
				-- 
			-- end
		-- else
			-- button.personalFavoriteGround:Hide()
		-- end
	-- end
	-- local MOUNT_BUTTON_HEIGHT = 46
	-- local totalHeight = numMounts * MOUNT_BUTTON_HEIGHT
	-- HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())
-- end

local function initAddon()
	--- SETUP VARIABLES ---
	
	if personalMountDB == nil then
		personalMountDB = {ground = {}, flying = {}}
	end
	
	if personalMountCount == nil then
		personalMountCount = {ground = 0, flying = 0}
		local playerName, playerRealm = UnitFullName('player')
		local _, playerClass = UnitClass('player')
		local _, _, _, classColor = GetClassColor(playerClass)
		phis.print('Addon loaded for the first time on |c'..classColor..playerName..'|r-'..playerRealm..'.')
	end

	--- CREATE AND ATTACH FRAMES ---
	local groundMountInset = createInset('groundMountInset', MountJournal, 100, 20, 'BOTTOMRIGHT', -7, 5, 'Ground: ', personalMountCount.ground)
	local flyingMountInset = createInset('flyingMountInset', groundMountInset, 100, 20, 'LEFT', -110, 0, 'Flying: ', personalMountCount.flying)
	
	local checkBoxGround = createCheckbox('CrazyForMountsCheckBoxGround', MountJournal.MountDisplay, 'TOPRIGHT', MountJournal.MountDisplay, 'BOTTOMRIGHT', -10, 50, 'Add this mount to your personal ground mounts', 'Interface\\Addons\\CrazyForMount\\Icons\\horse.tga')
	checkBoxGround:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local mountID = MountJournal.selectedMountID
		updateDB(mountID, false, checked)
		groundMountInset.content:SetText(personalMountCount.ground)
		-- updateMountList()
	end)
	
	local checkBoxFlying = createCheckbox('CrazyForMountsCheckBoxFlying', MountJournal.MountDisplay, 'RIGHT', checkBoxGround, 'LEFT', -10, 0, 'Add this mount to your personal flying mounts', 'Interface\\Addons\\CrazyForMount\\Icons\\bird.tga')
	checkBoxFlying:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local mountID = MountJournal.selectedMountID
		updateDB(mountID, true, checked)
		flyingMountInset.content:SetText(personalMountCount.flying)
		-- updateMountList()
	end)
	
	hooksecurefunc('MountJournal_UpdateMountDisplay', function()
		local mountID = MountJournal.selectedMountID
		checkBoxGround:SetChecked(personalMountDB.ground[mountID] == true)
		checkBoxFlying:SetChecked(personalMountDB.flying[mountID] == true)
		local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		checkBoxFlying:Enable()
		checkBoxFlying:SetAlpha(1)
		if mountType ~= 248 and locked then
			checkBoxFlying:SetAlpha(0.5)
			checkBoxFlying:Disable()
		end
	end)
	
	-- hooksecurefunc('MountJournal_UpdateMountList', updateMountList)
	
	personalMountCount.ground = phis.getLength(personalMountDB.ground)
	personalMountCount.flying = phis.getLength(personalMountDB.flying)
end

-- checks if both the addon itself and the Blizzard Collections addon are loaded
local function checkInit(self, event, addon)
	if addon == addonName then
		if IsAddOnLoaded('Blizzard_Collections') then
			initAddon()
			phisFrame:UnregisterEvent('ADDON_LOADED')
		end
	elseif addon == 'Blizzard_Collections' then
		initAddon()
		phisFrame:UnregisterEvent('ADDON_LOADED')
	end
end

-------------------------
--   DEBUG FUNCTIONS   --
-------------------------
local function copyFromOldVersion(tbl)
	local numCopiedMounts = 0
	
	-- generate tables where mount names are keys
	local tmpFlying = {}
	local tmpGround = {}
	for k,v in pairs(tbl[1]) do
		tmpFlying[v] = true
	end
	for k,v in pairs(tbl[2]) do
		tmpGround[v] = true
	end
	
	mountIDTable = C_MountJournal.GetMountIDs()
	
	for mount in pairs(mountIDTable) do
		mountName = C_MountJournal.GetMountInfoByID(mount)
		if tmpFlying[mountName] then
			updateDB(mount, true, true)
		end
		if tmpGround[mountName] then
			updateDB(mount, false, true)
		end
		numCopiedMounts = numCopiedMounts + 1
	end

	phis.print(numCopiedMounts..' copied from old table.')
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
		phis.print('Setting non-flying mounts as flying mounts is now '..(locked and 'locked' or 'unlocked')..'.')
		MountJournal_UpdateMountDisplay()
	elseif arg1:lower() == 'lock' then
		locked = true
		phis.print('Setting non-flying mounts as flying mounts is now locked.')
		MountJournal_UpdateMountDisplay()
	elseif arg1:lower() == 'unlock' then
		locked = false
		phis.print('Setting non-flying mounts as flying mounts is now unlocked.')
		MountJournal_UpdateMountDisplay()
	elseif arg1:lower() == 'flying' then
		summonRandom('flying')
	elseif arg1:lower() == 'ground' then
		summonRandom('ground')	
	-- DEBUG
	elseif arg1:lower() == 'copy' then
		if mount_tables and mount_tables[arg2:lower()] then
			copyFromOldVersion(mount_tables[arg2:lower()])
		else
			phis.print('Table "'..arg2..'" is nil.')
		end
	-- DEBUG END
	else
		summonRandom()
	end
end


phisFrame:SetScript('OnEvent', checkInit)