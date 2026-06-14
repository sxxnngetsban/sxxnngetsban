--!nonstrict
-- MovementController
-- Mouvement nerveux : sprint (Shift) et glissade/slide (C) — clé de la rétention sur un FPS.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MovementController = {}

local player = Players.LocalPlayer

-- Réglages (modifie ces valeurs pour ajuster le ressenti)
local WALK_SPEED = 16
local SPRINT_SPEED = 24
local SLIDE_SPEED = 46
local SLIDE_DURATION = 0.5
local SLIDE_COOLDOWN = 1.2

local sprinting = false
local sliding = false
local lastSlide = 0

local function getCharacter()
	local char = player.Character
	if not char then
		return nil, nil
	end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	return hum, hrp
end

local function isGrounded(hum: Humanoid): boolean
	return hum.FloorMaterial ~= Enum.Material.Air
end

local function startSlide()
	local hum, hrp = getCharacter()
	if not hum or not hrp then
		return
	end
	local now = os.clock()
	if sliding or now - lastSlide < SLIDE_COOLDOWN then
		return
	end
	if not isGrounded(hum) or hum.MoveDirection.Magnitude < 0.1 then
		return
	end

	sliding = true
	lastSlide = now

	-- Direction de l'élan (à plat)
	local dir = hrp.CFrame.LookVector
	local flat = Vector3.new(dir.X, 0, dir.Z)
	if flat.Magnitude < 0.05 then
		sliding = false
		return
	end
	flat = flat.Unit

	-- Contrainte de vitesse qui POUSSE le joueur vers l'avant (vrai slide)
	local att = Instance.new("Attachment")
	att.Parent = hrp
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = att
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.MaxForce = 1e6
	lv.VectorVelocity = flat * SLIDE_SPEED
	lv.Parent = hrp

	-- Caméra abaissée + on bride le contrôle pour garder l'élan
	hum.CameraOffset = Vector3.new(0, -1.3, 0)
	hum.WalkSpeed = 4

	-- L'élan décroît pendant la durée du slide
	local startT = os.clock()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		local h, root = getCharacter()
		local alpha = math.clamp((os.clock() - startT) / SLIDE_DURATION, 0, 1)
		if not h or not root or alpha >= 1 then
			conn:Disconnect()
			if lv then lv:Destroy() end
			if att then att:Destroy() end
			sliding = false
			if h then
				h.CameraOffset = Vector3.new(0, 0, 0)
				h.WalkSpeed = sprinting and SPRINT_SPEED or WALK_SPEED
			end
			return
		end
		local speed = SLIDE_SPEED * (1 - alpha)
		lv.VectorVelocity = Vector3.new(flat.X * speed, root.AssemblyLinearVelocity.Y, flat.Z * speed)
	end)
end

local function updateSprint()
	local hum = select(1, getCharacter())
	if not hum or sliding then
		return
	end
	hum.WalkSpeed = sprinting and SPRINT_SPEED or WALK_SPEED
end

-- API publique pour les contrôles mobiles
function MovementController.setSprint(value: boolean)
	sprinting = value
	updateSprint()
end

function MovementController.slide()
	startSlide()
end

function MovementController.start()
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftShift then
			sprinting = true
			updateSprint()
		elseif input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.LeftControl then
			startSlide()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			sprinting = false
			updateSprint()
		end
	end)

	-- Réinitialise la vitesse à chaque réapparition
	player.CharacterAdded:Connect(function(character)
		local hum = character:WaitForChild("Humanoid")
		sprinting = false
		sliding = false
		hum.WalkSpeed = WALK_SPEED
	end)
end

return MovementController
