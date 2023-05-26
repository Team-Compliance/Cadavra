local mod = RegisterMod("Cadavra", 1)
local game = Game()
local sound = SFXManager()
local rng = RNG()

local CADAVRA_HEAD = Isaac.GetEntityVariantByName("Cadavra")
local CHUBS = Isaac.GetEntityVariantByName("Chubs (Cadavra)")
local NIBS = Isaac.GetEntityVariantByName("Nibs (Cadavra)")
local CORD = Isaac.GetEntityVariantByName("Cadavra (Cord)")
mod.GatheredProjectilesCad = {}

local function Lerp(v1, v2, t)
	return (v1 + (v2 - v1)*t)
end

function mod:QuickCordCad(parent, child, anm2)
	local cord = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 0, parent.Position, Vector.Zero, parent):ToNPC()
	cord.Parent = parent
	cord.Target = child
	parent.Child = cord
	cord.DepthOffset = child.DepthOffset - 150
	cord.SpriteOffset = Vector(0, 0)
	
	
	if anm2 then
		cord:GetSprite():Load("gfx/bosses/Cadavra_cord_2.anm2", true)
	end
	
	return cord
end
 
function mod:CadavraAI(npc)
    if npc.Variant ~= CADAVRA_HEAD then
		return
	end
    local room = game:GetRoom()
	local data = npc:GetData()
	local rng = npc:GetDropRNG()
	
	local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget()
    local dir = player.Position - npc.Position
	local body = nil
	if not data.init then
	    npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	    data.state = "Normal"
		data.damaged = false
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        data.bloodExplode = false
		data.Attacked = 0
		data.Pos1 = npc.Position
		data.Cord = 0
        data.init = true
	end
	
	local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, CHUBS, -1, false, false)	
	local Bodycount2 = Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)	
    
    -- Appear --
	
    if data.state == "Normal" then
        if sprite:IsFinished("Appear") or sprite:IsFinished("Head_Shoot") or sprite:IsFinished("Head_Shoot_Big") then
            data.noise = true
			data.last = npc.FrameCount
			sprite:Play("Idle", true)
		end
		
		if sprite:IsPlaying("Idle") then
			npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Resized(3)
			if data.last + 15 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				
				sprite:Play("Head_Shoot", true)
			elseif data.last + 20 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				
				sprite:Play("Head_Shoot_Big", true)
			elseif data.last + 25 < npc.FrameCount and (#Bodycount > 0 or #Bodycount2 > 0) then
			if #Bodycount > 0 and #Bodycount2 == 0 then
			data.Choose = 1
			elseif #Bodycount2 > 0 and #Bodycount == 0 then
			data.Choose = 2
			else
			data.Choose = math.random(1,2)
			end
			print(data.Choose)
			data.last = npc.FrameCount
			sprite:Play("ApproachBody", true)
			data.state = "findbody"
			end
		end
		if sprite:IsPlaying("Head_Shoot") then
		npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Resized(1.25)
			--[[sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT, 0.6, 0, false, math.random(9,11)/10)
			local vector = (player.Position-npc.Position):Resized(15)
			local params = ProjectileParams()
			params.Variant = 0
			npc:FireProjectiles(npc.Position, vector, 3, params)]]
				if sprite:GetFrame() > 13 and sprite:GetFrame() < 20 and sprite:GetFrame() % 2 == 0 then
				angle = math.random(1,360);
				mag = math.random(5,10);
				projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position, (player.Position-npc.Position):Resized(math.random(3,5)):Rotated(math.random(-50,50)), nil):ToProjectile()
				projectile.ProjectileFlags = ProjectileFlags.DECELERATE
                projectile.FallingSpeed = 0
				projectile.FallingAccel = -0.1
				projectile.ChangeTimeout = 270
				projectile2 = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position, (player.Position-npc.Position):Resized(math.random(3,5)):Rotated(math.random(-100,100)), nil):ToProjectile()
				projectile2.ProjectileFlags = ProjectileFlags.DECELERATE
				projectile2.FallingSpeed = 0
				projectile2.FallingAccel = -0.1
				projectile2.ChangeTimeout = 270
				sound:Play(SoundEffect.SOUND_BOSS2_BUBBLES,1,0,false,1)
				end
		end
		
		if sprite:IsPlaying("Head_Shoot_Big") then
		npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Resized(1.25)
			if sprite:IsEventTriggered("Shoot") then
		        npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT,1,0,false,1)
			    npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_0,1,0,false,1)
			    local vector = (player.Position-npc.Position)*0.056
			    local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, npc.Position, vector, npc):ToProjectile();
			    data.tearColor2 = Color(1,1,1,1)
				data.tearColor2:SetColorize(1.5,2.2,0.8,1)
				
				tear:GetSprite().Color = data.tearColor2
    				tear.Scale = 2
			    	tear.FallingSpeed = -26;
				tear.FallingAccel = 2;
			    tear:GetData().cadBoom = true
			    tear:GetData().cadBoomTears = true
			    tear:GetData().cadGasLife = 325/2
			end
		
		end
		
		--[[if sprite:IsPlaying("Idle") and ((data.Phase == 1 and npc.HitPoints < npc.MaxHitPoints * .60) or (data.Phase == 2 and npc.HitPoints < npc.MaxHitPoints * .30)) then

			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			data.Choose = math.random(1,2)
			print(data.Choose)
			data.last = npc.FrameCount
			sprite:Play("ApproachBody", true)
			data.state = "findbody"
			--rng:RandomInt(1,2)
		end]]
	
	elseif data.state == "findbody" then
		if sprite:IsPlaying("ApproachBody") then
			if data.Choose == 1 then
				--local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, CHUBS, -1, false, false)
				if #Bodycount > 0 then
					for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, CHUBS, -1, false, false)) do
						local entityData = entity:GetData()
						if entityData.state == "nohost" then
							body = entity
							
							break
						else
							data.Choose = 2
							print(data.Choose)
						end
					end
				else
					data.Choose = 2
					print(data.Choose)
				end
			end
			if data.Choose == 2 then
				--local Bodycount2 = Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)
				if #Bodycount2 > 0 then
					for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)) do
						local entityData = entity:GetData()
						if entityData.state == "nohost" then
							body = entity
							break
						else
							data.Choose = 1
							print(data.Choose)
						end
					end
				else
					data.Choose = 1
					print(data.Choose)
				end
			end
			--[[if data.Choose == 2 then
				for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)) do
					local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)
					if #Bodycount > 0 then
						local entityData = entity:GetData()
							if entityData.state == "nohost" then
								body = entity
								break
							else
								break
								data.Choose = 1
								print(data.Choose)
							end
					else
						break
						data.Choose = 1
						print(data.Choose)
						
					
				end
			end
		end]]
			
		
		
		
		if body.Position:Distance(npc.Position)<= 5 then
			if data.Choose == 1 then 
			data.Startefusionbody = body
			local Bodydata, bodysprite = data.Startefusionbody:GetData(), data.Startefusionbody:GetSprite()
				if bodysprite:IsPlaying("Chubs_Enter") then
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					data.last = npc.FrameCount
					npc.Velocity = Vector.Zero
					sprite:Play("Idle", true)
					data.state = "insidebody"
					return
				else
					body.Parent = npc
					Bodydata.Doactivate = true
				end
			elseif data.Choose == 2 then
				data.Startefusionbody = body
			local Bodydata, bodysprite = data.Startefusionbody:GetData(), data.Startefusionbody:GetSprite()
				if bodysprite:IsPlaying("Nibs_Enter") then
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					data.last = npc.FrameCount
					npc.Velocity = Vector.Zero
					sprite:Play("Idle", true)
					data.state = "insidebody"
	
					return
				else
					body.Parent = npc
					Bodydata.Doactivate = true
				end
			end
		elseif body.Position:Distance(npc.Position)<= 75 and body.Position:Distance(npc.Position)> 30 then
			data.velo = (body.Position - npc.Position):Resized(1)
			npc:AddVelocity(data.velo)
		elseif body.Position:Distance(npc.Position)<= 30 then
			npc.Velocity = (body.Position - npc.Position):Resized(6)
		else
			data.velo = (body.Position - npc.Position):Resized(0.1)
			npc:AddVelocity(data.velo)
			if sprite:GetFrame() == 5 then
					angle = math.random(1,360);
					mag = math.random(5,10);
					projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position, (player.Position-npc.Position):Resized(math.random(3,5)):Rotated(math.random(-360,360)), nil):ToProjectile()
					projectile.ProjectileFlags = ProjectileFlags.DECELERATE
					projectile.FallingSpeed = 1
					projectile.FallingAccel = -0.1
					projectile.ChangeTimeout = 270
					sound:Play(SoundEffect.SOUND_BOSS2_BUBBLES,1,0,false,1)
				end
		end
		
		end
	
	
	elseif data.state == "insidebody" then
		data.Choose = 0 
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		if sprite:IsPlaying("Idle") then
		data.last = npc.FrameCount
		npc.Visible = false
		end
		
	elseif data.state == "Escape" then
		if data.damaged == false then
			npc.HitPoints = npc.HitPoints - (npc.HitPoints * 0.25)
			data.damaged = true
		end
		data.Cord = 0
		data.Attacked = 0
		npc.Velocity = RandomVector()*1
		npc.Position = data.Pos1
		if sprite:IsPlaying("BodyDestroyed") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		npc.Visible = true
		elseif sprite:IsFinished("BodyDestroyed") then
		data.last = npc.FrameCount
		sprite:Play("Idle", true)
		data.state = "Normal"
		end
	elseif data.state == "Abandon" then
		data.Attacked = 0
		npc.Position = data.Pos1
		data.last = npc.FrameCount
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		npc.Visible = true
		sprite:Play("Idle", true)
		data.state = "Normal"
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavraAI, EntityType.ENTITY_CADAVRA)


