--!nonstrict
-- MobileController
-- Boutons tactiles pour le mobile (~60% des joueurs Roblox) : tir, visée, recharge,
-- sprint, glissade. Le joystick et le saut sont fournis par Roblox automatiquement.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local WeaponController = require(script.Parent.WeaponController)
local MovementController = require(script.Parent.MovementController)

local MobileController = {}
local player = Players.LocalPlayer

local function makeButton(name, posScale, sizePx, text, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.Position = UDim2.fromScale(posScale.X, posScale.Y)
	btn.Size = UDim2.fromOffset(sizePx, sizePx)
	btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 35)
	btn.BackgroundTransparency = 0.35
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 18
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = btn
	return btn
end

function MobileController.start()
	if not UserInputService.TouchEnabled or UserInputService.MouseEnabled then
		return -- pas un appareil tactile : on n'affiche rien
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "FPSMobile"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Tir (maintien) — gros bouton à droite
	local fire = makeButton("Fire", Vector2.new(0.86, 0.78), 110, "TIR", Color3.fromRGB(200, 60, 60))
	fire.Parent = gui
	fire.MouseButton1Down:Connect(function()
		WeaponController.setFiring(true)
	end)
	fire.MouseButton1Up:Connect(function()
		WeaponController.setFiring(false)
	end)

	-- Visée (maintien)
	local aim = makeButton("Aim", Vector2.new(0.7, 0.85), 80, "VISER")
	aim.Parent = gui
	aim.MouseButton1Down:Connect(function()
		WeaponController.setAiming(true)
	end)
	aim.MouseButton1Up:Connect(function()
		WeaponController.setAiming(false)
	end)

	-- Recharge (tap)
	local reload = makeButton("Reload", Vector2.new(0.7, 0.68), 70, "R")
	reload.Parent = gui
	reload.Activated:Connect(function()
		WeaponController.reload()
	end)

	-- Sprint (maintien) — à gauche
	local sprint = makeButton("Sprint", Vector2.new(0.3, 0.85), 80, "SPRINT")
	sprint.Parent = gui
	sprint.MouseButton1Down:Connect(function()
		MovementController.setSprint(true)
	end)
	sprint.MouseButton1Up:Connect(function()
		MovementController.setSprint(false)
	end)

	-- Glissade (tap)
	local slide = makeButton("Slide", Vector2.new(0.44, 0.88), 66, "SLIDE")
	slide.Parent = gui
	slide.Activated:Connect(function()
		MovementController.slide()
	end)
end

return MobileController
