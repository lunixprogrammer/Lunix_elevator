local elevators = {}

MySQL.ready(function()
    -- Création table si inexistante
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `elevators` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) DEFAULT NULL,
            `job` varchar(50) DEFAULT 'none',
            `floors` longtext DEFAULT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    Wait(500)
    loadElevators()
end)

function loadElevators()
    MySQL.query('SELECT * FROM elevators', {}, function(result)
        elevators = {}
        if result then
            for _, row in ipairs(result) do
                elevators[row.id] = {
                    name = row.name,
                    job = row.job,
                    floors = json.decode(row.floors)
                }
            end
        end
        TriggerClientEvent('lunix_elevator:receiveElevators', -1, elevators)
        print('^2[Elevators] ^7' .. table.count(elevators) .. ' ascenseurs chargés.')
    end)
end

RegisterNetEvent('lunix_elevator:requestElevators', function()
    local src = source
    TriggerClientEvent('lunix_elevator:receiveElevators', src, elevators)
end)

RegisterNetEvent('lunix_elevator:create', function(data)
    local src = source
    if not IsPlayerAdmin(src) then 
        print("^1[Elevators] Tentative de création d'ascenseur sans permission: " .. src .. "^7")
        return 
    end

    MySQL.insert('INSERT INTO elevators (name, job, floors) VALUES (?, ?, ?)', {
        data.name,
        data.job,
        json.encode(data.floors)
    }, function(id)
        if id then
            loadElevators() -- Recharge et sync tout le monde
            TriggerClientEvent('lunix_elevator:created', src)
        end
    end)
end)

RegisterNetEvent('lunix_elevator:updateJob', function(id, job)
    local src = source
    if not IsPlayerAdmin(src) then return end

    MySQL.update('UPDATE elevators SET job = ? WHERE id = ?', {job, id}, function(affectedRows)
        if affectedRows > 0 then
            loadElevators()
            TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Job mis à jour'})
        else
            TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Erreur lors de la mise à jour'})
        end
    end)
end)

RegisterNetEvent('lunix_elevator:addFloor', function(id, floorData)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local elevator = elevators[id]
    if not elevator then return end

    local floors = elevator.floors
    table.insert(floors, floorData)

    MySQL.update('UPDATE elevators SET floors = ? WHERE id = ?', {json.encode(floors), id}, function(affectedRows)
        if affectedRows > 0 then
            loadElevators()
            TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Étage ajouté'})
        end
    end)
end)

RegisterNetEvent('lunix_elevator:editFloor', function(id, floorIndex, floorData)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local elevator = elevators[id]
    if not elevator or not elevator.floors[floorIndex] then return end

    -- Mise à jour des données
    if floorData.label then elevator.floors[floorIndex].label = floorData.label end
    if floorData.coords then elevator.floors[floorIndex].coords = floorData.coords end
    if floorData.heading then elevator.floors[floorIndex].heading = floorData.heading end

    MySQL.update('UPDATE elevators SET floors = ? WHERE id = ?', {json.encode(elevator.floors), id}, function(affectedRows)
        if affectedRows > 0 then
            loadElevators()
            TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Étage modifié'})
        end
    end)
end)

RegisterNetEvent('lunix_elevator:deleteFloor', function(id, floorIndex)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local elevator = elevators[id]
    if not elevator or not elevator.floors[floorIndex] then return end

    table.remove(elevator.floors, floorIndex)

    -- Si moins de 2 étages, on pourrait avertir, mais on laisse faire pour la flexibilité
    
    MySQL.update('UPDATE elevators SET floors = ? WHERE id = ?', {json.encode(elevator.floors), id}, function(affectedRows)
        if affectedRows > 0 then
            loadElevators()
            TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Étage supprimé'})
        end
    end)
end)

RegisterNetEvent('lunix_elevator:delete', function(id)
    local src = source
    if not IsPlayerAdmin(src) then return end

    MySQL.update('DELETE FROM elevators WHERE id = ?', {id}, function(affectedRows)
        if affectedRows > 0 then
            loadElevators()
            TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Ascenseur supprimé'})
        else
            TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Erreur lors de la suppression'})
        end
    end)
end)

function IsPlayerAdmin(source)
    -- Vérification Ace
    if IsPlayerAceAllowed(source, 'command.createelevator') then return true end
    
    -- Vérification Qbox Groups
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    
    for _, group in ipairs(Config.AdminGroups) do
        if player.PlayerData.groups[group] then return true end
    end
    
    return false
end

-- Helper pour compter la table
function table.count(t)
    local c = 0
    for _ in pairs(t) do c = c + 1 end
    return c
end
