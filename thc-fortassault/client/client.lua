local robtime = 300 -- Time to rob (in seconds)
local timerCount = robtime
local isRobbing, timers = false, false
local peds = {} -- Store the peds


local Config = {
    rob = '[~e~Press-Enter~q~] start the assault',
    ZoneSize = 2.0,
    npcspawn = {
        {x = -4205.81, y = -3430.02, z = 37.09},
        {x = -4205.81, y = -3430.02, z = 37.09},
        {x = -4207.34, y = -3431.82, z = 37.09},
        {x = -4202.31, y = -3429.72, z = 37.09},
        {x = -4201.2, y = -3432.66, z = 37.09},
        {x = -4235.85, y = -3428.87, z = 45.48},
        {x = -4228.56, y = -3450.46, z = 43.56},
        {x = -4223.76, y = -3461.3, z = 44.61},
        {x = -4243.9, y = -3468.63, z = 37.09},
        {x = -4259.25, y = -3470.88, z = 37.08},
        {x = -4229.83, y = -3422.19, z = 41.48},
        {x = -4221.04, y = -3428.73, z = 41.48},
        {x = -4204.81, y = -3422.55, z = 41.48},
        {x = -4193.06, y = -3419.21, z = 42.5},
        {x = -4214.4, y = -3425.81, z = 45.58},
        {x = -4207.84, y = -3417.93, z = 45.59}
        -- other coordinates...
    }
}


--Utility Functions
local function DrawText(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
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
    local model = GetHashKey("G_M_O_UniExConfeds_01")
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
    TaskCombatPed(ped, playerPed, 0, 16)
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
        DrawTxt("Assault the fort for... "..timerCount.." seconds", 0.15, 0.10, 0.3, 0.3, true, 255, 255, 255, 255, true)
        local playerPed = PlayerPedId()
        if IsPlayerDead(playerPed) or GetDistanceBetweenCoords(GetEntityCoords(playerPed), -4207.02, -3582.37, 49.43, true) > 2000.0 then
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
    for k, v in pairs(Config.npcspawn) do
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
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        if GetDistanceBetweenCoords(coords, -4207.02, -3582.37, 49.43, true) < 2.0 then
            DrawTxt(Config.rob, 0.17, 0.55, -4.3, 0.3, true, 255, 255, 255, 255, true)
            if IsControlJustReleased(0, 0xC7B5340A) then
                TriggerServerEvent("fortassault:startRobbing")
                isRobbing = true
            end
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
