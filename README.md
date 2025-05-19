# Script FiveM Boutique - Système de Coins avec Menu

## Fonctionnalités

- Stocke le nombre de coins de chaque joueur dans un fichier `coins.json`
- Commande `/addcoins <id> <montant>` pour ajouter des coins à un joueur (admin)
- Commande `/coins` pour voir ses coins
- Commande `/shop` pour ouvrir la boutique en jeu (menu NativeUI)
- Achat instantané (véhicule/objet) déduit les coins et donne la récompense
- **Traçabilité et gestion** : Possibilité de tracer, ajouter ou retirer des coins et d’adapter pour logguer les transactions

---

## Fonctionnement

- **Stockage des coins** :  
  Chaque joueur est identifié par sa license FiveM (ou Steam selon adaptation). Le solde est conservé dans le fichier `coins.json` à la racine de la ressource côté serveur.
- **Boutique interactive** :  
  En tapant `/shop`, un menu apparaît (via NativeUI) listant les articles disponibles et leur prix en coins. L’achat soustrait les coins et octroie la récompense (objet, véhicule...).
- **Ajout/Suppression de coins** :  
  Les administrateurs (ayant l’ACE permission) peuvent utiliser `/addcoins <id> <montant>` pour ajouter des coins à un joueur.
- **Affichage du solde** :  
  Tout joueur peut taper `/coins` pour afficher son solde actuel dans le chat.

---

## Dépendances

- **FiveM FXServer**
- **NativeUI** (https://github.com/FrazzIe/NativeUILua) pour l’affichage du menu boutique côté client
- JSON natif (supporté par FXServer)
- Un système d’inventaire côté client si vous souhaitez donner des objets (exemple : ESX pour `esx:addInventoryItem`)

---

## Installation

1. Placez `server.lua`, `client.lua` et un fichier vide `coins.json` dans le même dossier de ressource.
2. Téléchargez et ajoutez [NativeUILua](https://github.com/FrazzIe/NativeUILua) à votre serveur (`resources/NativeUI`).
3. Ajoutez cette ressource et NativeUI dans votre `server.cfg` :
   ```
   ensure NativeUI
   ensure nom_de_votre_boutique
   ```
4. (Optionnel) Pour restreindre l'accès à `/addcoins`, ajoutez dans votre `server.cfg` :
   ```
   add_ace group.admin boutique.addcoins allow
   ```

---

## Gestion des articles de la boutique

Pour ajouter ou retirer des articles, modifiez la table `shopItems` dans le fichier `server.lua` :
```lua
local shopItems = {
    {label = "BMX", value = "bmx", price = 100},
    {label = "Super Voiture", value = "adder", price = 500},
    {label = "Kit de soin", value = "medkit", price = 50}
}
```
Pour l’attribution, adaptez la partie :
```lua
bmx = {label = "BMX", price = 100, give = function(src) TriggerClientEvent("boutique:giveVehicle", src, "bmx") end},
```
Rajoutez ou retirez des lignes pour adapter vos récompenses.

---

## Ajout, suppression et traçabilité des coins

### Ajout de coins
- Utilisez la commande serveur (en jeu ou via console) :
  ```
  /addcoins <id> <montant>
  ```
  Exemple : `/addcoins 3 100`

### Suppression de coins
- Modifiez la commande `/addcoins` pour utiliser un montant négatif (ex: `/addcoins 3 -50`) **OU**
- Ajoutez une commande `/removecoins` en copiant la logique de `/addcoins` mais en soustrayant le montant.

### Traçabilité / Logs des transactions
Pour tracer chaque transaction (ajout, retrait, achat), ajoutez un logging dans les fonctions `AddCoinsToPlayer`, `RemoveCoinsFromPlayer` et lors des achats :
```lua
function LogTransaction(identifier, action, amount, reason)
    local file = io.open("transactions.log", "a")
    if file then
        file:write(os.date("[%Y-%m-%d %H:%M:%S]").." "..identifier.." "..action.." "..amount.." ("..reason..")\n")
        file:close()
    end
end
```
Exemple d'utilisation :
```lua
AddCoinsToPlayer(identifier, amount)
LogTransaction(identifier, "ADD", amount, "commande admin")
```
Vous pourrez ensuite lire le fichier `transactions.log` pour voir tout l’historique.

---

## Exemple de personnalisation pour ESX (inventaire)

Dans `client.lua`, adaptez :
```lua
RegisterNetEvent("boutique:giveItem")
AddEventHandler("boutique:giveItem", function(item, count)
    TriggerEvent('esx:addInventoryItem', item, count)
end)
```
Pour d’autres frameworks, adaptez l’event donné lors des achats.

---

## Résumé des commandes

- `/addcoins <id> <montant>` : Ajoute/retire des coins à un joueur (admin)
- `/coins` : Affiche les coins du joueur
- `/shop` : Ouvre la boutique

---

## Conseils de sécurité

- Ne donnez l’accès `/addcoins` qu’aux administrateurs via ACE.
- Sauvegardez et surveillez régulièrement le fichier `coins.json` et les logs.

---

## Personnalisation

- Modifiez la structure et le contenu de la table `shopItems` pour proposer de nouveaux articles.
- Adaptez les events de récompense pour intégrer vos propres systèmes (spawn objets, véhicules, grades...).

---

## Support

Pour toute question, ouvrez une issue ou contactez le développeur du script.