function mod:CadavrasChubsBodyAI(npc)
	if npc.Variant ~= CHUBS then
		return
	end
	local room = game:GetRoom()
	local data = npc:GetData()
	local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget()
	local rng = npc:GetDropRNG()
	local angle = npc.Velocity:GetAngleDegrees()

	
	
	if not data.init then
		npc.HitPoints = 300
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.state = "nohost"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		sprite:Play("Chubs_Body", true)
		data.init = true
		data.GridCountdown = 0
		data.direction = false
		data.repeatjump = 0
		data.Attacked = 0
	end
	
	if data.Doactivate then
		data.Activated = true
		data.Attacked = 0
		sprite:Play("Chubs_Enter", true)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		data.last = 0
		data.Doactivate = false
	end

	if data.Activated then
		if sprite:IsFinished("Chubs_Enter") then
			data.state = "Walk"
		end
	end
	
	if data.state == "Walk" then
		npc:AnimWalkFrame("Chubs_WalkHori", "Chubs_WalkVert", 0.3)
		
		
		if npc:CollidesWithGrid() or data.GridCountdown > 0 then
			npc.Pathfinder:FindGridPath(player.Position, 0.3, 1, false)
			if data.GridCountdown <= 0 then
				data.GridCountdown = 30
			else
				data.GridCountdown = data.GridCountdown - 1
			end
		else 
			npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Normalized() * 0.3 * 6
		end
		
		if data.last + 20 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				data.state = "Attack1"
				sprite:Play("Chubs_Jump_Big", true)
				npc.Velocity = Vector.Zero
				data.Attacked = data.Attacked + 1
		elseif data.last + 23 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				data.repeatjump = 0		
				npc.Velocity = Vector.Zero
				data.state = "Attack2"
				data.direction = false
				data.Attacked = data.Attacked + 1
		elseif (data.Attacked > 0 and data.last + 23 < npc.FrameCount and rng:RandomInt(50) == rng:RandomInt(50)) or data.Attacked == 5 then
				sprite:Play("Chubs_Abandon", true)
				npc.Velocity = Vector.Zero
				data.state = "Abandon"
		end
	
	
	elseif data.state == "Attack1" then
		if sprite:IsPlaying("Chubs_Jump_Big") then
			sprite.FlipX = false
			if sprite:IsEventTriggered("Jump") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = GridCollisionClass.COLLISION_PIT
			npc.Velocity = (player.Position-npc.Position)*0.056
			sound:Play(SoundEffect.SOUND_BOSS_LITE_ROAR, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Shoot") then
				sound:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				npc.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
				npc.Velocity = Vector.Zero
				angle = (player.Position - npc.Position):GetAngleDegrees()
				for _ = 1,(rng:RandomInt(5)+7) do
					local params = ProjectileParams()
					params.Variant = 0
					params.FallingSpeedModifier = -(rng:RandomInt(27) + 8) * 0.4
					params.FallingAccelModifier = 0.3
					npc:FireProjectiles(npc.Position, Vector.FromAngle(angle+(rng:RandomInt(359)+1)):Resized((rng:RandomInt(3) + 4)), 0, params)
				end
				for i = 1, 6 do
					local direction = (i*(360/6)) + (rng:RandomInt(20) - 10)
					local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKWAVE, 2, npc.Position + Vector.FromAngle(direction) * 10, Vector.Zero, npc):ToEffect()
					wave.Parent = npc
					wave.Rotation = direction
				end
			end
		elseif sprite:IsFinished("Chubs_Jump_Big") then
		data.state = "Walk"
		data.last = npc.FrameCount
		end
	
	elseif data.state == "Attack2" then
		sprite.FlipX = false
			if data.direction == false then
			sound:Play(SoundEffect.SOUND_BOSS_LITE_ROAR, 1, 0, false, 1)	
			local angle = (player.Position - npc.Position):GetAngleDegrees()
				if angle >= -45 and angle <= 45 then
					sprite:Play("Chubs_JumpRight", true)
				elseif angle >= 45 and angle <= 135 then
					sprite:Play("Chubs_JumpDown", true)
				elseif angle >= -135 and angle <= -45 then
					sprite:Play("Chubs_JumpUp", true)
				else
					sprite:Play("Chubs_JumpLeft", true)
				end
			data.direction = true
			end
		if sprite:IsPlaying("Chubs_JumpRight") or sprite:IsPlaying("Chubs_JumpUp") or sprite:IsPlaying("Chubs_JumpLeft") or sprite:IsPlaying("Chubs_JumpDown") then
			
			if sprite:IsEventTriggered("Jump") then
			npc.Velocity = (player.Position-npc.Position) * 0.05
			elseif sprite:IsEventTriggered("Shoot") then
			sound:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
			for _ = 1,(rng:RandomInt(2)+4) do
					local params = ProjectileParams()
					params.Variant = 0
					params.FallingSpeedModifier = -(rng:RandomInt(27) + 8) * 0.4
					params.FallingAccelModifier = 0.3
					npc:FireProjectiles(npc.Position, Vector.FromAngle(angle+(rng:RandomInt(359)+1)):Resized((rng:RandomInt(3) + 4)), 0, params)
			end
			for i = 1,8 do
			local vector = Vector(math.cos(i*math.pi/4),math.sin(i*math.pi/4)):Resized(6)
			Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0,npc.Position, vector, npc)
		end
				npc.Velocity = Vector.Zero
			end
		elseif sprite:IsFinished("Chubs_JumpRight") or sprite:IsFinished("Chubs_JumpUp") or sprite:IsFinished("Chubs_JumpLeft") or sprite:IsFinished("Chubs_JumpDown") then
				if data.repeatjump <= 1 then
					data.repeatjump = data.repeatjump + 1
					data.direction = false
					
				else
					data.state = "Walk"
					data.last = npc.FrameCount
				end
		end
	elseif data.state == "Abandon" then
		sprite.FlipX = false
		if sprite:IsFinished("Chubs_Abandon") then
		local entityData = npc.Parent:GetData()
		entityData.state = "Abandon" 
		entityData.damaged = false
		data.state = "nohost"
		entityData.Pos1 = npc.Position
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		sprite:Play("Chubs_Body", true)
		data.Activated = false
		end
	end 
