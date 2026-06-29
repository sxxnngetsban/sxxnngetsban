-- Script du CLIENT (LocalScript).
-- Comme ce fichier s'appelle "init.client.luau", c'est le dossier "Client" lui-même
-- qui devient un LocalScript et s'exécute sur la machine DE CHAQUE joueur.
--
-- Il vit dans StarterPlayer.StarterPlayerScripts : ce dossier est copié dans chaque
-- joueur qui se connecte, et ses scripts tournent côté client (parfait pour l'UI).
--
-- Son rôle : construire l'affichage du compteur, et le mettre à jour quand le
-- serveur envoie une nouvelle valeur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- On attend le RemoteEvent créé par le serveur. WaitForChild = "patiente jusqu'à
-- ce qu'il existe", car le client peut démarrer avant que le serveur l'ait créé.
local remote = ReplicatedStorage:WaitForChild("CoinsUpdated")

-- --- Construction de l'interface (UI) entièrement par code ---

-- ScreenGui = le calque d'interface 2D plaqué sur l'écran du joueur.
local gui = Instance.new("ScreenGui")
gui.Name = "CoinUI"
gui.ResetOnSpawn = false -- ne pas détruire/recréer l'UI à chaque réapparition
gui.Parent = player:WaitForChild("PlayerGui")

-- Le texte qui affiche le total de pièces.
local label = Instance.new("TextLabel")
label.Name = "CoinLabel"
label.Size = UDim2.fromOffset(220, 50)
label.Position = UDim2.fromOffset(20, 20)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.4
label.TextColor3 = Color3.fromRGB(255, 215, 0)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Text = "Pièces : 0"
label.Parent = gui

-- Petit coin arrondi, juste pour faire joli.
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = label

-- --- Mise à jour quand le serveur envoie le nouveau total ---
-- OnClientEvent = "le serveur m'a envoyé quelque chose". Ici, le total à afficher.
remote.OnClientEvent:Connect(function(total)
	label.Text = "Pièces : " .. total
end)

-- On signale au serveur "je suis prêt, envoie-moi mon total". Utile au tout début
-- pour afficher la valeur sauvegardée dès l'arrivée (et pas un 0 trompeur).
remote:FireServer()
