local mod = RegisterMod("Cadavra", 1)
local game = Game()
local sound = SFXManager()
local rng = RNG()

local CADAVRA_HEAD = Isaac.GetEntityVariantByName("Cadavra")
local CHUBS = Isaac.GetEntityVariantByName("Chubs (Cadavra)")
local NIBS = Isaac.GetEntityVariantByName("Nibs (Cadavra)")


local function Lerp(v1, v2, t)
	return (v1 + (v2 - v1)*t)
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
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        data.bloodExplode = false
		data.Phase = 1
		data.Pos1 = npc.Position
        data.init = true
	end
	
				
    
    -- Appear --
	
    if data.state == "Normal" then
        if sprite:IsFinished("Appear") or sprite:IsFinished("Head_Shoot") or sprite:IsFinished("Head_Shoot_Big") then
            data.noise = true
			data.last = npc.FrameCount
			sprite:Play("Idle", true)
		end
		
		if sprite:IsPlaying("Idle") then
			npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Resized(3)
			if data.last + 60 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				sprite:Play("Head_Shoot", true)
			elseif data.last + 130 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				sprite:Play("Head_Shoot_Big", true)
			end
		end
		if sprite:IsPlaying("Head_Shoot") then
		npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Resized(1.25)
			if sprite:IsEventTriggered("Shoot") then 
			sfx:Play(SoundEffect.SOUND_MEATHEADSHOOT, 0.6, 0, false, math.random(9,11)/10)
			local vector = (player.Position-npc.Position)*0.056
			local params = ProjectileParams()
			params.Variant = 0
			npc:FireProjectiles(npc.Position, vector, 3, params)
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
			    	tear.FallingSpeed = -30;
				tear.FallingAccel = 2;
			    tear:GetData().cadBoom = true
			    tear:GetData().cadBoomTears = true
			    tear:GetData().cadGasLife = 325/2
			end
		
		end
		
		if sprite:IsPlaying("Idle") and ((data.Phase == 1 and npc.HitPoints < npc.MaxHitPoints * .60) or (data.Phase == 2 and npc.HitPoints < npc.MaxHitPoints * .30)) then

			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			data.Choose = rng:RandomInt(1) + 1
			print(data.Choose)
			data.last = npc.FrameCount
			sprite:Play("ApproachBody", true)
			data.state = "findbody"
			--rng:RandomInt(1,2)
		end
	
	elseif data.state == "findbody" then
		if sprite:IsPlaying("ApproachBody") then
			if data.Choose == 1 then
				local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, CHUBS, -1, false, false)
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
				local Bodycount2 = Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)
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
			
		
		
		if body.Position:Distance(npc.Position)<= 2 then
			if data.Choose == 1 then 
			data.Startefusionbody = body
			local Bodydata, bodysprite = data.Startefusionbody:GetData(), data.Startefusionbody:GetSprite()
				if bodysprite:IsPlaying("Chubs_Enter") then
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
		else
			data.velo = (body.Position - npc.Position):Resized(3)
			npc.Velocity = Lerp(npc.Velocity, data.velo, 0.45)
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
		npc.Velocity = RandomVector()*1
		npc.Position = data.Pos1
		if sprite:IsPlaying("BodyDestroyed") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		npc.Visible = true
		elseif sprite:IsFinished("BodyDestroyed") then
		data.Phase = data.Phase + 1
		data.last = npc.FrameCount
		sprite:Play("Idle", true)
		data.state = "Normal"
		end
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
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.state = "nohost"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.HitPoints = 5
		sprite:Play("Chubs_Body", true)
		data.init = true
		data.GridCountdown = 0
	end
	
	if data.Doactivate then
		data.Activated = true
		
		sprite:Play("Chubs_Enter", true)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		data.last = 0
		if npc.HitPoints <= 5 then
			npc.HitPoints = 200 + npc.HitPoints
		end
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
		
		if 15 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				data.state = "Attack1"
				sprite:Play("Chubs_Jump_Big", true)
				npc.Velocity = Vector.Zero
		elseif 20 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				data.repeatjump = 0
				sprite:Play("Chubs_JumpCue", true)
				npc.Velocity = Vector.Zero
				data.state = "Attack2"
				
		end
	
	
	elseif data.state == "Attack1" then
		if sprite:IsPlaying("Chubs_Jump_Big") then
			if sprite:IsEventTriggered("Jump") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.Velocity = (player.Position-npc.Position)*0.056
			elseif sprite:IsEventTriggered("Shoot") then
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
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
		if sprite:IsFinished("Chubs_JumpCue") then
			local angle = (player.Position - npc.Position):GetAngleDegrees()
			if angle >= -45 and angle <= 45 then
				sprite:Play("Chubs_JumpRight", true)
			elseif angle >= 45 and angle <= 135 then
				sprite:Play("Chubs_JumpDown", true)
			elseif angle >= 135 and (angle <= 275 or angle <= -135) then
				sprite:Play("Chubs_JumpLeft", true)
			elseif angle >= -135 and angle <= -45 then
				sprite:Play("Chubs_JumpUp", true)
			end
		end
		if sprite:IsPlaying("Chubs_JumpRight") or sprite:IsPlaying("Chubs_JumpUp") or sprite:IsPlaying("Chubs_JumpLeft") or sprite:IsPlaying("Chubs_JumpDown") then
			if sprite:IsEventTriggered("Jump") then
				npc.Velocity = (player.Position-npc.Position) * 0.05
			elseif sprite:IsEventTriggered("Shoot") then
				for _ = 1,(rng:RandomInt(2)+4) do
					local params = ProjectileParams()
					params.Variant = 0
					params.FallingSpeedModifier = -(rng:RandomInt(27) + 8) * 0.4
					params.FallingAccelModifier = 0.3
					npc:FireProjectiles(npc.Position, Vector.FromAngle(angle+(rng:RandomInt(359)+1)):Resized((rng:RandomInt(3) + 4)), 0, params)
				end
				npc.Velocity = Vector.Zero
			end
		elseif sprite:IsFinished("Chubs_JumpRight") or sprite:IsFinished("Chubs_JumpUp") or sprite:IsFinished("Chubs_JumpLeft") or sprite:IsFinished("Chubs_JumpDown") then
				if data.repeatjump <= 1 then
					data.repeatjump = data.repeatjump + 1
					sprite:Play("Chubs_JumpCue", true)
				else
					data.state = "Walk"
					data.last = npc.FrameCount
				end
		end
	
	end 
	
	if npc:IsDead() then
		local entityData = npc.Parent:GetData()
		entityData.state = "Escape"
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
	
	
	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.state = "nohost"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.HitPoints = 5
		data.last = npc.FrameCount
		sprite:Play("Nibs_Body", true)
		data.init = true
	end
	if data.GridCountdown == nil then data.GridCountdown = 0 end
	
	if data.Doactivate then
		data.Activated = true
		
		sprite:Play("Nibs_Enter", true)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		
		if npc.HitPoints <= 5 then
			npc.HitPoints = 200 + npc.HitPoints
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
				
		end
		
		
	elseif data.state == "Attack1" then
	if sprite:IsPlaying("Nibs_Shoot") then
	elseif sprite:IsFinished("Nibs_Shoot") then
		data.state = "Walk"
		data.last = npc.FrameCount
	end 
	
	end
	
	if npc:IsDead() then
			local entityData = npc.Parent:GetData()
			entityData.state = "Escape"
			entityData.Pos1 = npc.Position
			npc.Parent:GetSprite():Play("BodyDestroyed", true)
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavrasNibsBodyAI, EntityType.ENTITY_CADAVRA)

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
			Weight = 1,
			Rooms = StageAPI.RoomsList("Cadavra Rooms", require("resources.luarooms.boss_cadavra")),
		})
	}
	
	StageAPI.AddBossToBaseFloorPool({BossID = "Cadavra"}, LevelStage.STAGE4_1, StageType.STAGETYPE_REPENTANCE)
end
