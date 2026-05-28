local elevators = {}
local currentElevatorId = nil

-- Initialisation
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('lunix_elevator:requestElevators')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    TriggerServerEvent('lunix_elevator:requestElevators')
end)

RegisterNetEvent('lunix_elevator:receiveElevators', function(data)
    elevators = data
    refreshElevatorTargets()
end)

RegisterNetEvent('lunix_elevator:created', function()
    lib.notify({ type = 'success', description = Config.Locales.elevator_created })
    TriggerServerEvent('lunix_elevator:requestElevators')
end)

function refreshElevatorTargets()
    -- Si on utilise ox_target, on nettoie d'abord (si nécessaire, mais ox_target gère bien les doublons si on utilise des noms uniques)
    -- Pour simplifier, on suppose que ox_target est utilisé
    
    if Config.UseTarget then
        for id, elevator in pairs(elevators) do
            for i, floor in ipairs(elevator.floors) do
                exports.ox_target:addBoxZone({
                    coords = vec3(floor.coords.x, floor.coords.y, floor.coords.z + 1.0),
                    size = vec3(1, 1, 2),
                    rotation = floor.heading or 0,
                    debug = false,
                    options = {
                        {
                            name = 'elevator_' .. id .. '_' .. i,
                            icon = 'fa-solid fa-elevator',
                            label = Config.Locales.open_elevator,
                            onSelect = function()
                                openElevatorUI(id, i)
                            end
                        }
                    }
                })
            end
        end
    end
end

-- Thread pour TextUI si Target désactivé
if not Config.UseTarget then
    CreateThread(function()
        local textUiShown = false
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local nearby = false
            
            for id, elevator in pairs(elevators) do
                for i, floor in ipairs(elevator.floors) do
                    local dist = #(playerCoords - vec3(floor.coords.x, floor.coords.y, floor.coords.z))
                    if dist < 2.0 then
                        sleep = 0
                        nearby = true
                        
                        if not textUiShown then
                            lib.showTextUI('[E] - ' .. Config.Locales.open_elevator)
                            textUiShown = true
                        end
                        
                        if IsControlJustPressed(0, 38) then
                            openElevatorUI(id, i)
                        end
                    end
                end
            end
            
            if not nearby and textUiShown then
                lib.hideTextUI()
                textUiShown = false
            end
            
            Wait(sleep)
        end
    end)
end

function openElevatorUI(elevatorId, currentFloorIndex)
    local elevator = elevators[elevatorId]
    if not elevator then return end

    -- Vérification Job
    if elevator.job and elevator.job ~= 'none' and elevator.job ~= '' then
        local PlayerData = exports.qbx_core:GetPlayerData()
        if PlayerData.job.name ~= elevator.job then
            lib.notify({ type = 'error', description = Config.Locales.invalid_permissions })
            return
        end
    end

    currentElevatorId = elevatorId
    SetNuiFocus(true, true)

    -- Calcul des numéros d'étage (logique Z)
    local uiFloors = {}
    local sortedFloors = {}
    
    for i, floor in ipairs(elevator.floors) do
        -- On copie les données nécessaires
        uiFloors[i] = {
            label = floor.label,
            coords = floor.coords,
            heading = floor.heading
        }
        table.insert(sortedFloors, { index = i, z = floor.coords.z })
    end

    table.sort(sortedFloors, function(a, b)
        return a.z < b.z
    end)

    -- Trouver l'index du "Rez-de-chaussée" (le premier étage créé/listé, index 1) dans la liste triée
    local groundIndexInSorted = 1
    for i, f in ipairs(sortedFloors) do
        if f.index == 1 then
            groundIndexInSorted = i
            break
        end
    end

    -- Assigner les numéros
    for i, f in ipairs(sortedFloors) do
        local logicalNum = i - groundIndexInSorted
        uiFloors[f.index].floorNumber = logicalNum
    end

    SendNUIMessage({
        action = 'open',
        floors = uiFloors,
        currentFloor = currentFloorIndex
    })
end

