local mod = RegisterMod("Cadavra", 1)
local game = Game()
local sound = SFXManager()
local sfx = SFXManager()
local rng = RNG()

local CADAVRA_HEAD = Isaac.GetEntityVariantByName("Cadavra")
local CHUBS = Isaac.GetEntityVariantByName("Chubs (Cadavra)")
local NIBS = Isaac.GetEntityVariantByName("Nibs (Cadavra)")
local CORD = Isaac.GetEntityVariantByName("Cadavra (Cord)")
mod.GatheredProjectilesCad = {}

local function Lerp(v1, v2, t)
	return (v1 + (v2 - v1)*t)
end

function mod:QuickCordCad(parent, child)
	local cord = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, 0, parent.Position, Vector.Zero, parent):ToNPC()
	cord.Parent = parent
	cord.Target = child
	parent.Child = cord
	cord.DepthOffset = parent.DepthOffset - 150
	
	-- cord.SpriteOffset = Vector(0, -60)
	-- cord.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
	-- cord.CollisionDamage = 1
	
	cord:GetSprite():Load("gfx/bosses/922.010_cadavra cord.anm2", true)
	cord:GetSprite():SetFrame("Cord", 54)
	
	return cord
end
 
function mod:CadavraAI(npc)
    if npc.Variant ~= CADAVRA_HEAD then
		return
	end
    local room = game:GetRoom()
	local data = npc:GetData()
	local rng = npc:GetDropRNG()
	
	
	data.clusterParams = ProjectileParams()
	data.clusterParams.FallingAccelModifier = -0.1
	data.ColorWigglyMaggot = Color(1,1,1,1,0,0,0)
	data.ColorWigglyMaggot:SetColorize(4,3,3,1)
	data.clusterParams.Color = data.ColorWigglyMaggot
	
	local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget()
	local body = nil
	if not data.init then
	    npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	    data.state = "Normal"
		data.damaged = false
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		data.Attacked = 0
		data.Pos1 = npc.Position
		data.Choose = rng:RandomInt(1) + 1
		data.Cord = 0
        data.init = true
		sprite:Play("Appear", true)
	end
	
	local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, CHUBS, -1, false, false)	
	local Bodycount2 = Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)	
    
    -- Appear --
	
    if data.state == "Normal" then
        if sprite:IsFinished("Appear") then
            data.noise = true
			data.last = npc.FrameCount
			sprite:Play("Idle", true)
		end
		
		if sprite:IsPlaying("Idle") then
			--npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Resized(3)
			if (#Bodycount > 0 or #Bodycount2 > 0) then
				if data.last + 23 < npc.FrameCount then
					if #Bodycount > 0 and #Bodycount2 < 1 then
					data.Choose = 1
					elseif #Bodycount2 > 0 and #Bodycount < 1 then
					data.Choose = 2
					end
				data.last = npc.FrameCount
				sprite:Play("ApproachBody", true)
				data.state = "findbody"
			else
				npc.Pathfinder:MoveRandomlyBoss(true)
			end
		else
				if player.Position:Distance(npc.Position) <= 50 then
					npc.Pathfinder:EvadeTarget(player.Position)
					npc.Velocity = npc.Velocity * 1.2
				else
					npc.Pathfinder:MoveRandomlyBoss(true)
						if rng:RandomInt(30) == rng:RandomInt(30) then
							sprite:Play("Head_Shoot_Big", true)
						else
						end
				end
			
			end
			
		end
		
		if sprite:IsPlaying("Head_Shoot_Big") then
			npc.Velocity = npc.Velocity * 0.08
			if sprite:IsEventTriggered("Shoot") then
				sound:Play(SoundEffect.SOUND_BOSS_SPIT_BLOB_BARF,1,0,false,1)
				mod.FireClusterProjectilesCad(npc, (player.Position - npc.Position):Resized(10), 10, data.clusterParams)
			end
		elseif sprite:IsFinished("Head_Shoot_Big") then
			data.noise = true
			data.last = npc.FrameCount
			sprite:Play("Idle", true)
		end
		
	
	elseif data.state == "findbody" then
		if sprite:IsPlaying("ApproachBody") then
			if data.Choose == 1 then
				--local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, CHUBS, -1, false, false)
				
					for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, CHUBS, -1, false, false)) do
						local entityData = entity:GetData()
						if entityData.state == "nohost" then
							body = entity
							
							break
						else
							data.Choose = 2
							
						end
					end
				
			
			elseif data.Choose == 2 then
				--local Bodycount2 = Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)
				
					for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)) do
						local entityData = entity:GetData()
						if entityData.state == "nohost" then
							body = entity
							break
						else
							data.Choose = 1
							
						end
					end
		
			end	
		if body.Position:Distance(npc.Position)<= 5 then
			if data.Choose == 1 then 
			data.Startefusionbody = body
			local Bodydata, bodysprite = data.Startefusionbody:GetData(), data.Startefusionbody:GetSprite()
				if bodysprite:IsPlaying("Chubs_Enter") then
					npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					Bodydata.state = "Activating"
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
					Bodydata.state = "Activating"
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
			data.velo = (body.Position - npc.Position):Resized(3)
			npc:AddVelocity(data.velo)
		elseif body.Position:Distance(npc.Position)<= 30 then
			npc.Velocity = (body.Position - npc.Position):Resized(6)
		else
			data.velo = (body.Position - npc.Position):Resized(1)
			npc:AddVelocity(data.velo)
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
		npc.CanShutDoors = true
		if data.damaged == false then
			npc.HitPoints = npc.HitPoints - (npc.HitPoints * 0.50)
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
				if data.Choose == 1 then
				data.Choose = 2
				else
				
				data.Choose = 1
				end
		data.last = npc.FrameCount
		sprite:Play("Idle", true)
		data.state = "Normal"
		end
	elseif data.state == "Abandon" then
		npc.CanShutDoors = true
		if data.Choose == 1 then
				data.Choose = 2
				
				else
				data.Choose = 1
				end
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

	local Head = Isaac.FindByType(EntityType.ENTITY_CADAVRA, CADAVRA_HEAD, -1, false, false)
	
	if not data.init then
		npc.CanShutDoors = false
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.state = "nohost"
		sprite:Play("Chubs_Body", true)
		data.init = true
		data.last = 0
		data.GridCountdown = 0
		data.direction = false
		npc.CollisionDamage = 0
		data.repeatjump = 0
		data.Attacked = 0
		data.Bounce = 4
	end
	
	local Flycount = Isaac.FindByType(18, 0, -1, false, false)
	if sprite:IsPlaying("Chubs_Body") then
		if #Head > 0 and #Flycount == 0 and data.last + 23 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then 
		sprite:Play("Chubs_Body_Shoot", true)
		end
	end
	if sprite:IsPlaying("Chubs_Body_Shoot") then
		if sprite:IsEventTriggered("Shoot") then
			for i = 1, 3 do
                    local maggot = Isaac.Spawn(18, 0, 0, npc.Position, Vector.FromAngle(math.random(0, 360)):Normalized() * (math.random(1, 2)), vessel):ToNPC()
                    maggot.V1 = Vector(-5, 5)
                    maggot.I1 = 1
                    --maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end
			
		end	
	elseif sprite:IsFinished("Chubs_Body_Shoot") then
			print("Finished animation")
			sprite:Play("Chubs_Body", true)
			data.last = npc.FrameCount
	end
	
	if data.Doactivate then
		npc.CanShutDoors = true
		data.Activated = true
		data.Attacked = 0
		sprite:Play("Chubs_Enter", true)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		data.last = 0
		data.bounce = 0
		data.Doactivate = false
		npc.CollisionDamage = 2
	end

	if data.Activated then
		if sprite:IsFinished("Chubs_Enter") then
			data.state = "Walk"
		end
	end
	local Bodycount2 = Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)
	if data.state == "Walk" then
		if player.Position:Distance(npc.Position) <= 10 then
			sprite:Play("Chubs_Idle", false)
			npc.Velocity = npc.Velocity * 0.08
		else
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
				data.bounce = 4
				data.Attacked = data.Attacked + 1
		elseif #Bodycount2 == 1 then
			if (data.Attacked > 0 and data.last + 23 < npc.FrameCount and rng:RandomInt(50) == rng:RandomInt(50)) or data.Attacked >= 5 then
				sprite:Play("Chubs_Abandon", true)
				npc.Velocity = Vector.Zero
				data.state = "Abandon"
			end
		end
	
	
	elseif data.state == "Attack1" then
		if sprite:IsPlaying("Chubs_Jump_Big") then
			sprite.FlipX = false
			if sprite:IsEventTriggered("Jump") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			npc.GridCollisionClass = GridCollisionClass.COLLISION_PIT
			npc.Velocity = ((player.Position + ((player.Velocity):Normalized() * 100))-npc.Position)*0.056
			sound:Play(SoundEffect.SOUND_BOSS_LITE_ROAR, 1, 0, false, 1)
			elseif sprite:IsEventTriggered("Shoot") then
				game:MakeShockwave(npc.Position, 0.045, 0.035, 10)
				game:ShakeScreen(30)
				sound:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
				npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				npc.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
				npc.Velocity = Vector.Zero
				for _ = 1,(rng:RandomInt(5)+7) do --cluster
					local params = ProjectileParams()
					params.Variant = 0
					params.FallingSpeedModifier = -(rng:RandomInt(27) + 8) * 0.4
					params.FallingAccelModifier = 0.3
					npc:FireProjectiles(npc.Position + Vector(rng:RandomInt(10) - 10,rng:RandomInt(10) - 10), Vector.FromAngle(angle+(rng:RandomInt(359)+1)):Resized((rng:RandomInt(3) + 4)), 0, params)
				end
				for i = 1, 6 do
					local direction = (i*(360/6)) + (rng:RandomInt(20) - 10)
					local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKWAVE, 2, npc.Position + Vector.FromAngle(direction) * 10, Vector.Zero, npc):ToEffect()
					wave.Parent = npc
					wave.Rotation = direction
				end
				for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)) do
				local entityData = entity:GetData()
				local nibssprite = entity:GetSprite()
					if entity:Exists() and (not nibssprite:IsPlaying("Nibs_Enter") and not nibssprite:IsPlaying("Nibs_Abandon") and not entityData.Activated ) then
						nibssprite:Play("Nibs_Body_Jump", true)
						break
					end
				end
				
				--local nibs = Isaac.FindByType(EntityType.ENTITY_CADAVRA, NIBS, -1, false, false)
				--nibs:GetSprite():Play("Nibs_Body_Jump", true)
			end
		elseif sprite:IsFinished("Chubs_Jump_Big") then
		data.state = "Walk"
		data.last = npc.FrameCount
		end
	
	elseif data.state == "Attack2" then
		sprite.FlipX = false
			if data.direction == false then
			
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
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
				npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				sound:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS, 1, 0, false, 1)
				game:MakeShockwave(npc.Position, 0.015, 0.050, 5)
				for _ = 1,(rng:RandomInt(2)+4) do --spread projectiles
					local params = ProjectileParams()
					params.Variant = 0
					params.FallingSpeedModifier = -(rng:RandomInt(27) + 8) * 0.4
					params.FallingAccelModifier = 0.3
					npc:FireProjectiles(npc.Position, Vector.FromAngle(angle+(rng:RandomInt(359)+1)):Resized((rng:RandomInt(8))), 0, params)
				end
				for i = 1,data.bounce do
					local vector = Vector(math.cos(i*math.pi/(data.bounce/2)),math.sin(i*math.pi/(data.bounce/2))):Resized(8)
					local params = ProjectileParams()
					params.FallingSpeedModifier = 1/(rng:RandomInt(27) + 8)
					npc:FireProjectiles(npc.Position, vector, 0, params)
				end
				npc.Velocity = Vector.Zero
			end
		elseif sprite:IsFinished("Chubs_JumpRight") or sprite:IsFinished("Chubs_JumpUp") or sprite:IsFinished("Chubs_JumpLeft") or sprite:IsFinished("Chubs_JumpDown") then
				if data.repeatjump <= 1 then
					data.repeatjump = data.repeatjump + 1
					data.direction = false
					data.bounce = data.bounce + 2
				else
					data.state = "Walk"
					data.last = npc.FrameCount
				end
		end
	elseif data.state == "Abandon" then
		sprite.FlipX = false
		if sprite:GetFrame() == 17 then
			local shotMin = 10
			local shotMax = 20
			local params = ProjectileParams()
			params.Variant = 0
			-- npc:FireBossProjectiles(shotMin+rng:Ra ndomInt(shotMax-shotMin + 1), player.Position, 0, params)
			data.Offset = (rng:RandomInt(90) - 90)
			for i = 1,3 do
				npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT,1,0,false,1)
				local vector = Vector(math.cos(i*math.pi/1.5),math.sin(i*math.pi/1.5)):Resized(10)
				local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, npc.Position, vector, npc):ToProjectile();
				data.tearColor2 = Color(1,1,1,1)
				data.tearColor2:SetColorize(1.5,2.2,0.8,1)

				tear:GetSprite().Color = data.tearColor2
					tear.Scale = 2
					tear.FallingSpeed = -16;
				tear.FallingAccel = 1;
				tear:GetData().cadBoom = true
				tear:GetData().cadBoomTears = true
				tear:GetData().cadGasLife = 325/2
			end
		elseif sprite:IsFinished("Chubs_Abandon") then
			local entityData = npc.Parent:GetData()
			entityData.state = "Abandon"
			entityData.damaged = false
			entityData.Choose = 1
			data.state = "nohost"
			npc.CollisionDamage = 0
			entityData.Pos1 = npc.Position
			sprite:Play("Chubs_Body", true)
			data.Activated = false
			npc.CanShutDoors = false
		end
	end 
	
	if npc:IsDead() then
		data.Offset = (rng:RandomInt(90) - 90)
		for i = 1,3 do
		npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT,1,0,false,1)
		local vector = Vector(math.cos(i*math.pi/1.5),math.sin(i*math.pi/1.5)):Resized(10)
		local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_MEAT, 0, npc.Position, vector, npc):ToProjectile();
		tear.FallingSpeed = -26;
		tear.FallingAccel = 2
		tear.ProjectileFlags = ProjectileFlags.ACCELERATE
	end
		if data.Activated == true then
			local entityData = npc.Parent:GetData()
			entityData.state = "Escape"
			entityData.Choose = 1
			entityData.damaged = false
			entityData.Pos1 = npc.Position
			npc.Parent:GetSprite():Play("BodyDestroyed", true)
		else
		end
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
	
	local Head = Isaac.FindByType(EntityType.ENTITY_CADAVRA, CADAVRA_HEAD, -1, false, false)
	
	data.clusterParams = ProjectileParams()
	data.clusterParams.FallingAccelModifier = -0.1
	data.ColorWigglyMaggot = Color(1,1,1,1,0,0,0)
	data.ColorWigglyMaggot:SetColorize(4,3,3,1)
	data.clusterParams.Color = data.ColorWigglyMaggot
	
	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.state = "nohost"
		data.last = npc.FrameCount
		sprite:Play("Nibs_Body", true)
		data.Startmovinge = 0
		npc.CollisionDamage = 0
		data.Cord = 0
		data.Attacked = 0
		data.init = true
	end
	if data.GridCountdown == nil then data.GridCountdown = 0 end
	
	local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, CHUBS, -1, false, false)
	local Wormcount = Isaac.FindByType(853, 0, -1, false, false)
	if sprite:IsPlaying("Nibs_Body") then
		data.nohit = 0
		if #Head > 0 and #Wormcount == 0 and data.last + 23 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then 
		sprite:Play("Nibs_Body_Shoot", true)
		end
	end
	if sprite:IsPlaying("Nibs_Body_Shoot") then
		if sprite:IsEventTriggered("Shoot") then
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT , 140, 0, npc.Position, Vector(0,0), npc):ToEffect()
			data.Maggots = 0
			for i = 1, 3 do
                    local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, npc.Position, Vector.FromAngle(math.random(0, 360)):Normalized() * (math.random(2, 3)), vessel):ToNPC()
                    maggot.V1 = Vector(-10, 10)
                    maggot.I1 = 1
                    maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    maggot.State = NpcState.STATE_SPECIAL
            end
		end
	elseif sprite:IsFinished("Nibs_Body_Shoot") then
			-- print("Finished animation")
			sprite:Play("Nibs_Body", true)
			data.last = npc.FrameCount
	end
	
	if sprite:IsPlaying("Nibs_Body_Jump") then
		if data.nohit == 0 then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		data.nohit = 1
		end
		if sprite:IsEventTriggered("Shoot") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		end
	elseif sprite:IsFinished("Nibs_Body_Jump") then
		sprite:Play("Nibs_Body", true)
		data.last = npc.FrameCount
	end
	
	if data.Doactivate then
		npc.CanShutDoors = true
		data.Activated = true
		data.Attacked = 0
		npc.CollisionDamage = 2
		sprite:Play("Nibs_Enter", true)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		data.Doactivate = false
	end

	if data.Activated then
		if sprite:IsFinished("Nibs_Enter") then
			data.state = "Walk"
		end
	end
	
	if data.state == "Walk" then
		if player.Position:Distance(npc.Position) <= 10 then
			sprite:Play("Nibs_Idle", false)
			npc.Velocity = npc.Velocity * 0.08
		else
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
		
		if data.last + 20 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				data.state = "Attack1"
				sprite:Play("Nibs_Shoot", true)
				npc.Velocity = Vector.Zero
				data.Attacked = data.Attacked + 1
		elseif data.last + 24 < npc.FrameCount and rng:RandomInt(30) == rng:RandomInt(30) then
				data.state = "Cord"
				data.Startmovinge = 0
				data.Attacked = data.Attacked + 1
				sprite:Play("Nibs_Cord", true)
				npc.Velocity = Vector.Zero
		elseif #Bodycount == 1 then
			if (data.Attacked > 0 and  data.last + 40 < npc.FrameCount and rng:RandomInt(50) == rng:RandomInt(50)) or data.Attacked >= 5 then
				sprite:Play("Nibs_Abandon", true)
				npc.Velocity = Vector.Zero
				data.state = "Abandon"
			end
		end
	end
		
		
		
	elseif data.state == "Attack1" then
	if sprite:IsPlaying("Nibs_Shoot") then
		--[[if sprite:IsEventTriggered("Shoot") then
		sound:Play(SoundEffect.SOUND_BOSS_SPIT_BLOB_BARF,1,0,false,1)
		mod.FireClusterProjectilesCad(npc, (player.Position - npc.Position):Resized(10), 10, data.clusterParams)
		end]]
		if sprite:IsEventTriggered("Shoot") then
		--local Spread = ProjectileParams()
		--Spread.FallingAccelModifier = -0.1
		--Spread.Scale = 1
				data.Amount = rng:RandomInt(2) + 3
				local offsetVector = rng:RandomInt(360)
				for i = 1,data.Amount do
					local vector = Vector.FromAngle((360 * i/data.Amount) + offsetVector):Resized(8)
				
					-- local vector = Vector(math.cos(math.pi*i/(data.Amount/2)),math.sin(math.pi*i/(data.Amount/2))):Resized(8)
					mod.FireClusterProjectilesCad(npc, vector, 3, data.clusterParams)
				end
		--[[if math.random(1,2) == 1 then
		Spread.BulletFlags = ProjectileFlags.CURVE_LEFT | ProjectileFlags.BACKSPLIT
		else
		Spread.BulletFlags = ProjectileFlags.CURVE_RIGHT | ProjectileFlags.BACKSPLIT
		end]]
		
		--npc:FireProjectiles(npc.Position, Vector(5,math.random(5,8)), 9, Spread)	
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
			cordEnd:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		end
	elseif sprite:IsFinished("Nibs_Cord") then
		sprite:Play("Nibs_CordLoop", true)
		end
	if sprite:IsPlaying("Nibs_CordLoop") then
		local cordEnd2
		if data.Startmovinge == 1 then
			for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, CORD, -1, false, false)) do
				local entityData = entity:GetData()
				if entity:Exists() then
					cordEnd2 = entity
					break
				end
			end
			if cordEnd2.Position:Distance(npc.Position) <= 20 or npc:CollidesWithGrid() then
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
				if npc.FrameCount % 2 == 0 then
					Isaac.Spawn(1000, 23, 0, npc.Position, Vector(0,0), npc)
				end
				
				if sprite:IsEventTriggered("Shoot") then
				sound:Play(SoundEffect.SOUND_BLOODSHOOT, 0.6, 0, false, math.random(9,11)/10)
				local veloc = npc.Velocity
				data.tearColor2 = Color(1,1,1,1)
				data.tearColor2:SetColorize(1.5,2.2,0.8,1)
				local params = ProjectileParams()
				-- params.BulletFlags = ProjectileFlags.ACCELERATE
				params.Variant = 0
				-- params.Spread = 6
				params.Color = data.tearColor2
				--params.Acceleration = 1+1/24
				npc:FireProjectiles(npc.Position, Vector(veloc:Resized(6):Length(), 5), 9, params)
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
		if sprite:IsPlaying("Nibs_Abandon") then
			if sprite:GetFrame() % 3 == 0 and sprite:GetFrame() < 30 then
				local angle = math.random(1,360);
				local mag = math.random(5,10);
				local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, npc.Position, (player.Position-npc.Position):Resized(math.random(5,7)):Rotated(math.random(-360,360)), nil):ToProjectile()
				projectile.ProjectileFlags = ProjectileFlags.DECELERATE
				projectile.FallingSpeed = 1
				projectile.FallingAccel = -0.1
				projectile.ChangeTimeout = 270
				sound:Play(SoundEffect.SOUND_BOSS2_BUBBLES,1,0,false,1)
			end

			if sprite:GetFrame() == 31 then
				local entityData = npc.Parent:GetData()
				entityData.state = "Abandon"
				entityData.damaged = false
				entityData.Choose = 2
				data.state = "nohost"
				entityData.Pos1 = npc.Position
				sprite:Play("Nibs_Body", true)
				npc.CollisionDamage = 0
				data.Activated = false
				npc.CanShutDoors = false
			end
		end
	end
	
	
	
	if npc:IsDead() then
		if data.Activated == true then
			local entityData = npc.Parent:GetData()
			entityData.state = "Escape"
			entityData.Choose = 2
			entityData.Pos1 = npc.Position
			npc.Parent:GetSprite():Play("BodyDestroyed", true)
			for i, entity2 in pairs(Isaac.GetRoomEntities()) do
				if entity2.Type == EntityType.ENTITY_EVIS or (entity2.Type == EntityType.ENTITY_EVIS and entity2.Variant == CORD) then
					entity2:Remove()
				end
			end
		else
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavrasNibsBodyAI, EntityType.ENTITY_CADAVRA)

function mod:CadavrasNibsCordAI(npc)
	if npc.Variant ~= CORD then
		return
	end
	npc.Visible = false
	npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
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
		mod:QuickCordCad(npc, npc.Parent)
		data.Cord = 1
		npc.Velocity = (player.Position - npc.Position):Resized(19)
		data.moving = 1
	end
	npc.SpriteRotation = npc.Velocity:GetAngleDegrees()
	
	
	if data.moving == 0 then
		npc.Velocity = Vector.Zero
	end
	
	
	
	if npc:CollidesWithGrid() then
		npc.Velocity = Vector.Zero
		data.moving = 0
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
			Offset = Vector(0, -13),
			Rooms = StageAPI.RoomsList("Cadavra Rooms", require("resources.luarooms.boss_cadavra")),
			Entity = {Type = EntityType.ENTITY_CADAVRA, Variant = CADAVRA_HEAD},
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

