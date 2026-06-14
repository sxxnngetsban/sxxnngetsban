--!nonstrict
-- ViewModelController
-- Affiche le modèle d'arme à l'écran (viewmodel) et le fait bouger :
-- suit la caméra, balancement à la marche (bob), recul au tir, position de visée (ADS).
--
-- ⚠️ ASSET À AJOUTER : place tes modèles d'armes dans
--    ReplicatedStorage > Assets > ViewModels > (nom = champ ModelName de l'arme).
-- Si aucun modèle n'est trouvé, le jeu fonctionne quand même (juste pas d'arme visible).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Spring = require(Shared.Spring)

local ViewModelController = {}

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local current = nil -- modèle cloné affiché
local ads = false
local kickSpring = Spring.new(90, 12) -- recul du viewmodel
local bobPhase = 0

-- ⚙️ Décalages (ajuste si l'arme est mal placée à l'écran)
local HIP_OFFSET = CFrame.new(1.1, -1.4, -1.8) -- droite, bas, avant
local ADS_OFFSET = CFrame.new(0, -1.05, -1.3) -- centrée pour la visée

-- Prépare un modèle pour l'affichage (ancré, sans collision, sans ombre)
local function prep(model: Model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CastShadow = false
			part.Massless = true
		end
	end
end

function ViewModelController.unequip()
	if current then
		current:Destroy()
		current = nil
	end
end

-- Charge le modèle de l'arme (cfg = config de l'arme)
function ViewModelController.equip(cfg)
	ViewModelController.unequip()
	if not cfg or not cfg.ModelName or cfg.ModelName == "" then
		return
	end
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local folder = assets and assets:FindFirstChild("ViewModels")
	local template = folder and folder:FindFirstChild(cfg.ModelName)
	if not template then
		return -- pas de modèle : on n'affiche rien (le jeu marche quand même)
	end

	current = template:Clone()
	prep(current)
	current.Parent = camera -- enfant de la caméra = visible localement uniquement
end

function ViewModelController.setAds(value: boolean)
	ads = value
end

-- Petit coup de recul du viewmodel au tir
function ViewModelController.kick()
	kickSpring:impulse(Vector3.new(-0.25, 0, 0.4)) -- recule + remonte
end

local function onRender(dt: number)
	if not current then
		return
	end
	camera = Workspace.CurrentCamera

	-- Balancement à la marche (bob)
	local bobAmount = 0
	local char = player.Character
	if char then
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if hum and hum.MoveDirection.Magnitude > 0.1 then
			bobPhase += dt * 10
			bobAmount = math.sin(bobPhase) * 0.04
		end
	end

	-- Recul (ressort)
	local kick = kickSpring:update(dt)

	local offset = ads and ADS_OFFSET or HIP_OFFSET
	local target = camera.CFrame
		* offset
		* CFrame.new(0, bobAmount, kick.Z)
		* CFrame.Angles(kick.X, 0, 0)

	current:PivotTo(target)
end

function ViewModelController.start()
	-- Après la caméra, pour coller au mouvement de la vue
	RunService:BindToRenderStep("FPSViewModel", Enum.RenderPriority.Camera.Value + 2, onRender)

	player.CharacterAdded:Connect(function()
		ViewModelController.unequip()
	end)
end

return ViewModelController
