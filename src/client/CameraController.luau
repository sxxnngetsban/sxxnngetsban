--!nonstrict
-- CameraController
-- Applique le recul (kick + récupération) et le champ de vision (visée/ADS) à la caméra.

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Spring = require(Shared.Spring)

local CameraController = {}

local camera = Workspace.CurrentCamera
local recoilSpring = Spring.new(140, 14)
local recoilTarget = Vector3.zero -- recul accumulé (X=pitch, Y=yaw)
local recoilRecovery = 12

local currentFov = 70
local targetFov = 70
local fovSpeed = 12

local function onRender(dt: number)
	camera = Workspace.CurrentCamera

	-- Le recul accumulé revient progressivement vers zéro (récupération)
	recoilTarget = recoilTarget:Lerp(Vector3.zero, math.clamp(recoilRecovery * dt, 0, 1))
	recoilSpring:setTarget(recoilTarget)
	local r = recoilSpring:update(dt)

	-- Applique la rotation de recul par-dessus la caméra
	camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(r.X), math.rad(r.Y), 0)

	-- Champ de vision (lissé)
	currentFov = currentFov + (targetFov - currentFov) * math.clamp(fovSpeed * dt, 0, 1)
	camera.FieldOfView = currentFov
end

-- Ajoute un coup de recul (degrés)
function CameraController.addRecoil(pitch: number, yaw: number)
	recoilTarget = recoilTarget + Vector3.new(pitch, yaw, 0)
end

function CameraController.setRecoilRecovery(value: number)
	recoilRecovery = value
end

-- Définit le FOV cible et la vitesse de transition
function CameraController.setFov(fov: number, speed: number?)
	targetFov = fov
	if speed then
		fovSpeed = speed
	end
end

function CameraController.start()
	currentFov = camera.FieldOfView
	targetFov = currentFov
	RunService:BindToRenderStep("FPSCameraRecoil", Enum.RenderPriority.Camera.Value + 1, onRender)
end

return CameraController
