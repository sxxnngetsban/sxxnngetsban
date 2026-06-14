--!nonstrict
-- Spring
-- Petit ressort amorti (Vector3) pour le recul caméra, le sway et le bob du viewmodel.
-- Modèle physique : F = -k*x - c*v

local Spring = {}
Spring.__index = Spring

function Spring.new(stiffness: number?, damping: number?)
	return setmetatable({
		position = Vector3.zero,
		velocity = Vector3.zero,
		target = Vector3.zero,
		stiffness = stiffness or 120,
		damping = damping or 18,
	}, Spring)
end

-- Donne une impulsion instantanée à la vitesse
function Spring:impulse(force: Vector3)
	self.velocity = self.velocity + force
end

-- Fixe la cible vers laquelle le ressort tend
function Spring:setTarget(target: Vector3)
	self.target = target
end

-- Avance la simulation de dt secondes et renvoie la position courante.
-- Intégration semi-implicite (stable même avec un grand dt).
function Spring:update(dt: number): Vector3
	-- Clamp dt pour éviter l'explosion si la frame a lag
	if dt > 0.05 then
		dt = 0.05
	end
	local displacement = self.position - self.target
	local force = (displacement * -self.stiffness) - (self.velocity * self.damping)
	self.velocity = self.velocity + force * dt
	self.position = self.position + self.velocity * dt
	return self.position
end

function Spring:reset()
	self.position = Vector3.zero
	self.velocity = Vector3.zero
	self.target = Vector3.zero
end

return Spring
