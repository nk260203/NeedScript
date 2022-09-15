-- NeedScript

-- Requerimentos
util.require_natives("natives-1660775568-uno")
util.require_natives(1651208000)
util.require_natives(1627063482)
util.require_natives(1640181023)
util.require_natives(1660775568)

-- Mensagem de Bem-vindo
util.toast("Obrigado por usar NeedScript =)")

-- Procurar por atualizações
local response = false
local localVer = 1.6
async_http.init("raw.githubusercontent.com", "/nk260203/NeedScript/main/NeedScriptVersion", function(output)
    currentVer = tonumber(output)
    response = true
    if localVer ~= currentVer then
        util.toast("Uma nova versão do NeedScript está disponível, atualize o lua para ter a versão mais recente.")
        menu.action(menu.my_root(), "Atualizar Lua (v" .. localVer .. " -> v" .. currentVer .. ")", {}, "", function()
            async_http.init('raw.githubusercontent.com','/nk260203/NeedScript/main/NeedScript.lua',function(a)
                local err = select(2,load(a))
                if err then
                    util.toast("Falha no download do script. Por favor, tente novamente mais tarde. Se isso continuar acontecendo, atualize manualmente via github.")
                return end
                local f = io.open(filesystem.scripts_dir()..SCRIPT_RELPATH, "wb")
                f:write(a)
                f:close()
                util.toast("NeedScript atualizado com sucesso, reinicie o script! :)")
                util.stop_script()
            end)
            async_http.dispatch()
        end)
    end
end, function() response = true end)
async_http.dispatch()
repeat 
    util.yield()
until response

-- Criação de abas

voce_root = menu.list(menu.my_root(), "Você", {""}, "Um simples menu com opções relacionadas a você")

armas_root = menu.list(menu.my_root(), "Armas", {""}, "Um simples menu com opções relacionadas a armas")

veiculo_root = menu.list(menu.my_root(), "Veículo", {""}, "Um simples menu com opções relacionadas a veículos")
clonagem_root = menu.list(veiculo_root, "Configurações de clonagem", {""}, "Um menu com configurações de clonagem de veículos")

online_root = menu.list(menu.my_root(), "Online", {""}, "Um simples menu com opções relacionadas ao online")

mundo_root = menu.list(menu.my_root(), "Mundo", {""}, "Um simples menu com opções relacionadas ao mundo")

utilidade_root = menu.list(menu.my_root(), "Utilidades", {""}, "Um simples menu com opções que podem ser útil")

sobre_root = menu.list(menu.my_root(), "Sobre", {""}, "Um simples menu com informações sobre o script")

local caracteres = "QWERTYUIOPASDFGHJKLZXCVBNM12345678901234567890"
function placaAleatoria(length)
	local ret = {}
	local r
	for i = 1, length do
		r = math.random(1, #charset)
		table.insert(ret, charset:sub(r, r))
	end
	return table.concat(ret)
end

function deletar_entidades(list, range, dryRun)
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

-- function clonar_veiculo
-- end

-- Aba de configurações de clonagem de veículo
menu.toggle(clonagem_root, "A pé, dirigir veículo clonado", { "" }, "Se você estiver a pé, instantaneamente será colocado no controle de veículos clonados", function(on)
    if on then
        dirigirveiculoape = true
    else
        dirigirveiculoape = false
    end
end)

menu.toggle(clonagem_root, "Placa aleatória", { "" }, "Se ativar isso seu carro usando uma placa aleatória", function(on)
    if on then
        platetype = true
    else
        platetype = false
    end
end)

-- Aba de veículos
local dirigirveiculoape
local platetype
menu.action(veiculo_root, "Clonar veículo", {"clone"}, "Clona seu atual ou último veículo", function()
    local vehicle = entities.get_user_vehicle_as_handle()
	local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
	local player_veh = PED.GET_VEHICLE_PED_IS_USING(ped)
	local foot_drive_state = menu.get_value(menu.ref_by_path("Vehicle>Spawner>On Foot Behaviour>Drive Spawned Vehicles"))
	local veh_drive_state = menu.get_value(menu.ref_by_path("Vehicle>Spawner>In Vehicle Behaviour>Drive Spawned Vehicles"))
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

menu.toggle(veiculo_root, "Trancar portas", { "" }, "Tranca as portas do seu atual ou último carro usado", function(on)
	local vehicle = entities.get_user_vehicle_as_handle()
    if on then
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 3)
    else
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 1)
    end
end)

-- Aba de ultilidade
menu.click_slider(utilidade_root, "Remover veículos próximos", {""}, "Remove todos os veículos próximos a você", 500, 100000, 500, 6000, function(range)
    local vehicles = entities.get_all_vehicles_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " veículos removidos")
end)

menu.click_slider(utilidade_root, "Remover objetos próximos", {""}, "Remove todos os objetos próximos a você", 500, 100000, 500, 6000, function(range)
    local vehicles = entities.get_all_objects_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " Objetos removidos")
end)

menu.click_slider(utilidade_root, "Remover pedestres próximos", {""}, "Remove todos os pedestres próximos a você", 500, 100000, 500, 6000, function(range)
    local vehicles = entities.get_all_peds_as_handles()
    local count = _clear_ents(vehicles, range)
    util.toast(count .. " Pedestres removidos")
end)

menu.click_slider(utilidade_root, "Remover todos próximos", {""}, "Remove todos os veículos, objetos e pedestres próximos a você", 500, 100000, 500, 6000, function(range)
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

-- Aba de sobre
menu.hyperlink(sobre_root, "GitHub", "https://github.com/nk260203/NeedScript")
menu.readonly(sobre_root, "Versão atual", "v" .. localVer)
menu.action(sobre_root, "Verificar atualizações", {"needscriptcheckupdate"}, "Verifica se existe alguma atualização pendente", function()
	async_http.init("raw.githubusercontent.com", "/nk260203/NeedScript/main/NeedScriptVersion", function(output)
		currentVer = tonumber(output)
		response = true
		if localVer ~= currentVer then
			util.toast("Uma nova versão do NeedScript está disponível, atualize o lua para ter a versão mais recente.")
			menu.action(sobre_root, "Atualizar Lua (v" .. localVer .. " -> v" .. currentVer .. ")", {}, "", function()
				async_http.init('raw.githubusercontent.com','/nk260203/NeedScript/main/NeedScript.lua',function(a)
					local err = select(2,load(a))
					if err then
						util.toast("Falha no download do script. Por favor, tente novamente mais tarde. Se isso continuar acontecendo, atualize manualmente via github.")
					return end
					local f = io.open(filesystem.scripts_dir()..SCRIPT_RELPATH, "wb")
					f:write(a)
					f:close()
					util.toast("NeedScript atualizado com sucesso, reinicie o script! :)")
					util.stop_script()
				end)
				async_http.dispatch()
			end)
		else
			util.toast("Nenhuma atualização foi encontrada")
		end
	end, function() response = true end)
	async_http.dispatch()
	repeat 
		util.yield()
	until response
end)


-- Fim
util.keep_running()