RegisterNUICallback('travel', function(data, cb)
    local floorIndex = data.floorIndex
    
    if not currentElevatorId then return end
    
    local elevator = elevators[currentElevatorId]
    local targetFloor = elevator.floors[floorIndex]
    
    SetNuiFocus(false, false)
    cb('ok')

    if Config.ScreenFade then
        DoScreenFadeOut(500)
        Wait(500)
    end

    Wait(Config.TravelTime or 2000)

    local ped = PlayerPedId()
    SetEntityCoords(ped, targetFloor.coords.x, targetFloor.coords.y, targetFloor.coords.z)
    SetEntityHeading(ped, targetFloor.heading or 0.0)

    if Config.ScreenFade then
        DoScreenFadeIn(500)
    end

    if Config.ElevatorSound then
        -- Chargement de la banque de sons
        RequestScriptAudioBank("MP_PROPERTIES_ELEVATOR_DOORS", false)
        
        -- Son d'arrivée demandé
        PlaySoundFrontend(-1, "FAKE_ARRIVE", "MP_PROPERTIES_ELEVATOR_DOORS", 1)
    end
    
    currentElevatorId = nil
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    currentElevatorId = nil
    cb('ok')
end)

-- Création d'ascenseur (Admin)
RegisterCommand('createelevator', function()
    -- Vérification permissions (côté client simple, mais le serveur bloquera aussi)
    -- On laisse le serveur gérer la perm via la commande ou on check ici
    
    local input = lib.inputDialog(Config.Locales.create_elevator, {
        {type = 'input', label = 'Nom', required = true},
        {type = 'input', label = 'Job (optionnel, ex: police)'},
    })
    
    if not input then return end
    
    local floors = {}
    local adding = true
    
    while adding do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        
        local confirm = lib.alertDialog({
            header = 'Ajouter cet étage ?',
            content = 'Position actuelle: ' .. string.format("%.2f, %.2f, %.2f", coords.x, coords.y, coords.z),
            centered = true,
            cancel = true,
            labels = {confirm = 'Ajouter', cancel = 'Annuler'}
        })
        
        if confirm == 'confirm' then
            local labelInput = lib.inputDialog('Nom de l\'étage', {{type = 'input', label = 'Label (ex: Garage, Toit)', required = true}})
            if labelInput then
                table.insert(floors, {
                    coords = {x = coords.x, y = coords.y, z = coords.z},
                    heading = heading,
                    label = labelInput[1]
                })
                lib.notify({type = 'success', description = 'Étage ajouté !'})
            end
        end
        
        local continue = lib.alertDialog({
            header = 'Continuer ?',
            content = 'Voulez-vous ajouter un autre étage ? (Déplacez-vous avant de confirmer)',
            centered = true,
            cancel = true,
            labels = {confirm = 'Oui', cancel = 'Non, terminer'}
        })
        
        if continue == 'cancel' then 
            adding = false 
        else
            -- Petit délai pour laisser le temps de bouger
            lib.notify({description = 'Déplacez-vous au prochain étage et attendez...'})
            Wait(3000) 
        end
    end
    
    if #floors >= 2 then
        local jobName = input[2]
        if not jobName or jobName == '' then jobName = 'none' end

        TriggerServerEvent('lunix_elevator:create', {
            name = input[1],
            job = jobName,
            floors = floors
        })
    else
        lib.notify({type = 'error', description = 'Il faut au moins 2 étages'})
    end
end)

