-- Local variables
local visits = 1
local l = 0
local area = 0
local isOnFoodJob = false
local foodPay = 0
local maxvisits = 10
local spawned_car = nil
local deliveryblip = nil

local destination = {
    { x = 285.79,  y = -937.67,  z = 29.36, money = math.random(100, 350) },
    { x = 262.74,  y = -831.44,  z = 29.41, money = math.random(100, 350) },
    { x = 319.46,  y = -834.65,  z = 29.41, money = math.random(100, 350) },
    { x = 338.80,  y = -774.22,  z = 29.15, money = math.random(100, 350) },
    { x = 285.85,  y = -790.88,  z = 29.44, money = math.random(100, 350) },
    { x = 238.04,  y = -696.99,  z = 36.67, money = math.random(100, 350) },
    { x = 222.32,  y = -595.75,  z = 43.87, money = math.random(100, 350) },
    { x = 167.67,  y = -568.62,  z = 43.88, money = math.random(100, 350) },
    { x = -100.02, y = -557.41,  z = 40.32, money = math.random(100, 350) },
    { x = -318.58, y = -609.36,  z = 33.56, money = math.random(100, 350) },
    { x = -468.70, y = -679.15,  z = 32.71, money = math.random(100, 350) },
    { x = -652.99, y = -677.66,  z = 31.57, money = math.random(100, 350) },
    { x = -656.96, y = -854.69,  z = 24.51, money = math.random(100, 350) },
    { x = -206.64, y = -1342.11, z = 34.89, money = math.random(100, 350) },
    { x = 20.80,   y = -1505.53, z = 31.85, money = math.random(100, 350) },
    { x = 15.72,   y = -1445.15, z = 30.54, money = math.random(100, 350) },
    { x = -2.22,   y = -1442.44, z = 30.95, money = math.random(100, 350) },
    { x = -15.23,  y = -1442.45, z = 31.10, money = math.random(100, 350) },
    { x = -32.78,  y = -1447.17, z = 31.88, money = math.random(100, 350) },
    { x = -46.14,  y = -1445.63, z = 32.43, money = math.random(100, 350) },
    { x = -64.03,  y = -1449.40, z = 32.52, money = math.random(100, 350) },
    { x = -117.90, y = -1485.72, z = 33.82, money = math.random(100, 350) },
    { x = -120.37, y = -1574.29, z = 34.18, money = math.random(100, 350) },
    { x = -123.56, y = -1591.02, z = 34.21, money = math.random(100, 350) },
    { x = -123.53, y = -1591.03, z = 37.37, money = math.random(100, 350) },
    { x = 69.33,   y = -1569.29, z = 29.60, money = math.random(100, 350) },
    { x = -33.11,  y = -1847.42, z = 26.19, money = math.random(100, 350) },
    { x = -5.10,   y = -1871.16, z = 24.15, money = math.random(100, 350) },
    { x = 45.59,   y = -1864.39, z = 23.29, money = math.random(100, 350) },
    { x = 55.03,   y = -1873.64, z = 22.74, money = math.random(100, 350) },
    { x = 101.08,  y = -1912.17, z = 21.40, money = math.random(100, 350) },
}

Citizen.CreateThread(function()
    AddTextEntry("press_start_job", "Press ~INPUT_CONTEXT~ to start your shift")
    while true do
        Citizen.Wait(0)
        -- Lowered Z from 29.36 to 29.16
        DrawMarker(1, 264.73, -981.45, 28.16, 0, 0, 0, 0, 0, 0, 2.0001, 2.0001, 1.5001, 139, 69, 19, 75, 0, 0, 0, 0)
        if GetDistanceBetweenCoords(264.73, -981.45, 29.36, GetEntityCoords(GetPlayerPed(-1))) <= 3 then
            if not isOnFoodJob then
                DisplayHelpTextThisFrame("press_start_job")
                if IsControlJustReleased(1, 38) then
                    SpawnDeliveryCar()
                end
            end
        end
    end
end)


function IsInVehicle()
    return IsPedSittingInAnyVehicle(GetPlayerPed(-1))
end

function SpawnDeliveryCar()
    if isOnFoodJob then return end -- prevent double start

    if IsInVehicle() then
        isOnFoodJob = true
        StartFoodDeliveryJob()
    else
        local vehicle = math.randomchoice(Config.FoodCarModels)
        RequestModel(vehicle)
        while not HasModelLoaded(vehicle) do Wait(1) end
        local spawnCoords = vector3(257.34, -978.43, 29.25)
        local heading = 345.37
        spawned_car = CreateVehicle(vehicle, spawnCoords, heading, true, false)
        SetVehicleEngineOn(spawned_car, true, true, false)
        SetVehicleOnGroundProperly(spawned_car)
        SetModelAsNoLongerNeeded(vehicle)
        local vehicleBlip = AddBlipForEntity(spawned_car)
        SetBlipSprite(vehicleBlip, 227)
        SetBlipColour(vehicleBlip, 31)
        isOnFoodJob = true
        StartFoodDeliveryJob()
        TriggerServerEvent("TruckDriver:started", spawned_car)
    end
