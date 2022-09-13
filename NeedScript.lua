-- MyScript
util.keep_running()

util.require_natives(1651208000)
util.require_natives(1627063482)
util.require_natives(1640181023)
util.require_natives(1660775568)

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

local veiculo_tab = menu.list(menu.my_root(), "Veículo2")

local VEHICLE_DIR = filesystem.stand_dir() .. "Vehicles" .. package.config:sub(1,1)
if not filesystem.exists(VEHICLE_DIR) then
    filesystem.mkdir(VEHICLE_DIR)
end

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
	local my_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
	local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
	local player_veh = PED.GET_VEHICLE_PED_IS_USING(ped)
	local position = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(my_ped, 0.0, 6.5, 0.5)
	local heading = ENTITY.GET_ENTITY_HEADING(my_ped)
	
	saveVehicleJson(vehicle)
	
	local file = io.open( VEHICLE_DIR .. "vehiclecloneneedscript.json", "r")
	local saveData = json.decode(file:read("*a"))
	
	vehicle = entities.create_vehicle(saveData.Model, position, heading)
	vehiclelib.ApplyToVehicle(vehicle, saveData)
	
	if platetype then
		VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, randomString(8))
	end
	
	if not PED.IS_PED_IN_VEHICLE(ped, player_veh, false) then 
		if dirigirveiculoape then
			PED.SET_PED_INTO_VEHICLE(my_ped, vehicle, -1)
		end
	else 
		if dirigirveiculoemveiculo then
			PED.SET_PED_INTO_VEHICLE(my_ped, vehicle, -1)
		end
	end
	file:close()
end)

local clonagem_tab = menu.list(veiculo_tab, "Configurações de clonagem")

menu.toggle(clonagem_tab, "A pé, dirigir veículo clonado", { "" }, "Se você estiver a pé, instantaneamente será colocado no controle de veículos clonados", function(on)

    if on then
		util.toast("true")
        dirigirveiculoape = true
    else
        dirigirveiculoape = false
    end
	
end)

menu.toggle(clonagem_tab, "Em veículo, dirigir veículo clonado", { "" }, "Se você estiver em um veículo, instantaneamente será colocado no controle de veículos clonados", function(on)

    if on then
        dirigirveiculoemveiculo = true
    else
        dirigirveiculoemveiculo = false
    end
	
end)

menu.toggle(clonagem_tab, "Placa aleatória", { "" }, "Se ativar isso seu carro usando uma placa aleatória", function(on)

    if on then
        platetype = true
    else
        platetype = false
    end
	
end)