end
	
	if npc:IsDead() then
			local entityData = npc.Parent:GetData()
			entityData.state = "Escape"
			entityData.damaged = false
			entityData.Pos1 = npc.Position
			npc.Parent:GetSprite():Play("BodyDestroyed", true)
	end
end


mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavrasChubsBodyAI, EntityType.ENTITY_CADAVRA)

function mod:CadavrasNibsBodyAI(npc)
	if npc.Variant ~= NIBS then
		return
	end
	local room = game:GetRoom()
	local data = npc:GetData()
	local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget()
	local rng = npc:GetDropRNG()
	
	
	data.clusterParams = ProjectileParams()
	data.clusterParams.FallingAccelModifier = -0.1
	data.ColorWigglyMaggot = Color(1,1,1,1,0,0,0)
	data.ColorWigglyMaggot:SetColorize(4,3,3,1)
	data.clusterParams.Color = data.ColorWigglyMaggot
	
	if not data.init then
		npc.HitPoints = 150
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.state = "nohost"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		data.last = npc.FrameCount
		sprite:Play("Nibs_Body", true)
		data.Startmovinge = 0
		data.Cord = 0
		data.Attacked = 0
		data.init = true
	end
	if data.GridCountdown == nil then data.GridCountdown = 0 end
	
	if data.Doactivate then
		data.Activated = true
		data.Attacked = 0
		sprite:Play("Nibs_Enter", true)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		
		if npc.HitPoints <= 50 then
			npc.HitPoints = 150 + npc.HitPoints
		end
		data.Doactivate = false
	end

	if data.Activated then
		if sprite:IsFinished("Nibs_Enter") then
			data.state = "Walk"
		end
	end
	
	if data.state == "Walk" then
		npc:AnimWalkFrame("Nibs_WalkHori", "Nibs_WalkVert", 0.1)
		
		
		if npc:CollidesWithGrid() or data.GridCountdown > 0 then
			npc.Pathfinder:FindGridPath(player.Position, 0.6, 1, false)
			if data.GridCountdown <= 0 then
				data.GridCountdown = 30
			else
				data.GridCountdown = data.GridCountdown - 1
			end
		else 
			npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Normalized() * 0.5 * 6
		end
		
		if data.last + 15 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				data.state = "Attack1"
				sprite:Play("Nibs_Shoot", true)
				npc.Velocity = Vector.Zero
				data.Attacked = data.Attacked + 1
		elseif data.last + 40 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) or (npc.Position:Distance(player.Position) > 250) then
				data.state = "Cord"
				data.Startmovinge = 0
				data.Attacked = data.Attacked + 1
				sprite:Play("Nibs_Cord", true)
				npc.Velocity = Vector.Zero
		elseif (data.Attacked > 0 and data.last + 40 < npc.FrameCount and rng:RandomInt(50) == rng:RandomInt(50)) or data.Attacked >= 5 then
				sprite:Play("Nibs_Abandon", true)
				npc.Velocity = Vector.Zero
				data.state = "Abandon"
		end
		
		
		
	elseif data.state == "Attack1" then
	if sprite:IsPlaying("Nibs_Shoot") then
		if sprite:IsEventTriggered("Shoot") then
		sound:Play(SoundEffect.SOUND_BOSS_SPIT_BLOB_BARF,1,0,false,1)
		mod.FireClusterProjectilesCad(npc, (player.Position - npc.Position):Resized(10), 10, data.clusterParams)
		end
	elseif sprite:IsFinished("Nibs_Shoot") then
		data.state = "Walk"
		data.last = npc.FrameCount
	end 
	
	elseif data.state == "Cord" then
	if sprite:IsPlaying("Nibs_Cord") then
		if sprite:IsEventTriggered("Shoot") then
			sound:Play(SoundEffect.SOUND_MEATHEADSHOOT, 0.6, 0, false, math.random(9,11)/10)
			local cordEnd = Isaac.Spawn(EntityType.ENTITY_CADAVRA, CORD, 0, npc.Position, Vector.Zero, npc)
			cordEnd.Parent = npc
			cordEnd.SpriteOffset = Vector(0, -10)
			cordEnd.Visible = true
			cordEnd:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
	elseif sprite:IsFinished("Nibs_Cord") then
		sprite:Play("Nibs_CordLoop", true)
		end
	if sprite:IsPlaying("Nibs_CordLoop") then
		if data.Startmovinge == 1 then
			for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, CORD, -1, false, false)) do
				local entityData = entity:GetData()
				if entity:Exists() then
					cordEnd2 = entity
					break
				end
			end
			if cordEnd2.Position:Distance(npc.Position) <= 15 then
				sprite:Play("Nibs_CordEnd", true)
				sound:Play(SoundEffect.SOUND_BLOODSHOOT, 0.6, 0, false, math.random(9,11)/10)
				npc.Velocity = Vector.Zero
				local params = ProjectileParams()
				data.tearColor2 = Color(1,1,1,1)
				data.tearColor2:SetColorize(1.5,2.2,0.8,1)
				params.Color = data.tearColor2
				params.Spread = 2
				npc:FireProjectiles(npc.Position, (player.Position - npc.Position):Resized(7), 5, params)
				for i, entity2 in pairs(Isaac.GetRoomEntities()) do
					if entity2.Type == EntityType.ENTITY_EVIS then
					entity2:Remove()
					end
				end
				cordEnd2:Remove()
				
			else
			npc:AddVelocity((cordEnd2.Position - npc.Position):Resized(1))
				if sprite:GetFrame() % 6 == 0 then
				sound:Play(SoundEffect.SOUND_BLOODSHOOT, 0.6, 0, false, math.random(9,11)/10)
				local veloc = npc.Velocity
				data.tearColor2 = Color(1,1,1,1)
				data.tearColor2:SetColorize(1.5,2.2,0.8,1)
				local params = ProjectileParams()
				params.BulletFlags = ProjectileFlags.ACCELERATE 
				params.Variant = 0
				params.Spread = 6
				params.Color = data.tearColor2
				params.Acceleration = 1+1/24
				npc:FireProjectiles(npc.Position, veloc:Resized(2), 1, params)
				end
			end
		end
	end
	if sprite:IsFinished("Nibs_CordEnd") then
		data.state = "Walk"
		data.last = npc.FrameCount
	end
	elseif data.state == "Abandon" then
		sprite.FlipX = false
		if sprite:GetFrame() == 31 then 
		local entityData = npc.Parent:GetData()
		entityData.state = "Abandon" 
		entityData.damaged = false
		data.state = "nohost"
		entityData.Pos1 = npc.Position
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		sprite:Play("Nibs_Body", true)
		data.Activated = false
		end
	end 
	
	
	
	if npc:IsDead() then
			local entityData = npc.Parent:GetData()
			entityData.state = "Escape"
			entityData.Pos1 = npc.Position
			npc.Parent:GetSprite():Play("BodyDestroyed", true)
			for i, entity2 in pairs(Isaac.GetRoomEntities()) do
			if entity2.Type == EntityType.ENTITY_EVIS or (entity2.Type == EntityType.ENTITY_EVIS and entity2.Variant == CORD) then
				entity2:Remove()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavrasNibsBodyAI, EntityType.ENTITY_CADAVRA)

