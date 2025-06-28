-- Event handler for starting the Food Delivery job
RegisterNetEvent("FoodDelivery:started", function(spawned_car)
    local player = source

    if Config.UseND then -- Optional: Still preserves this conditional if needed
        if DoesEntityExist(spawned_car) then
            local netId = NetworkGetNetworkIdFromEntity(spawned_car)
            -- Optionally store or use netId if needed
        else
            print("Invalid vehicle entity!")
        end
    end
end)

-- Event handler for successful Food Delivery
RegisterServerEvent('FoodDelivery:success')
AddEventHandler('FoodDelivery:success', function(pay)
    local src = source
    exports['Az-Framework']:addMoney(src, pay)
    print("Food delivery reward added: $" .. pay .. " to player " .. src)
end)

-- Event handler for penalty in Food Delivery
RegisterServerEvent("FoodDelivery:penalty")
AddEventHandler("FoodDelivery:penalty", function(money)
    local src = source
    exports['Az-Framework']:deductMoney(src, money)
    print("Food delivery penalty deducted: $" .. money .. " from player " .. src)
end)
