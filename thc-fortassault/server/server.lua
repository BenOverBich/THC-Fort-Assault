VORP = exports.vorp_inventory:vorp_inventoryApi()

local data = {}
TriggerEvent("vorp_inventory:getData", function(call)
    data = call
end)

RegisterNetEvent("fortassault:startRobbing")
AddEventHandler("fortassault:startRobbing", function()
    local _source = source
    TriggerEvent('vorp:getCharacter', _source, function(user)
        local count = VORP.getItemCount(_source, "presidential_order")

        if count >= 1 then
            VORP.subItem(_source, "presidential_order", 1)
            TriggerClientEvent('fortassault:startTimer', _source)
            TriggerClientEvent('fortassault:startAnimation', _source)
        else
            TriggerClientEvent("vorp:TipBottom", _source, "You need the Presidential Order", 6000)
        end     
    end)
end)

RegisterNetEvent("fortassault:payout")
AddEventHandler("fortassault:payout", function()
    TriggerEvent('vorp:getCharacter', source, function(user)
        local _source = source
        local _user = user
        TriggerEvent("vorp:addMoney", source, 0, 100, _user)
    end)
    TriggerClientEvent("vorp:Tip", source, 'The State has sent you a reward: $100', 5000)
end)