end

function StartFoodDeliveryJob()
    AddTextEntry("press_deliver_food", "Press ~INPUT_CONTEXT~ to deliver the coffee")
    local message = Config.UseND and "Drive to the destination.\nPress ~r~X~s~ at any time to cancel the delivery. You will be penalized"
                                or "Drive to the destination.\nPress ~r~X~s~ at any time to cancel the delivery."
    drawnotifcolor(message, 140)
    area = math.random(1, #destination)
    l = area
    if deliveryblip ~= nil then RemoveBlip(deliveryblip) end
    deliveryblip = AddBlipForCoord(destination[l].x, destination[l].y, destination[l].z)
    SetBlipSprite(deliveryblip, 280)
    SetBlipColour(deliveryblip, 31)
    SetBlipRoute(deliveryblip, true)
    SetBlipRouteColour(deliveryblip, 31)

    while isOnFoodJob do
        Citizen.Wait(0)
        if IsControlJustReleased(1, 73) then
            if Config.UseND then
                TriggerServerEvent('FoodDelivery:penalty', destination[l].money)
            end
            isOnFoodJob = false
            RemoveBlip(deliveryblip)
            SetBlipRoute(deliveryblip, false)
            visits = 1
            local penaltyMsg = Config.UseND and "You've cancelled the delivery and paid $" .. destination[l].money .. " as penalty. You may return the car."
                                      or "You've cancelled the delivery. You may return the car."
            drawnotifcolor(penaltyMsg, 208)
            SetNewWaypoint(-321.85, 7151.46, 6.65)
            if spawned_car ~= nil then DeleteEntity(spawned_car) spawned_car = nil end
            ReturnJobCar()
            break
        end
        if GetDistanceBetweenCoords(destination[l].x, destination[l].y, destination[l].z, GetEntityCoords(GetPlayerPed(-1))) < 10.0 then
            DisplayHelpTextThisFrame("press_deliver_food")
            if IsControlJustReleased(1, 38) then
                FoodDeliverySuccessful()
                break
            end
        end
    end
end

function FoodDeliverySuccessful()
    foodPay = foodPay + destination[l].money
    if visits == maxvisits then 
        RemoveBlip(deliveryblip)
        visits = 1
        if Config.UseND then
            TriggerServerEvent('FoodDelivery:success', foodPay)
            drawnotifcolor("You've received ~g~$" .. foodPay .. "~w~ for completing the job. You may return the car.", 140)
        else 
            drawnotifcolor("You've completed the job. You may return the car.", 140)
        end
        SetNewWaypoint(-347.62, 7164.83, 6.40)
        isOnFoodJob = false
        ReturnJobCar()
    else
        visits = visits + 1
        StartFoodDeliveryJob()
    end
end

function ReturnJobCar()
    AddTextEntry("press_return_car", "Press ~INPUT_CONTEXT~ to return the job car")
    while true do
        Citizen.Wait(0)
        DrawMarker(1, 257.34, -978.43, 29.25, 0, 0, 0, 0, 0, 0, 2.0001, 2.0001, 1.5001, 139, 69, 19, 75, 0, 0, 0, 0)
        if GetDistanceBetweenCoords(257.34, -978.43, 29.25, GetEntityCoords(GetPlayerPed(-1))) <= 3 then
            DisplayHelpTextThisFrame("press_return_car")
            if IsControlJustReleased(1, 38) then
                DeleteEntity(spawned_car)
                spawned_car = nil
                drawnotifcolor("You've returned the job car.", 140)
                break
            end
        end
    end
end

function drawnotifcolor(text, color)
    Citizen.InvokeNative(0x92F0DA1E27DB96DC, tonumber(color))
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end

local blips = {{
    title = "Coffee Delivery Job",
    colour = 53,
    id = 827,
    x = 264.73,
    y = -981.45,
    z = 29.36
}}

Citizen.CreateThread(function()
    for _, info in pairs(blips) do
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(info.blip)
    end
end)

function math.randomchoice(d)
    local keys = {}
    for key, _ in pairs(d) do
        table.insert(keys, key)
    end
    local randomKey = keys[math.random(1, #keys)]
    return d[randomKey]
end