function mod:CadavrasNibsCordAI(npc)
	if npc.Variant ~= CORD then
		return
	end
	local room = game:GetRoom()
	local data = npc:GetData()
	local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget()
	local rng = npc:GetDropRNG()
	
	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		sprite:Play("CordEnds", true)
		data.init = true
	end
	if data.Cord == nil then
	mod:QuickCordCad(npc.Parent, npc, "Cadavra_cord_2")
	data.Cord = 1
	end
	if data.move == nil then
	npc.Velocity = (player.Position - npc.Position):Resized(15)
	data.move = 1 
	end
	
	if npc:CollidesWithGrid()then
		npc.Velocity = Vector.Zero
		npc.Parent:GetData().Startmovinge = 1
	end
		
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavrasNibsCordAI, EntityType.ENTITY_CADAVRA)

function mod:Cadavrasboom(tear,collided)
    local d = tear:GetData()
	local rng = tear:GetDropRNG()
		if d.pestBoomTarget then
			if not d.target then
				d.target = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, tear.Position,Vector.Zero, tear):ToEffect()
				local targetColor = Color(0.4,1,0.3,1)
				d.target:SetColor(targetColor, 120, 1, false, false)
				d.target.Timeout = 100
			end
		end
    if tear:IsDead() or collided then
			
		if d.target then
		    d.target:Remove()
		end
    local boomColor = Color(1,1,1,1)
	boomColor:SetColorize(1.3,2,0.7,1)
	    
    local explode = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, tear.Position, Vector.Zero, tear):ToEffect()
    explode:GetSprite().Color = boomColor
	    
	for i, entity in ipairs(Isaac.FindInRadius(tear.Position, 60)) do
	    if entity.Type ~= EntityType.ENTITY_PLAYER and entity.Type ~= EntityType.ENTITY_CADAVRA then
				entity:TakeDamage(2, DamageFlag.DAMAGE_EXPLOSION, EntityRef(tear), 0)
		end
	end
	
	local gas = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, tear.Position, Vector.Zero, tear):ToEffect()
	gas.Timeout = 123
	
	if tear:GetData().cadBoomTears then
	        local tearNum = 6
		    local vector = Vector(1,0)*10
		    local tearSpin = 0
			tearSpin = rng:RandomInt(360)
		    
		    for i=0,tearNum do
			    local rotated = (i*(360/tearNum)) + tearSpin
			    local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, tear.Position, vector:Rotated(rotated), tear):ToProjectile()
			    tear:GetSprite().Color = boomColor
		    end
	    end
	
	    
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, tear)
	if tear:GetData().cadBoom then
		mod:Cadavrasboom(tear,false)
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, function(_, tear, collider)
	if tear:GetData().cadBoom then
		mod:Cadavrasboom(tear,true)
	end
