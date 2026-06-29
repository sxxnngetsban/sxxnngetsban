-- Réglages partagés du collecteur de pièces.
-- Un seul endroit pour changer les valeurs : c'est plus lisible et facile à régler.
--
-- Ce ModuleScript vit dans ReplicatedStorage.Shared : le serveur ET le client
-- peuvent le require(). Ici c'est surtout le serveur qui s'en sert, mais le mettre
-- en "shared" est la bonne habitude (un seul endroit de vérité pour les réglages).

local Settings = {}

-- Combien de pièces présentes en même temps sur la map.
Settings.CoinCount = 15

-- Combien vaut une pièce ramassée (en points).
Settings.CoinValue = 1

-- Zone (carrée) où les pièces apparaissent, centrée sur (0, 0).
-- Les pièces sortiront entre -SpawnRange et +SpawnRange en X et Z.
Settings.SpawnRange = 50

-- Hauteur (Y) à laquelle les pièces flottent au-dessus du sol.
Settings.CoinHeight = 3

-- Nom du RemoteEvent que le serveur crée pour prévenir le client.
Settings.RemoteName = "CoinsUpdated"

-- Nom du DataStore (la "base de données" qui sauvegarde les pièces).
-- Astuce : garder un "_v1" permet de repartir à zéro plus tard en passant à "_v2".
Settings.DataStoreName = "CoinData_v1"

return Settings
