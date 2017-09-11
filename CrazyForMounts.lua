-- define the slash commands
SLASH_CFM1 = "/crazyformounts"
SLASH_CFM2 = "/cfm"

-- get a table of every mountID
mount_id_table =  C_MountJournal.GetMountIDs()

SlashCmdList["CFM"] = function(args)
	-- if the player is currently mounted - dismount him
	if IsMounted() then
		Dismount()
		return
	end

	-- boolean variable for error handling
	mount_found = false
	
	-- test if the user can fly in the current zone
	canFly = (IsFlyableArea() and UnitLevel("player") >= 60)
	
	-- if no argument was given, just use "hestah"
	if args == "" or args == nil then
		print("Usage: /cfm name_of_table")
		return
	end
	
	-- get the corresponding table
	local table_of_mount_names = mount_tables[args:lower()]
	
	-- if the user can fly get the table of flying mounts
	if canFly == true then
		table_of_mount_names = table_of_mount_names[1]
	-- else get the other table
	else
		table_of_mount_names = table_of_mount_names[2]
	end
	-- if there is no such table return an error
	if table_of_mount_names == nil then
		print("Table " .. args .. " is nil. :(")
		return
	end
	
	-- select a random mount from the corresponding list in the Tables-file
	local mount_to_summon = GetRandomArgument(unpack(table_of_mount_names))
	
	-- iterate over the table of all mountIDs
	for _, mount_id in ipairs(mount_id_table) do
		-- get the name of the mount in the table
		name_of_mount, _, _, _, _, _, _, _, _, _, learned = C_MountJournal.GetMountInfoByID(mount_id)
		-- if the name matches the randomly selected mount
		if name_of_mount == mount_to_summon and learned then
			-- summon it
			C_MountJournal.SummonByID(mount_id)
			-- declare that the mount was in the table
			mount_found = true
			break
		end
	end
	if mount_found == false then
		print(mount_to_summon .. " is not in the table.")
	end
end