end)

if StageAPI and StageAPI.Loaded then
	mod.StageAPIBosses = {
		StageAPI.AddBossData("Cadavra", {
			Name = "Cadavra",
			Portrait = "gfx/ui/boss/portrait_cadavra.png",
			Bossname = "gfx/ui/boss/bossname_cadavra.png",
			Weight = 2,
			Rooms = StageAPI.RoomsList("Cadavra Rooms", require("resources.luarooms.boss_cadavra")),
		})
	}
	
	StageAPI.AddBossToBaseFloorPool({BossID = "Cadavra"}, LevelStage.STAGE4_1, StageType.STAGETYPE_REPENTANCE)
end



function mod:DummyEffectInitCad(effect)
    effect.Visible = false
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.DummyEffectInitCad, 451)

function mod:DummyEffectAICad(effect, sprite, data)
    local room = game:GetRoom()
	
    if effect:GetData().corpseClusters then
        --[[if effect.FrameCount % 3 == 0 then
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, effect.Position, effect.Velocity:Resized(-5), effect):ToEffect()
            trail.SpriteOffset = Vector(0, -25)
            trail.DepthOffset = -15
            trail.Color = mod.ColorRedPoop
            trail:Update()
        end]]
        if room:GetGridCollisionAtPos(effect.Position) >= GridCollisionClass.COLLISION_SOLID then
            for _, projectile in pairs(effect:GetData().corpseClusters) do
                projectile.Velocity = effect.Velocity:Rotated(180 + mod:RandomInt(-60,60))
                projectile:GetData().projType = nil
                projectile:ClearProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
            end
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
            effect:Remove()
        end
    elseif data.afterImage then
		local cloud = Isaac.Spawn(1000,16,5,effect.Position,Vector.Zero,effect)
            cloud.Color = mod.ColorRedPoop
            cloud.SpriteScale = Vector(0.7,0.7)
        if effect.FrameCount > 10 then
            effect:Remove()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.DummyEffectAICad, 451)

