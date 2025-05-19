--[[
    Client : Menu boutique /shop
    Utilise NativeUILua (https://github.com/FrazzIe/NativeUILua)
    Assurez-vous d'ajouter 'NativeUI.lua' à votre ressource ou utilisez un menu natif si vous préférez.
]]

local shopMenu = nil
local NativeUI = exports["NativeUI"]:GetInterface() -- Adaptez ceci selon votre version de NativeUI

RegisterNetEvent("boutique:openMenu")
AddEventHandler("boutique:openMenu", function(coins, items)
    if shopMenu ~= nil then
        shopMenu:Visible(false)
        shopMenu = nil
    end

    shopMenu = NativeUI.CreateMenu("Boutique", "Vos coins : "..tostring(coins))
    NativeUI._menuPool:Add(shopMenu)

    for _, item in ipairs(items) do
        local btn = NativeUI.CreateItem(item.label.." ("..item.price.." coins)", "")
        btn.Activated = function(sender, itemBtn)
            TriggerServerEvent("boutique:buyItem", item.value)
            shopMenu:Visible(false)
        end
        shopMenu:AddItem(btn)
    end

    shopMenu:Visible(true)
end)

-- Gérer la réception d'un véhicule (test, à adapter selon votre framework)
RegisterNetEvent("boutique:giveVehicle")
AddEventHandler("boutique:giveVehicle", function(model)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
    TaskWarpPedIntoVehicle(playerPed, veh, -1)
end)

-- Gérer la réception d'un objet (ex : medkit)
RegisterNetEvent("boutique:giveItem")
AddEventHandler("boutique:giveItem", function(item, count)
    -- À adapter selon votre inventaire
    TriggerEvent('esx:addInventoryItem', item, count)
end)

-- Commande pour ouvrir le menu boutique
RegisterCommand("shop", function()
    TriggerServerEvent("shop:requestOpen")
end)

-- Pour compatibilité : le server ouvre le menu directement (mais on garde la commande client pour sécurité)
RegisterNetEvent("shop:forceOpen")
AddEventHandler("shop:forceOpen", function(coins, items)
    TriggerEvent("boutique:openMenu", coins, items)
end)

-- Boucle pour les menus NativeUI (si besoin)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NativeUI and NativeUI._menuPool then
            NativeUI._menuPool:ProcessMenus()
        end
    end
end)
