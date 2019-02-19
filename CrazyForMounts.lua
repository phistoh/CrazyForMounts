local addonName, phis = ...

local phisFrame = CreateFrame('Frame', 'phisCheckFrame', UIParent)
phisFrame:RegisterEvent('ADDON_LOADED')


local function summonRandom()
	-- if the player is currently mounted - dismount them
	if IsMounted() then
		Dismount()
		return
	end
	
	-- test if the user can fly in the current zone and set the correct list of mounts
	-- (some areas return wrong value)
	local canFly = (IsFlyableArea() and UnitLevel("player") >= 60)
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
		print('No personal '..(canFly and 'flying' or 'ground')..' mounts set.')
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

-- attaches '*' to every mount in personalMountDB
local function updateMountList()
	local scrollFrame = MountJournal.ListScrollFrame
	local buttons = scrollFrame.buttons
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local numMounts = C_MountJournal.GetNumDisplayedMounts()
	
	for i=1, #buttons do
		button = buttons[i]
		displayIndex = i + offset
		if displayIndex <= numMounts and numMounts > 0 then
			creatureName, _, _, _, _, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(displayIndex)
			if personalMountDB.ground[mountID] then
				creatureName = creatureName..' *'
			end
			if personalMountDB.flying[mountID] then
				creatureName = creatureName..' +'
			end
			button.name:SetText(creatureName)
		end
	end
end

local function initAddon()
	--- SETUP VARIABLES ---
	
	if personalMountDB == nil then
		personalMountDB = {ground = {}, flying = {}}
	end
	
	if personalMountCount == nil then
		personalMountCount = {ground = 0, flying = 0}
	end

	--- CREATE AND ATTACH FRAMES ---
	
	-- number of selected ground mounts	
	local groundMountInset = CreateFrame('Frame', 'groundMountInset', MountJournal, 'InsetFrameTemplate3')
	groundMountInset:SetSize(100,20)
	groundMountInset:SetPoint('BOTTOMRIGHT', -7, 5)
	local groundMountLabel = groundMountInset:CreateFontString('groundMountLabelFontString', 'ARTWORK', 'GameFontHighlightSmall')
	groundMountLabel:SetPoint('RIGHT', -10, 0)
	groundMountLabel:SetJustifyH('RIGHT')
	groundMountLabel:SetText(personalMountCount.ground)
	local groundMountCount = groundMountInset:CreateFontString('groundMountCountFontString', 'ARTWORK', 'GameFontNormalSmall')
	groundMountCount:SetPoint('LEFT', 10, 0)
	groundMountCount:SetPoint('RIGHT', groundMountLabel, 'LEFT', -3, 0)
	groundMountCount:SetJustifyH('LEFT')
	groundMountCount:SetText('Ground: ')
	
	-- number of selected flying mounts
	local flyingMountInset = CreateFrame('Frame', 'flyingMountInset', MountJournal, 'InsetFrameTemplate3')
	flyingMountInset:SetSize(100,20)
	flyingMountInset:SetPoint('RIGHT', groundMountInset, 'LEFT', -10, 0)
	local flyingMountLabel = flyingMountInset:CreateFontString('groundMountLabelFontString', 'ARTWORK', 'GameFontHighlightSmall')
	flyingMountLabel:SetPoint('RIGHT', -10, 0)
	flyingMountLabel:SetJustifyH('RIGHT')
	flyingMountLabel:SetText(personalMountCount.flying)
	local flyingMountCount = flyingMountInset:CreateFontString('groundMountCountFontString', 'ARTWORK', 'GameFontNormalSmall')
	flyingMountCount:SetPoint('LEFT', 10, 0)
	flyingMountCount:SetPoint('RIGHT', flyingMountLabel, 'LEFT', -3, 0)
	flyingMountCount:SetJustifyH('LEFT')
	flyingMountCount:SetText('Flying: ')
	
	-- checkbox for ground mounts
	local checkBoxGround = CreateFrame('CheckButton', 'CrazyForMountsCheckBoxGround', MountJournal.MountDisplay, 'UICheckButtonTemplate')
	checkBoxGround:SetPoint('TOPRIGHT', MountJournal.MountDisplay, 'BOTTOMRIGHT', -10, 50)
	checkBoxGround.tooltip = 'Add this mount to your personal list of ground mounts'
	checkBoxGround:SetScript('OnClick', function()
		local checked = checkBoxGround:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local mountID = MountJournal.selectedMountID
		updateDB(mountID, false, checked)
		groundMountLabel:SetText(personalMountCount.ground)
		updateMountList()
	end)
	checkBoxGround:SetScript('OnEnter', function()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetPoint('BOTTOMRIGHT', checkBoxGround, 'TOPRIGHT', 0, 0);
		GameTooltip:SetText('Add this mount to your personal ground mounts')
		GameTooltip:Show()
	end)
	checkBoxGround:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
	
	-- checkbox for flying mounts
	local checkBoxFlying = CreateFrame('CheckButton', 'CrazyForMountsCheckBoxFlying', MountJournal.MountDisplay, 'UICheckButtonTemplate')
	checkBoxFlying:SetPoint('RIGHT', checkBoxGround, 'LEFT', -10, 0)
	checkBoxFlying:SetScript('OnClick', function()
		local checked = checkBoxFlying:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local mountID = MountJournal.selectedMountID
		updateDB(mountID, true, checked)
		flyingMountLabel:SetText(personalMountCount.flying)
		updateMountList()
	end)
	checkBoxFlying:SetScript('OnEnter', function()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetPoint('BOTTOMRIGHT', checkBoxFlying, 'TOPRIGHT', 0, 0);
		GameTooltip:SetText('Add this mount to your personal flying mounts')
		GameTooltip:Show()
	end)
	checkBoxFlying:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
	
	hooksecurefunc('MountJournal_UpdateMountDisplay', function()
		local mountID = MountJournal.selectedMountID
		checkBoxGround:SetChecked(personalMountDB.ground[mountID] == true)
		checkBoxFlying:SetChecked(personalMountDB.flying[mountID] == true)
		local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		checkBoxFlying:Enable()
		checkBoxFlying:SetAlpha(1)
		if mountType ~= 248 then
			checkBoxFlying:SetAlpha(0.5)
			checkBoxFlying:Disable()
		end
	end)
	
	hooksecurefunc('MountJournal_UpdateMountList', updateMountList)
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

SLASH_CFM1 = '/crazyformounts'
SLASH_CFM2 = '/cfm'

SlashCmdList['CFM'] = function(msg)
	summonRandom()
end


phisFrame:SetScript('OnEvent', checkInit)