function mod:CadsProjectileUpdate(projectile, sprite, data)
	local projType = data.projType
	if projType == "corpseClusterCad" then
        mod:CorpseClusterProjectileCad(projectile, data)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, projectile)
    local data = projectile:GetData()
    local sprite = projectile:GetSprite()
    mod:CadsProjectileUpdate(projectile, sprite, data)
    --mod:PrintColor(projectile.Color)
    --print(projectile.Variant)
end)

function mod:CorpseClusterProjectileCad(projectile, data)
    data.Angle = mod:RandomAngle()
    projectile.TargetPosition = projectile.Parent.Position + Vector.One:Resized(mod:RandomInt(30,40)):Rotated(data.Angle)
    local vec = projectile.TargetPosition - projectile.Position
    vec = vec:Resized(math.min(40, vec:Length()))
    projectile.Velocity = Lerp(projectile.Velocity, vec, 0.02)
end

function mod:RandomAngle(customRNG)
    local rand = customRNG or rng
    return mod:RandomInt(0,359,rand)
end

function mod:RandomInt(min, max, customRNG)
    local rand = customRNG or rng
    if not max then
        max = min
        min = 0
    end  
    if min > max then 
        local temp = min
        min = max
        max = temp
    end
    return min + (rand:RandomInt(max - min + 1))
