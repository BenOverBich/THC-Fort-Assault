local timerCount = Config.RobTime
local isRobbing, timers = false, false
local peds = {} -- Store the peds
local startPrompt
--Utility Functions
local function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
	SetTextFontForCurrentCommand(15)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    DisplayText(str, x, y)
end

local function countdown()
    while timers do
        Citizen.Wait(1000)
        if timerCount >= 0 then
            timerCount = timerCount - 1
        else
            timers = false
        end
    end
end

local function spawnPed(x, y, z)
    local model = GetHashKey(Config.NPCModel)
    while not HasModelLoaded(model) do
        Wait(500)
        RequestModel(model)
    end
    local ped = CreatePed(model, x, y, z, 0, true, false, 0, 0)
    table.insert(peds, ped) 
    SetPedRelationshipGroupHash(ped, 'NPC')
    GiveWeaponToPed_2(ped, 0x64356159, 500, true, 1, false, 0.0)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
    Citizen.InvokeNative(0xF166E48407BAC484, ped, PlayerPedId(), 0, 0)
    FreezeEntityPosition(ped, false)
    TaskCombatPed(ped, PlayerPedId(), 0, 16)
end

local function setupStartPrompt()
    startPrompt = PromptRegisterBegin()
    PromptSetControlAction(startPrompt, Config.StartKey)
    local str = CreateVarString(10, "LITERAL_STRING", Config.RobPrompt)
    PromptSetText(startPrompt, str)
    PromptSetEnabled(startPrompt, false)
    PromptSetVisible(startPrompt, false)
    PromptSetGroup(startPrompt, GetHashKey("FORTASSAULT"))
    PromptSetStandardMode(startPrompt, true)
    PromptRegisterEnd(startPrompt)
end

--Event Handlers
RegisterNetEvent('fortassault:startAnimation')
AddEventHandler('fortassault:startAnimation', function()    
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 3500, true, false, false, false)
    exports['progressBars']:startUI(3500, "Preparing for the fight...")
    Citizen.Wait(3500)
    ClearPedTasksImmediately(PlayerPedId())
    ClearPedSecondaryTask(PlayerPedId())
    Citizen.Wait(1000)
    TriggerEvent("fortassault:startTheEvent")
end)

RegisterNetEvent("fortassault:startTimer")
AddEventHandler("fortassault:startTimer",function()
	timers = true
    TriggerEvent("fortassault:startCountdown")
    while timers do
        DrawTxt("Assault the fort for... " .. timerCount .. " seconds", 0.15, 0.10, 0.3, 0.3, true, 255, 255, 255, 255, true)
        local playerPed = PlayerPedId()
        if IsPlayerDead(playerPed) or GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.AssaultLocation.x, Config.AssaultLocation.y, Config.AssaultLocation.z, true) > Config.CancelDistance then
            timers = false
        end
        if timerCount == 0 or not timers then
            Citizen.Wait(1000)
            TriggerServerEvent("fortassault:payout")
            for i, ped in ipairs(peds) do
                DeletePed(ped)
            end
            peds = {}
            timers = false
        end
    end
end)

AddEventHandler("fortassault:startCountdown", countdown)

RegisterNetEvent("fortassault:startTheEvent")
AddEventHandler("fortassault:startTheEvent", function()
    for k, v in pairs(Config.NPCSpawns) do
        Citizen.CreateThread(function()
            while timers do
                spawnPed(v.x, v.y, v.z)
                Citizen.Wait(60000)
            end
        end)
    end
end)

--Threads
Citizen.CreateThread(function()
    setupStartPrompt()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        if GetDistanceBetweenCoords(coords, Config.AssaultLocation.x, Config.AssaultLocation.y, Config.AssaultLocation.z, true) < Config.ZoneSize then
            PromptSetEnabled(startPrompt, true)
            PromptSetVisible(startPrompt, true)
            if Citizen.InvokeNative(0xC92AC953F0A982AE, startPrompt) then
                PromptSetEnabled(startPrompt, false)
                PromptSetVisible(startPrompt, false)
                TriggerServerEvent("fortassault:startRobbing")
                isRobbing = true
            end
        else
            PromptSetEnabled(startPrompt, false)
            PromptSetVisible(startPrompt, false)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        for i, ped in ipairs(peds) do
            if IsPedDeadOrDying(ped, 1) then
                DeletePed(ped)
                table.remove(peds, i)
            end
        end
    end
end)
