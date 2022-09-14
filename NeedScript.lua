-- MyScript
util.keep_running()

util.require_natives(1651208000)
util.require_natives(1627063482)
util.require_natives(1640181023)
util.require_natives(1660775568)

menu.divider(menu.my_root(), "NeedScript v1.0.4")

local auto_update_source_url = "https://raw.githubusercontent.com/nk260203/NeedScript/main/NeedScript.lua"
local status, lib = pcall(require, "auto-updater")
if not status then
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
        function(result, headers, status_code) local error_prefix = "Error downloading auto-updater: "
            if status_code ~= 200 then util.toast(error_prefix..status_code) return false end
            if not result or result == "" then util.toast(error_prefix.."Found empty file.") return false end
            local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
            if file == nil then util.toast(error_prefix.."Could not open file for writing.") return false end
            file:write(result) file:close() util.toast("Successfully installed auto-updater lib")
        end, function() util.toast("Error downloading auto-updater lib. Update failed to download.") end)
    async_http.dispatch() util.yield(3000) require("auto-updater")
end
run_auto_update({source_url=auto_update_source_url, script_relpath=SCRIPT_RELPATH})

local json = require("json")
local vehiclelib = require("jackzvehiclelib")

local veiculo_tab = menu.list(menu.my_root(), "Veículo", {""}, "Um simples menu com opções relacionadas a veículos")

local charset = "QWERTYUIOPASDFGHJKLZXCVBNM12345678901234567890"
function randomString(length)
	local ret = {}
	local r
	for i = 1, length do
		r = math.random(1, #charset)
		table.insert(ret, charset:sub(r, r))
	end
	return table.concat(ret)
end

function saveVehicleJson(vehicle)
	local saveData = vehiclelib.Serialize(vehicle)
	local file = io.open( VEHICLE_DIR .. "vehiclecloneneedscript.json", "w")
	file:write(json.encode(saveData))
	file:close()
end

local dirigirveiculoape
local dirigirveiculoemveiculo
local tipodeplaca
local platetype
menu.action(veiculo_tab, "Clonar veículo", {"clone"}, "Clona seu atual ou último veículo", function()

    local vehicle = entities.get_user_vehicle_as_handle()
	local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
	local player_veh = PED.GET_VEHICLE_PED_IS_USING(ped)

	foot_drive_state = menu.get_value(menu.ref_by_path("Vehicle>Spawner>On Foot Behaviour>Drive Spawned Vehicles"))
	veh_drive_state = menu.get_value(menu.ref_by_path("Vehicle>Spawner>In Vehicle Behaviour>Drive Spawned Vehicles"))
	
	menu.trigger_commands("savevehicle needscriptclone")
	
	if not PED.IS_PED_IN_VEHICLE(ped, player_veh, false) then 
		if dirigirveiculoape then
			menu.set_value(menu.ref_by_path("Vehicle>Spawner>On Foot Behaviour>Drive Spawned Vehicles"), true)
			menu.trigger_commands("vehicleneedscriptclone")
			menu.set_value(menu.ref_by_path("Vehicle>Spawner>On Foot Behaviour>Drive Spawned Vehicles"), foot_drive_state)
		end
	else 
		menu.set_value(menu.ref_by_path("Vehicle>Spawner>In Vehicle Behaviour>Drive Spawned Vehicles"), true)
		menu.trigger_commands("vehicleneedscriptclone")
		menu.set_value(menu.ref_by_path("Vehicle>Spawner>In Vehicle Behaviour>Drive Spawned Vehicles"), veh_drive_state)
	end
	
	if platetype then
		local vehicle = entities.get_user_vehicle_as_handle()
		VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, randomString(8))
	end
	
end)

local clonagem_tab = menu.list(veiculo_tab, "Configurações de clonagem", {""}, "Um menu com configurações de clonagem de veículos")

menu.toggle(clonagem_tab, "A pé, dirigir veículo clonado", { "" }, "Se você estiver a pé, instantaneamente será colocado no controle de veículos clonados", function(on)

    if on then
        dirigirveiculoape = true
    else
        dirigirveiculoape = false
    end
	
end)

menu.toggle(clonagem_tab, "Placa aleatória", { "" }, "Se ativar isso seu carro usando uma placa aleatória", function(on)

    if on then
        platetype = true
    else
        platetype = false
    end
	
end)

menu.toggle(veiculo_tab, "Trancar portas", { "" }, "Tranca as portas do seu atual ou último carro usado", function(on)

	local vehicle = entities.get_user_vehicle_as_handle()

    if on then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 3)
    else
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
    end

end)

local utilsMenu = menu.list(menu.my_root(), "Utilidades", {""}, "Um simples menu de utilidades")
menu.click_slider(utilsMenu, "Remover veículos próximos", {""}, "Remove todos os veículos próximos a você", 500, 100000, 500, 6000, function(range)
    local vehicles = entities.get_all_vehicles_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " veículos removidos")
end)
menu.click_slider(utilsMenu, "Remover objetos próximos", {""}, "Remove todos os objetos próximos a você", 500, 100000, 500, 6000, function(range)
    local vehicles = entities.get_all_objects_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " Objetos removidos")
end)
menu.click_slider(utilsMenu, "Remover pedestres próximos", {""}, "Remove todos os pedestres próximos a você", 500, 100000, 500, 6000, function(range)
    local vehicles = entities.get_all_peds_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " Pedestres removidos")
end)
menu.click_slider(utilsMenu, "Remover todos próximos", {""}, "Remove todos os veículos, objetos e pedestres próximos a você", 500, 100000, 500, 6000, function(range)
	local vehicles = entities.get_all_vehicles_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " veículos removidos")
		local vehicles = entities.get_all_objects_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " Objetos removidos")
    local vehicles = entities.get_all_peds_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " Pedestres removidos")
end)

function _clear_ents(list, range, dryRun)
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    local pos = ENTITY.GET_ENTITY_COORDS(ped, 1)

    local count = 0
    for _, entity in ipairs(list) do
        local pos2 = ENTITY.GET_ENTITY_COORDS(entity, 1)
        local dist = SYSTEM.VDIST(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z)
        if dist <= range then
            util.draw_debug_text(string.format("deleted entity %d - %f m away", entity, dist))
            if not dryRun then
                entities.delete_by_handle(entity)
            end
            count = count + 1
        end
    end
    return count
end

