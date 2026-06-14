--!nonstrict
-- FPSServer (bootstrap)
-- Point d'entrée serveur : crée les remotes puis initialise les services.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)

-- 1) Crée tous les RemoteEvents avant que les clients ne se connectent
Net.setup()

-- 2) Charge les services
local GameModeService = require(script.GameModeService)
local SpawnService = require(script.SpawnService)
local CombatService = require(script.CombatService)

-- 3) Conteneur de services partagé entre eux
local services = {}
services.GameMode = GameModeService
services.Spawn = SpawnService
services.Combat = CombatService

-- 4) Initialisation (ordre : modes -> spawn -> combat)
GameModeService.init(services)
SpawnService.init(services)
CombatService.init(services)
GameModeService.startRound()

print("[FPS] Serveur initialisé — mode:", require(Shared.GameConfig).Mode)
