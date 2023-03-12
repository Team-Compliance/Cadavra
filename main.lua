local mod = RegisterMod("Cadavra", 1)
local game = Game()
local sound = SFXManager()
local rng = RNG()


local function Lerp(v1, v2, t)
	return (v1 + (v2 - v1)*t)
end
 
function mod:CadavraAI(npc)
    if npc.Variant ~= 0 then
		return
	end
    local room = game:GetRoom()
	local data = npc:GetData()
	
	local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget()
    local dir = player.Position - npc.Position
	local angle = npc.Velocity:GetAngleDegrees()
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
			if data.last + 15 < npc.FrameCount and math.random(30) == math.random(30) then
				sprite:Play("Head_Shoot", true)
			elseif data.last + 20 < npc.FrameCount and math.random(30) == math.random(30) then
				sprite:Play("Head_Shoot_Big", true)
			end
		end
		if sprite:IsPlaying("Head_Shoot") then
		npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Resized(1.25)
			 
		end
		
		if sprite:IsPlaying("Head_Shoot_Big") then
		npc.Velocity = npc.Velocity * 0.05 + (player.Position - npc.Position):Resized(1.25)
			if sprite:IsEventTriggered("Shoot") then
		        npc:PlaySound(SoundEffect.SOUND_MEATHEADSHOOT,1,0,false,1)
			    npc:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_0,1,0,false,1)
			    local vector = (player.Position-npc.Position)*0.1
			    local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, npc.Position, vector, npc):ToProjectile();
			    data.tearColor2 = Color(1,1,1,1)
				data.tearColor2:SetColorize(1.5,2.2,0.8,1)
				
				tear:GetSprite().Color = data.tearColor2
    			tear.Scale = 2
			    tear.FallingSpeed = -25;
			    tear.FallingAccel = 4;
			    tear:GetData().cadBoom = true
			    tear:GetData().cadBoomTears = true
			    tear:GetData().cadGasLife = 325/2
			end
		
		end
		
		if sprite:IsPlaying("Idle") and ((data.Phase == 1 and npc.HitPoints < npc.MaxHitPoints * .60) or (data.Phase == 2 and npc.HitPoints < npc.MaxHitPoints * .30)) then
			sprite:Play("idletonewbody", true)
			
		else
			if sprite:IsFinished("idletonewbody") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			data.Choose = math.random(1,2)
			print(data.Choose)
			data.last = npc.FrameCount
			sprite:Play("ApproachBody", true)
			data.state = "findbody"
			 --math.random(1,2)
			end
		end
	
	elseif data.state == "findbody" then
		if sprite:IsPlaying("ApproachBody") then
			if data.Choose == 1 then
				local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, 21, -1, false, false)
				if #Bodycount > 0 then
					for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, 21, -1, false, false)) do
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
				local Bodycount2 = Isaac.FindByType(EntityType.ENTITY_CADAVRA, 50, -1, false, false)
				if #Bodycount2 > 0 then
					for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, 50, -1, false, false)) do
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
				for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, 50, -1, false, false)) do
					local Bodycount = Isaac.FindByType(EntityType.ENTITY_CADAVRA, 50, -1, false, false)
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
					data.state = "Inside man"
					return
				else
					Bodydata.Doactivate = true
				end
			elseif data.Choose == 2 then
				data.Startefusionbody = body
			local Bodydata, bodysprite = data.Startefusionbody:GetData(), data.Startefusionbody:GetSprite()
				if bodysprite:IsPlaying("Nibs_Enter") then
					data.last = npc.FrameCount
					npc.Velocity = Vector.Zero
					sprite:Play("Idle", true)
					data.state = "Inside man"
					return
				else
					Bodydata.Doactivate = true
				end
			end
		else
			data.velo = (body.Position - npc.Position):Resized(3)
			npc.Velocity = Lerp(npc.Velocity, data.velo, 0.45)
		end
		
		end
	
	
	elseif data.state == "Inside man" then
		data.Choose = 0 
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		if sprite:IsPlaying("Idle") then
		data.last = npc.FrameCount
		npc.Visible = false
		end
		
	elseif data.state == "Escape" then
		npc.Velocity = RandomVector()*1
		npc.Position = data.Pos1
		if sprite:IsPlaying("outofbody") then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		npc.Visible = true
		elseif sprite:IsFinished("outofbody") then
		data.Phase = data.Phase + 1
		data.last = npc.FrameCount
		sprite:Play("Idle", true)
		data.state = "Normal"
		end
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavraAI, EntityType.ENTITY_CADAVRA)


function mod:CadavrasChubbyBodyAI(npc)
	if npc.Variant ~= 21 then
		return
	end
	local room = game:GetRoom()
	local data = npc:GetData()
	local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget()
	
	
	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.state = "nohost"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.HitPoints = 5
		sprite:Play("chubbody", true)
		data.init = true
		data.GridCountdown = 0
	end
	
	if data.Doactivate then
		data.Activated = true
		
		sprite:Play("Chubs_Enter", true)
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		
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
	
	end
	
	
	if npc:IsDead() then
		for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, 0, -1, false, false)) do
			local entityData = entity:GetData()
			entityData.state = "Escape"
			entityData.Pos1 = npc.Position
			entity:GetSprite():Play("outofbody", true)
		end
	end
end


mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavrasChubbyBodyAI, EntityType.ENTITY_CADAVRA)

function mod:CadavrasNibbyBodyAI(npc)
	if npc.Variant ~= 50 then
		return
	end
	local room = game:GetRoom()
	local data = npc:GetData()
	local sprite = npc:GetSprite()
    local player = npc:GetPlayerTarget()
	
	
	if not data.init then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		data.state = "nohost"
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.HitPoints = 5
		data.last = npc.FrameCount
		sprite:Play("nibsbody", true)
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
		
		if data.last + 15 < npc.FrameCount and math.random(30) == math.random(30) then
				data.state = "Attack1"
				sprite:Play("NibsShoot", true)
				npc.Velocity = Vector.Zero
				
		end
		
		
	elseif data.state == "Attack1" then
	if sprite:IsPlaying("NibsShoot") then
	elseif sprite:IsFinished("NibsShoot") then
		data.state = "Walk"
		data.last = npc.FrameCount
	end 
	
	end
	
	if npc:IsDead() then
		for i,entity in ipairs(Isaac.FindByType(EntityType.ENTITY_CADAVRA, 0, -1, false, false)) do
			local entityData = entity:GetData()
			entityData.state = "Escape"
			entityData.Pos1 = npc.Position
			entity:GetSprite():Play("outofbody", true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.CadavrasNibbyBodyAI, EntityType.ENTITY_CADAVRA)

function mod:Cadavrasboom(tear,collided)
    local d = tear:GetData()
	local rng = tear:GetDropRNG()
		if d.pestBoomTarget then
			if not d.target then
				d.target = Isaac.Spawn(1000, EffectVariant.TARGET, 0, tear.Position,Vector.Zero, tear):ToEffect()
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
			tearSpin = math.random(0,360)
		    
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