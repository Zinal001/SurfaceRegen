function HideSurfaceGenerationGUI(player)
	if player.gui.center.frameSurfaceRegenIn ~= nil then
		player.gui.center.frameSurfaceRegenIn.destroy()
	end
end

function ShowSurfaceGenerationGUI(player)
	
	if player.gui.center.frameSurfaceRegenIn == nil then
		player.gui.center.add({
			type = "frame",
			name = "frameSurfaceRegenIn",
			caption = "Warning",
			direction = "vertical"
		})
	end
	
	if player.gui.center.frameSurfaceRegenIn.lblSurfaceRegenIn == nil then
		player.gui.center.frameSurfaceRegenIn.add({
			type = "label",
			name = "lblSurfaceRegenIn",
			caption = "Surface regeneration in " .. global.countdown .. " seconds"
		})		
	else
		player.gui.center.frameSurfaceRegenIn.lblSurfaceRegenIn.caption = "Surface regeneration in " .. global.countdown .. " seconds"
	end
	
	if player.gui.center.frameSurfaceRegenIn.lblSurfaceRegenWarning == nil then
		player.gui.center.frameSurfaceRegenIn.add({
			type = "label",
			name = "lblSurfaceRegenWarning",
			caption = "Warning: This might cause some lag",
			style = "menu_message_style"
		})
	end
	
end

function HideSurfaceGUI(player)
	if player.gui.center.frameSurfaceGen ~= nil then
		player.gui.center.frameSurfaceGen.destroy()
	end
end

function CreateSurfaceGUI(player)

	HideSurfaceGUI(player)
	
	local win = player.gui.center.add({
		type = "frame",
		name = "frameSurfaceGen",
		caption = "Surface Regenerator",
		direction = "vertical"
	})
	
	local mainTbl = win.add({
		type = "table",
		name = "tblSurfaceGen_main",
		colspan = 2
	})
	
	mainTbl.add({
		type = "checkbox",
		name = "cbSurfaceGUI_regenerate_enemies",
		caption = "Regenerate enemies",
		state = false
	})
	
	mainTbl.add({ type = "flow" })
	
	mainTbl.add({
		type = "button",
		name = "btnSurfaceGUI_close",
		caption = "Close"
	})
	
	mainTbl.add({
		type = "button",
		name = "btnSurfaceGUI_regenerate",
		caption = "Regenerate"
	})
	
end

function on_tick(event)
	if global.countdown ~= nil and (event.tick - global.tickstart) % 60 == 0 then
	
		if global.countdown > 0 then
			for i, p in pairs(game.players) do
				ShowSurfaceGenerationGUI(p)
			end
			global.countdown = global.countdown - 1
		else
			local surface = game.surfaces[global.regeneration_surface]
			local autoplace_entities = {}
			
			for name, ent in pairs(game.entity_prototypes) do
				if ent.autoplace_specification ~= nil then
					if (ent.autoplace_specification.force == "enemy" and global.regenerate_enemies) or (ent.autoplace_specification.force ~= "enemy") then
						table.insert(autoplace_entities, name)
					end
				end
			end
			
			local player = game.players[global.regeneration_playerindex]
			
			
			if surface ~= nil and surface.valid then
				surface.regenerate_entity(autoplace_entities)
				game.print("Regenerated " .. #autoplace_entities .. " entity prototypes on explored chunks on surface " .. surface.name)
			elseif player ~= nil and player.valid then
				player.print("Error: Surface " .. global.regeneration_surface .. "doesn't appear to exist anymore")
			else
				game.print("Error: Surface " .. global.regeneration_surface .. "doesn't appear to exist anymore")
			end
			
			global.regeneration_surface = nil
			global.regenerate_enemies = nil
			global.countdown = nil
			global.tickstart = nil
			
			for i, p in pairs(game.players) do
				HideSurfaceGenerationGUI(p)
			end
			
		end
	
	end
end

function on_gui_click(event)
	local player = game.players[event.player_index]
	
	local elm = event.element
	
	if elm.name == "btnSurfaceGUI_close" then
		HideSurfaceGUI(player)
	elseif elm.name == "btnSurfaceGUI_regenerate" then
		global.regenerate_enemies = player.gui.center.frameSurfaceGen.tblSurfaceGen_main.cbSurfaceGUI_regenerate_enemies.state
		global.regeneration_surface = player.surface.name
		global.countdown = 10
		global.tickstart = event.tick
		global.regeneration_playerindex = player.index
		game.print("Warning: " .. player.name .. " is regenerating surface " .. player.surface.name .. " in 10 seconds. This might cause some lag")
		
		HideSurfaceGUI(player)
		
		for i, p in pairs(game.players) do
			ShowSurfaceGenerationGUI(p)
		end
	end
end

function On_Show_SurfaceGen_GUI(event)
	
	local player = game.players[event.player_index]
	
	if player.admin then
		CreateSurfaceGUI(player)
	else
		player.print("Error: Only admins are allowed to use this command")
	end
	
end

script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event("Show-SurfaceGen-GUI", On_Show_SurfaceGen_GUI)