local isScenePlaying = false

function DrawLetterbox() local barHeight = 0.12; DrawRect(0.5, barHeight / 2, 1.0, barHeight, 0, 0, 0, 255); DrawRect(0.5, 1.0 - (barHeight / 2), 1.0, barHeight, 0, 0, 0, 255) end

RegisterNetEvent("ap_kidnap:startKidnapScene", function(data)
    if isScenePlaying then return end
    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) or IsPedDeadOrDying(playerPed, 1) then
        print("[ap_kidnap] Target is not in a valid state. Aborting.")
        TriggerServerEvent('ap_kidnap:sceneAborted')
        return
    end

    isScenePlaying = true
    Citizen.CreateThread(function()
        local coords = GetEntityCoords(playerPed)
        DoScreenFadeOut(1000); Wait(1000)

        local vehicleModel = 'burrito'; local animDict = 'random@kidnap_girl'; local kidnapperModels = {'s_m_y_swat_01', 's_m_y_swat_01'}
        RequestModel(vehicleModel); RequestAnimDict(animDict)
        for _, model in ipairs(kidnapperModels) do RequestModel(model) end
        while not HasModelLoaded(vehicleModel) or not HasAnimDictLoaded(animDict) do Wait(50) end
        for _, model in ipairs(kidnapperModels) do while not HasModelLoaded(model) do Wait(50) end end
        
        local found, vehicleCoords = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 1, 3.0, 0)
        if not found then vehicleCoords = GetSafeCoordForPed(coords.x + 5.0, coords.y, coords.z, true, 16) end
        
        local van = CreateVehicle(vehicleModel, vehicleCoords, GetEntityHeading(playerPed) + 90.0, true, true)
        local vanNetId = NetworkGetNetworkIdFromEntity(van)
        SetNetworkIdCanMigrate(vanNetId, false)
        SetEntityAsMissionEntity(van, true, true); PlaceObjectOnGroundProperly(van); Wait(100)
        
        local kidnapperPeds = {}
        local kidnapperRoles = {
            { anim = "ig_1_guy2_drag_into_van", offset = vector3(-1.5, -1.5, 0.0), hasWeapon = false },
            { anim = "ig_1_guy1_drag_into_van", offset = vector3(1.0, 3.0, 0.0),  hasWeapon = true }
        }
        for i, role in ipairs(kidnapperRoles) do
            local npcCoordsBase = GetOffsetFromEntityInWorldCoords(van, role.offset.x, role.offset.y, role.offset.z)
            local foundGround, groundZ = GetGroundZFor_3dCoord(npcCoordsBase.x, npcCoordsBase.y, npcCoordsBase.z, false)
            local npcCoordsFinal = vector3(npcCoordsBase.x, npcCoordsBase.y, groundZ)
            local npcPed = CreatePed(4, kidnapperModels[i], npcCoordsFinal, GetEntityHeading(van), true, true)
            local pedNetId = NetworkGetNetworkIdFromEntity(npcPed)
            SetNetworkIdCanMigrate(pedNetId, false)
            SetEntityAsMissionEntity(npcPed, true, true); SetBlockingOfNonTemporaryEvents(npcPed, true); SetPedCanRagdoll(npcPed, false)
            if role.hasWeapon then GiveWeaponToPed(npcPed, `WEAPON_CARBINERIFLE`, 250, false, true); SetCurrentPedWeapon(npcPed, `WEAPON_CARBINERIFLE`, true) end
            table.insert(kidnapperPeds, npcPed)
        end
        
        DoScreenFadeIn(1000); ShakeGameplayCam('JOLT_SHAKE', 0.7)
          
        local scenePos = GetEntityCoords(van) + vector3(0.0, 0.0, 0.2)
        local sceneRot = GetEntityRotation(van)
        local scene = NetworkCreateSynchronisedScene(scenePos, sceneRot, 2, false, false, 1.0, 0.0, 1.0)
        
        NetworkAddPedToSynchronisedScene(playerPed, scene, animDict, "ig_1_girl_drag_into_van", 8.0, -8.0, 1033, 0, 1148846080, 0)
        for i, npcPed in ipairs(kidnapperPeds) do NetworkAddPedToSynchronisedScene(npcPed, scene, animDict, kidnapperRoles[i].anim, 4.0, -8.0, 1, 16, 1148846080, 0) end
        NetworkAddEntityToSynchronisedScene(van, scene, animDict, "drag_into_van_burr", 1.0, -1.0, 1)

        NetworkStartSynchronisedScene(scene)
        
        local animDuration = GetAnimDuration(animDict, "drag_into_van_burr") * 1000
        local waitTime = animDuration - 500
        local startTime = GetGameTimer()

        while GetGameTimer() - startTime < waitTime do
            DrawLetterbox(); Wait(0)
        end
        
        StopGameplayCamShaking(true)

        DoScreenFadeOut(500); Wait(500)

        TriggerServerEvent('ap_kidnap:performActionAfterScene', data)

        for _, npcPed in ipairs(kidnapperPeds) do DeleteEntity(npcPed) end
        DeleteEntity(van)
        isScenePlaying = false
    end)
end)