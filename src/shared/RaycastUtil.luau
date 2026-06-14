--!nonstrict
-- RaycastUtil
-- Helpers de raycast partagés client/serveur.

local RaycastUtil = {}

-- Applique une dispersion (en degrés) à une direction unitaire.
function RaycastUtil.applySpread(direction: Vector3, spreadDegrees: number): Vector3
	if spreadDegrees <= 0 then
		return direction
	end
	-- Cône aléatoire autour de la direction
	local spreadRad = math.rad(spreadDegrees)
	-- Angle aléatoire dans le cône (distribution surfacique correcte)
	local theta = math.random() * 2 * math.pi
	local phi = math.acos(1 - math.random() * (1 - math.cos(spreadRad)))

	-- Base orthonormée autour de direction
	local up = math.abs(direction.Y) < 0.99 and Vector3.yAxis or Vector3.xAxis
	local right = direction:Cross(up).Unit
	local realUp = right:Cross(direction).Unit

	local x = math.sin(phi) * math.cos(theta)
	local y = math.sin(phi) * math.sin(theta)
	local z = math.cos(phi)

	return (right * x + realUp * y + direction * z).Unit
end

-- Construit des RaycastParams excluant une liste d'instances.
function RaycastUtil.makeParams(ignoreList: { Instance }): RaycastParams
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignoreList or {}
	params.IgnoreWater = true
	return params
end

-- Trouve l'Humanoid associé à une instance touchée (remonte la hiérarchie).
function RaycastUtil.getHumanoidFromHit(hitInstance: Instance?): (Humanoid?, Model?)
	if not hitInstance then
		return nil, nil
	end
	local model = hitInstance:FindFirstAncestorWhichIsA("Model")
	while model do
		local humanoid = model:FindFirstChildWhichIsA("Humanoid")
		if humanoid then
			return humanoid, model
		end
		model = model:FindFirstAncestorWhichIsA("Model")
	end
	return nil, nil
end

-- Détermine si la partie touchée est la tête (pour les headshots).
function RaycastUtil.isHeadshot(hitInstance: Instance?): boolean
	if not hitInstance then
		return false
	end
	return hitInstance.Name == "Head"
end

return RaycastUtil