RegisterCommand('listelevators', function()
    local options = {}
    
    for id, data in pairs(elevators) do
        local floorCount = #data.floors
        local description = string.format("Job: %s | Étages: %d", data.job or 'Aucun', floorCount)
        
        table.insert(options, {
            title = string.format("[%d] %s", id, data.name),
            description = description,
            icon = 'elevator',
            onSelect = function()
                local menuOptions = {}

                -- Ajouter un étage
                table.insert(menuOptions, {
                    title = 'Ajouter un étage',
                    description = 'Ajoute un étage à votre position actuelle',
                    icon = 'plus',
                    onSelect = function()
                        local input = lib.inputDialog('Ajouter un étage', {
                            {type = 'input', label = 'Nom de l\'étage', required = true}
                        })
                        if input then
                            local ped = PlayerPedId()
                            local coords = GetEntityCoords(ped)
                            local heading = GetEntityHeading(ped)
                            TriggerServerEvent('lunix_elevator:addFloor', id, {
                                label = input[1],
                                coords = {x = coords.x, y = coords.y, z = coords.z},
                                heading = heading
                            })
                        end
                    end
                })

                -- Modifier le Job
                table.insert(menuOptions, {
                    title = 'Modifier le Job',
                    description = 'Job actuel: ' .. (data.job or 'Aucun'),
                    icon = 'briefcase',
                    onSelect = function()
                        local input = lib.inputDialog('Modifier le Job', {
                            {type = 'input', label = 'Nouveau Job (laisser vide pour aucun)', default = data.job ~= 'none' and data.job or ''}
                        })
                        
                        if input then
                            local newJob = input[1]
                            if not newJob or newJob == '' then newJob = 'none' end
                            TriggerServerEvent('lunix_elevator:updateJob', id, newJob)
                        end
                    end
                })

                -- Liste des étages
                for i, floor in ipairs(data.floors) do
                    table.insert(menuOptions, {
                        title = string.format("Étage %d: %s", i, floor.label),
                        description = string.format("Coords: %.2f, %.2f, %.2f", floor.coords.x, floor.coords.y, floor.coords.z),
                        icon = 'layer-group',
                        onSelect = function()
                            -- Sous-menu pour l'étage
                            local floorMenu = {
                                {
                                    title = 'Se téléporter',
                                    icon = 'location-dot',
                                    onSelect = function()
                                        SetEntityCoords(PlayerPedId(), floor.coords.x, floor.coords.y, floor.coords.z)
                                    end
                                },
                                {
                                    title = 'Mettre à jour la position',
                                    description = 'Définit la position sur votre position actuelle',
                                    icon = 'floppy-disk',
                                    onSelect = function()
                                        local ped = PlayerPedId()
                                        local coords = GetEntityCoords(ped)
                                        local heading = GetEntityHeading(ped)
                                        TriggerServerEvent('lunix_elevator:editFloor', id, i, {
                                            coords = {x = coords.x, y = coords.y, z = coords.z},
                                            heading = heading
                                        })
                                    end
                                },
                                {
                                    title = 'Renommer',
                                    icon = 'pen',
                                    onSelect = function()
                                        local input = lib.inputDialog('Renommer l\'étage', {
                                            {type = 'input', label = 'Nouveau nom', default = floor.label, required = true}
                                        })
                                        if input then
                                            TriggerServerEvent('lunix_elevator:editFloor', id, i, {
                                                label = input[1]
                                            })
                                        end
                                    end
                                },
                                {
                                    title = 'Supprimer l\'étage',
                                    icon = 'trash',
                                    iconColor = 'red',
                                    onSelect = function()
                                        local alert = lib.alertDialog({
                                            header = 'Supprimer l\'étage ?',
                                            content = 'Êtes-vous sûr ?',
                                            centered = true,
                                            cancel = true
                                        })
                                        if alert == 'confirm' then
                                            TriggerServerEvent('lunix_elevator:deleteFloor', id, i)
                                        end
                                    end
                                }
                            }
                            lib.registerContext({
                                id = 'elevator_floor_' .. id .. '_' .. i,
                                title = floor.label,
                                menu = 'elevator_details_' .. id,
                                options = floorMenu
                            })
                            lib.showContext('elevator_floor_' .. id .. '_' .. i)
                        end
                    })
                end
                
                -- Option pour supprimer l'ascenseur
                table.insert(menuOptions, {
                    title = 'Supprimer cet ascenseur',
                    icon = 'trash',
                    iconColor = 'red',
                    onSelect = function()
                        local alert = lib.alertDialog({
                            header = 'Supprimer l\'ascenseur ?',
                            content = 'Êtes-vous sûr de vouloir supprimer ' .. data.name .. ' ?',
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            TriggerServerEvent('lunix_elevator:delete', id)
                        end
                    end
                })

                lib.registerContext({
                    id = 'elevator_details_' .. id,
                    title = data.name,
                    menu = 'elevator_list_menu',
                    options = menuOptions
                })
                lib.showContext('elevator_details_' .. id)
            end
        })
    end

    if #options == 0 then
        lib.notify({type = 'error', description = 'Aucun ascenseur trouvé.'})
        return
    end

    lib.registerContext({
        id = 'elevator_list_menu',
        title = 'Liste des Ascenseurs',
        options = options
    })
    lib.showContext('elevator_list_menu')
end)