end



mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, projectile)
    local data = projectile:GetData()
    if mod.GatheringProjectilesCad then
        table.insert(mod.GatheredProjectilesCad, projectile)
    end
end)

function mod:SetGatheredProjectilesCad()
    mod.GatheredProjectilesCad = {}
    mod.GatheringProjectilesCad = true
end

function mod:GetGatheredProjectilesCad()
    mod.GatheringProjectilesCad = false
    return mod.GatheredProjectilesCad
end

function mod.FireClusterProjectilesCad(npc, velocity, numProjectiles, params)
	local corpseClusterParentCad = Isaac.Spawn(1000, 451, 10, npc.Position, velocity, npc)
	
	
	local params = params or ProjectileParams()
	params.FallingAccelModifier = -0.1
	params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE

	mod:SetGatheredProjectilesCad()
	

	for i = 1, numProjectiles or 12 do
		npc:FireProjectiles(npc.Position, velocity, 0, params)
	end

	local projectiles = mod:GetGatheredProjectilesCad()
	for i, projectile in pairs(projectiles) do
		projectile:GetData().projType = "corpseClusterCad"
		projectile.Parent = corpseClusterParentCad
		projectile.Scale = projectile.Scale * (8 + math.random() * 8) / 10
	end
	
	corpseClusterParentCad:GetData().corpseClusters = projectiles
	return projectiles, corpseClusterParentCad
end
