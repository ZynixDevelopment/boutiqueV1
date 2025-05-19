--[[
    Script FiveM: Boutique avec système de coins et menu interactif
    - Stockage des coins dans un fichier bdd (coins.json)
    - Commande /addcoins <id> <montant> pour ajouter des coins à un joueur
    - Commande /coins pour afficher ses coins
    - Commande /shop pour ouvrir le menu boutique en jeu (client)
]]

local coinsDBFile = "coins.json"
local coins = {}

-- Chargement des coins depuis le fichier au démarrage
function LoadCoins()
    local file = io.open(coinsDBFile, "r")
    if file then
        local content = file:read("*a")
        coins = json.decode(content) or {}
        file:close()
    else
        coins = {}
    end
end

-- Sauvegarde des coins dans le fichier
function SaveCoins()
    local file = io.open(coinsDBFile, "w+")
    if file then
        file:write(json.encode(coins))
        file:close()
    end
end

-- Obtenir l'identifiant unique du joueur (par exemple steam ou license)
function GetPlayerIdentifier(src)
    for k,v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            return v
        end
    end
    return nil
end

-- Donner des coins à un joueur
function AddCoinsToPlayer(identifier, amount)
    coins[identifier] = (coins[identifier] or 0) + amount
    SaveCoins()
end

-- Retirer des coins à un joueur
function RemoveCoinsFromPlayer(identifier, amount)
    if (coins[identifier] or 0) >= amount then
        coins[identifier] = coins[identifier] - amount
        SaveCoins()
        return true
    end
    return false
end

-- Obtenir le nombre de coins d'un joueur
function GetCoins(identifier)
    return coins[identifier] or 0
end

-- Commande pour ajouter des coins
RegisterCommand("addcoins", function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "boutique.addcoins") then
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2])
        if targetId and amount then
            local identifier = GetPlayerIdentifier(targetId)
            if identifier then
                AddCoinsToPlayer(identifier, amount)
                TriggerClientEvent("chat:addMessage", targetId, { args = {"Boutique", "Vous avez reçu "..amount.." coins !"} })
                if source ~= 0 then
                    TriggerClientEvent("chat:addMessage", source, { args = {"Boutique", "Vous avez donné "..amount.." coins au joueur #"..targetId.."."} })
                end
            else
                if source ~= 0 then
                    TriggerClientEvent("chat:addMessage", source, { args = {"Erreur", "Impossible d'identifier ce joueur."} })
                end
            end
        else
            if source ~= 0 then
                TriggerClientEvent("chat:addMessage", source, { args = {"Erreur", "Usage: /addcoins <id> <montant>"} })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, { args = {"Erreur", "Vous n'avez pas la permission."} })
    end
end)

-- Commande pour afficher ses coins
RegisterCommand("coins", function(source)
    local identifier = GetPlayerIdentifier(source)
    if identifier then
        local amount = GetCoins(identifier)
        TriggerClientEvent("chat:addMessage", source, { args = {"Boutique", "Vous avez "..amount.." coins."} })
    end
end)

-- Commande pour ouvrir le menu boutique
RegisterCommand("shop", function(source)
    local identifier = GetPlayerIdentifier(source)
    if identifier then
        local amount = GetCoins(identifier)
        -- Ici, vous pouvez définir les articles disponibles dans la boutique
        local shopItems = {
            {label = "BMX", value = "bmx", price = 100},
            {label = "Super Voiture", value = "adder", price = 500},
            {label = "Kit de soin", value = "medkit", price = 50}
        }
        TriggerClientEvent("boutique:openMenu", source, amount, shopItems)
    end
end)

-- Achat d'un article via l'event
RegisterNetEvent("boutique:buyItem")
AddEventHandler("boutique:buyItem", function(item)
    local src = source
    local identifier = GetPlayerIdentifier(src)
    if not identifier then return end

    -- Définir ici vos articles et leurs prix
    local shopItems = {
        bmx = {label = "BMX", price = 100, give = function(src) TriggerClientEvent("boutique:giveVehicle", src, "bmx") end},
        adder = {label = "Super Voiture", price = 500, give = function(src) TriggerClientEvent("boutique:giveVehicle", src, "adder") end},
        medkit = {label = "Kit de soin", price = 50, give = function(src) TriggerClientEvent("boutique:giveItem", src, "medkit", 1) end}
    }

    local it = shopItems[item]
    if it then
        if RemoveCoinsFromPlayer(identifier, it.price) then
            it.give(src)
            TriggerClientEvent("chat:addMessage", src, { args = {"Boutique", "Achat réussi : "..it.label.." pour "..it.price.." coins."} })
        else
            TriggerClientEvent("chat:addMessage", src, { args = {"Boutique", "Vous n'avez pas assez de coins !"} })
        end
    end
end)

-- Initialisation
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        LoadCoins()
    end
end)

-- Sauvegarde lors du stop serveur
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SaveCoins()
    end
end)
