





local GONE_DISTANCE_CONSTANT = 2000;

--State machine shit

--Constants for states
local LANE = 1; -- Laning involves staying in mid and last hitting creeps, this happens when the creeps are not near the ally tower or under the enemy tower
local PUSH = 2; -- Pushing involves attacking the enemy tower, this happens when there are ally creeps under the enemy tower who are attacking the tower
local DEFEND = 3; -- Defending involves attacking anything that is attacking the ally tower, this happens when enemy creeps or heroes are attacking the ally tower
local ATTACK = 4; -- Attacking involves hitting and chasing an enemy hero, this happens when the enemy hero's health is low
local RETREAT = 5; -- Retreating involves running back to base (or shrine?) to heal, this happens when the hero's health is low

-- Holds the initial state
local initialState = LANE;

-- Holds the current state
local currentState = initialState;

local SKILL_1 = 'nevermore_shadowraze1';
local SKILL_1_1 = 'nevermore_shadowraze2';
local SKILL_1_2 = 'nevermore_shadowraze3';
local SKILL_2 = 'nevermore_necromastery';
local SKILL_3 = 'nevermore_dark_lord';
local SKILL_ULTI = 'nevermore_requiem';

local SKILL_BUILD = {
    SKILL_2, -- 1
    SKILL_1, -- 2
    SKILL_2, -- 3
    SKILL_1, -- 4
    SKILL_2, -- 5
    SKILL_1, -- 6
    SKILL_2, -- 7
    SKILL_1, -- 8
    SKILL_3, -- 9
    SKILL_3, -- 10
    SKILL_ULTI, -- 11
    SKILL_ULTI, -- 12
    SKILL_3, -- 13
    -- 'special_bonus_spell_amplify_6', -- 15
    --SKILL_3, -- 16
    --SKILL_ULTI, -- 18
    -- 'special_bonus_unique_nevermore_1', -- 20
    -- 'special_bonus_attack_range_150', -- 25
}

local TOTAL_SKILL_LEVEL = 0

function LevelUp()
    local bot = GetBot();

	--print("Things left to skill " .. #SKILL_BUILD);
    if(#SKILL_BUILD == 0) then
        return
    end

    local skill = bot:GetAbilityByName(SKILL_BUILD[1])
    local skill_level = skill:GetLevel()

    if(skill:CanAbilityBeUpgraded() and (bot:GetAbilityPoints() > 0)) then
        bot:ActionImmediate_LevelAbility(SKILL_BUILD[1])
        local skill_level_after_upgrade = skill:GetLevel()

        if(skill_level_after_upgrade > skill_level) then
            table.remove(SKILL_BUILD, 1);
        end
    end
end

-- Check and apply transitions, updating currentState
function updateState()

	if (currentState == LANE) then
		laneUpdateState();
	elseif (currentState == PUSH) then
		pushUpdateState();
	elseif (currentState == DEFEND) then
		defendUpdateState();
	elseif (currentState == ATTACK) then
		attackUpdateState();
	elseif (currentState == RETREAT) then
		retreatUpdateState();
	else
		error("Unexpected state value");
		currentState = LANE;
	end;

end


function Think()
	local bot = GetBot();
	
	LevelUp();

	updateState();

	
	if (currentState == LANE) then
		laneThink();
	elseif(currentState == PUSH) then
		pushThink();
	elseif(currentState == DEFEND) then
		defendThink();
	elseif(currentState == ATTACK) then
		attackThink();
	elseif(currentState == RETREAT) then
		retreatThink();
	end
	
	
	
	local botTeamName = "Glitch";
	if (bot:GetTeam() == 2) then
		botTeamName = "Radi";
	elseif (bot:GetTeam() == 3) then
		botTeamName = "Dire"
	end;
	
	local botStateName = "Glitch";
	if (currentState == 1) then
		botStateName = "LANE";
	elseif (currentState == 2) then
		botStateName = "PUSH"
	elseif (currentState == 3) then
		botStateName = "DEFEND"
	elseif (currentState == 4) then
		botStateName = "ATTACK"
	elseif (currentState == 5) then
		botStateName = "RETREAT"
	end;
	
	
	
	--This is for making bugfixing much better 
	--[[
	if ( GameTime()%10 < 0.05) then
		print(botTeamName .. " bot state  is " .. botStateName);
	end;
		--]]
	--[[
	if (bot:GetStashValue() > 10) then
		print("Things in my booty!");
		local myCourier = GetCourier(bot:GetTeam()-2);
		bot:ActionImmediate_Courier(myCourier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS);
	-; --]]
	
end

-- State Machine Funtions
-- Lane
function laneUpdateState()
	local bot = GetBot();
	local enemyBot = getEnemyBot();
	
	local tower;
	local creepsLoc;
	if (bot:GetTeam() == 2) then
		--print("A");
		tower = GetTower(TEAM_RADIANT,TOWER_MID_1)
		creepsLoc = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 0);
	end
	if (bot:GetTeam() == 3) then
		--print("B");
		tower = GetTower(TEAM_DIRE,TOWER_MID_1);
		creepsLoc = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 0);
	end

	local creepsUnderTower = false;
	if (GetUnitToLocationDistance(tower, creepsLoc) < 900) then
		creepsUnderTower = true;
	end;
	
	local botTeamName = "Glitch";
	if (bot:GetTeam() == 2) then
		botTeamName = "Radi";
	elseif (bot:GetTeam() == 3) then
		botTeamName = "Dire"
	end;
	
	if (shouldRetreat()) then
		currentState = RETREAT;
		print(botTeamName .. " changing state from LANE TO RETREAT")
	elseif (enemyGone() and (DotaTime() > 0)) then
		currentState = PUSH;
		print(botTeamName .. " changing state from LANE TO PUSH")
	elseif (creepsUnderTower) then
	   currentState = DEFEND;
	   print(botTeamName .. " changing state from LANE to DEFEND");
	elseif ((enemyBot:GetHealth()/enemyBot:GetMaxHealth() - bot:GetHealth()/bot:GetMaxHealth() > .3) or (bot:GetHealth() - enemyBot:GetHealth() > 400)) then
		currentState = ATTACK;
		print(botTeamName .. " changing state from LANE to ATTACK");
	end
end
function laneThink()
	--comment
	--print("Laning");
	local bot = GetBot();
	local enemyBot = getEnemyBot();
	local enemyList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local listLength = table.getn(enemyList);
	
	local target;
	local targetMeet;
	if (bot:GetTeam() == 2) then
		target = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, -300);
		targetMeet = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 50);
	end
	if (bot:GetTeam() == 3) then
		target = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, -300);
		targetMeet = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 50);
	end
	
	local attackableCreeps = bot:GetNearbyLaneCreeps(800, true);
	local denyableCreeps = bot:GetNearbyLaneCreeps(800, false);
	
	local enemyCreeps = bot:GetNearbyLaneCreeps(1000, true);
	local enemyHeroesToRaze = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
	
	for i=1,#denyableCreeps do
        attackableCreeps[#attackableCreeps+1] = denyableCreeps[i]
    end
	
	for i=1,#enemyHeroesToRaze do
        enemyCreeps[#enemyCreeps+1] = enemyHeroesToRaze[i]
    end

	local myDamage = bot:GetAttackDamage();
	
	local hitsAvailable = false;
	
	local earlyHitConstant = 8;
	
	local outOfAggroRange = true;
	
	
	--Checks if There are creeps that can be last hit.
	if (table.getn(attackableCreeps) > 0) then
		for i = 1, table.getn(attackableCreeps) do
			local creep = attackableCreeps[i];
			local creepHP = creep:GetHealth();
			local creepEHP = creepHP;
			if (creep:WasRecentlyDamagedByCreep(5)) then
				if (creep:TimeSinceDamagedByCreep() > .6 and creep:TimeSinceDamagedByCreep() < 1) then
					--print("e");
					creepEHP = creepEHP - 17;
				end
			end
			
			local rangedCreepBonus = 0;
			
			if (creep:GetAttackRange() > 200) then
				rangedCreepBonus = 40;
			end;
			
			if (myDamage + earlyHitConstant + rangedCreepBonus > creepEHP) then
				hitsAvailable = true;
			end
			
		end
	end
	
	local raze1 = 0;
	local raze2 = 0;
	local raze3 = 0;
	
	local razeDamage = (bot:GetAbilityByName("nevermore_shadowraze1")):GetAbilityDamage()
	print("I think my raze damage is " .. razeDamage);
	
	--Checks num of creeps that can be razed by
	if (table.getn(enemyCreeps) > 0) then
		for i = 1, table.getn(enemyCreeps) do
			local creep = enemyCreeps[i];
			local creepHP = creep:GetHealth();
			local creepEHP = creepHP;
			if (creep:WasRecentlyDamagedByCreep(5)) then
				if (creep:TimeSinceDamagedByCreep() > .6 and creep:TimeSinceDamagedByCreep() < 1) then
					--print("e");
					creepEHP = creepEHP - 17;
				end
			end
			if ((razeDamage + earlyHitConstant> creepEHP) or (creep:IsHero())) then
				if (GetUnitToUnitDistance(bot, creep) < 450) then
					raze1 = raze1 + 1;
				end
				if ((GetUnitToUnitDistance(bot, creep) > 200) and (GetUnitToUnitDistance(bot, creep) < 700)) then
					raze2 = raze2 + 1;
				end
				if ((GetUnitToUnitDistance(bot, creep) > 450) and (GetUnitToUnitDistance(bot, creep) < 950)) then
					raze3 = raze3 + 1;
				end
			end
			
		end
	end
	
	
	local enemyCreeps = bot:GetNearbyLaneCreeps(500, true);
	if (table.getn(enemyCreeps) > 0) then
		outOfAggroRange = false;
	end
	local botTeamName = "Glitch";
	if (bot:GetTeam() == 2) then
		botTeamName = "Radi";
	elseif (bot:GetTeam() == 3) then
		botTeamName = "Dire"
	end;
	
	local MIN_CREEP_TO_RAZE = 2;
	
	print("isfacing is " .. tostring(bot:IsFacingLocation(targetMeet,20)));
	print("razes are " .. tostring(raze1) .. " " .. tostring(raze2) .. " " .. tostring(raze3));
	if (bot:IsFacingLocation(targetMeet, 20) and (raze1>=MIN_CREEP_TO_RAZE or raze2>=MIN_CREEP_TO_RAZE or raze3>=MIN_CREEP_TO_RAZE) and (bot:GetMana()/bot:GetMaxMana() > .3)) then
		if (raze1>=MIN_CREEP_TO_RAZE) then
			shortRazeSkill = bot:GetAbilityByName("nevermore_shadowraze1");
			bot:Action_UseAbility(shortRazeSkill);
			print("Razing short");
		elseif (raze2>=MIN_CREEP_TO_RAZE) then 
			mediumRazeSkill = bot:GetAbilityByName("nevermore_shadowraze2");
			bot:Action_UseAbility(mediumRazeSkill);
			print("Razing med");
		elseif (raze3>=MIN_CREEP_TO_RAZE) then 
			longRazeSkill = bot:GetAbilityByName("nevermore_shadowraze3");
			bot:Action_UseAbility(longRazeSkill);
			print("Razing long");
		end;
	--If there are creeps to last hit, hit them
	elseif (hitsAvailable) then
		for i = 1, table.getn(attackableCreeps) do
			local creep = attackableCreeps[i];
			local creepHP = creep:GetHealth();
			local creepEHP = creepHP;
			if (creep:WasRecentlyDamagedByCreep(5)) then
				if (creep:TimeSinceDamagedByCreep() > .6 and creep:TimeSinceDamagedByCreep() < 1) then
					creepEHP = creepEHP - 17; --17 is aprox dmg of a creep melee
				end
			end
			
			local rangedCreepBonus = 0;
			
			if (creep:GetAttackRange() > 200) then
				rangedCreepBonus = 40;
			end;
			
			if (myDamage + earlyHitConstant + rangedCreepBonus > creepEHP) then
				bot:Action_AttackUnit(attackableCreeps[i], true);
				break;
			end
		end
	elseif(outOfAggroRange) then
		bot:Action_AttackUnit(enemyBot, true);
	else  -- Othwerwise, be a bit behind the creep wave
		bot:Action_MoveToLocation(target);
	end
end

-- Push
function pushUpdateState()
	local bot = GetBot();
	local enemyBot = getEnemyBot();
	local enemyList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local listLength = table.getn(enemyList);

	local botTeamName = "Glitch";
	if (bot:GetTeam() == 2) then
		botTeamName = "Radi";
	elseif (bot:GetTeam() == 3) then
		botTeamName = "Dire"
	end;

	if (shouldRetreat()) then
		currentState = RETREAT;
		print(botTeamName .. " changing state from PUSH TO RETREAT")
	elseif (not enemyGone()) then
		currentState = LANE;
		print(botTeamName .. " changing state from PUSH TO LANE")
	end
end
function pushThink()
	local bot = GetBot();
	local enemyBot= getEnemyBot();
	local enemyList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local listLength = table.getn(enemyList);
	
	local target;
	if (bot:GetTeam() == 2) then
		target = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, -200);
	end
	if (bot:GetTeam() == 3) then
		target = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, -200);
	end
	
	local attackableCreeps = bot:GetNearbyLaneCreeps(500, true);
	
	local nearbyCreeps = bot:GetNearbyLaneCreeps(700, true);
	
	local tower;
	if (bot:GetTeam() == 3) then
		tower = GetTower(TEAM_RADIANT,TOWER_MID_1)
	end
	if (bot:GetTeam() == 2) then
		tower = GetTower(TEAM_DIRE,TOWER_MID_1);
	end
	
	
	
	--Later, maybe make this prioritize low creeps, so it can get lh while pushing
	if (table.getn(attackableCreeps) > 0) then
		bot:Action_AttackUnit(attackableCreeps[1], true);
	elseif(#nearbyCreeps < 1 and (GetUnitToUnitDistance(bot, tower) < 500)) then
		bot:Action_AttackUnit(tower, false)
	else 
		bot:Action_MoveToLocation(target);
	end
	
end

-- Defend
function defendUpdateState()
	local bot = GetBot();
	local targetTower;
	local creepsLocation;

	-- get the allied tower and the location for creeps
	if (bot:GetTeam() == 3) then -- bot is Dire
		targetTower = GetTower(TEAM_DIRE, TOWER_MID_1);
		creepsLocation = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 0);
	elseif (bot:GetTeam() == 2) then -- bot is Radiant
		targetTower = GetTower(TEAM_RADIANT, TOWER_MID_1);
		creepsLocation = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 0);
	end
	
	-- are creeps under allied tower
	local creepsUnderTower = false;
	if (GetUnitToLocationDistance(targetTower, creepsLocation) < 900) then
		creepsUnderTower = true;
	end
	
	local botTeamName = "Glitch";
	if (bot:GetTeam() == 2) then
		botTeamName = "Radi";
	elseif (bot:GetTeam() == 3) then
		botTeamName = "Dire"
	end;

	-- if deaths > 0 and health < 50% and tower health > 30% --> retreat 
	if ((GetHeroDeaths(bot:GetPlayerID()) > 0) and (bot:GetHealth() < (bot:GetMaxHealth()/100)*50) and (targetTower:GetHealth() > (targetTower:GetMaxHealth()/100)*30)) then
		print(botTeamName .. " changing state from DEFEND to RETREAT");
		currentState = RETREAT;
	elseif (not creepsUnderTower) then -- if there are no enemies under tower --> lane
		print(botTeamName .. " changing state from DEFEND to LANE");
		currentState = LANE;
	end
end

function defendThink()

	--print("Defending");
	local bot = GetBot();
	
	
	local target;
	if (bot:GetTeam() == 2) then
		target = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, -200);
	end
	if (bot:GetTeam() == 3) then
		target = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, -200);
	end
	
	local friendlyCreeps = bot:GetNearbyLaneCreeps(700, false);
	local attackableCreeps = bot:GetNearbyLaneCreeps(500, true);
	
	--Later, maybe make this prioritize low creeps, so it can get lh while pushing
	if (table.getn(friendlyCreeps) > 0) then
		--print("See attackable creep");
		if (table.getn(attackableCreeps) > 0) then
			bot:Action_AttackUnit(attackableCreeps[1], true);
		else
			bot:Action_MoveToLocation(target);
		end
	else 
		bot:Action_MoveToLocation(target);
	end
	
	--[[
	-- where bot needs to go
	local target;
	

	-- determine where mid tower is 
	if (bot:GetPlayerID() == 9) then -- bot is Dire
		target = GetLocationAlongLane(LANE_MID, 0.51);
	elseif (bot:GetTeam() == 2) then -- bot is Radiant
		target = GetLocationAlongLane(LANE_MID, 0.45);
	end
	
	-- attack anything that is near the tower
	bot:Action_AttackMove(target); --]]

end

-- Attack
function attackUpdateState()
   local bot = GetBot();

   local botTeamName = "Glitch";
	if (bot:GetTeam() == 2) then
		botTeamName = "Radi";
	elseif (bot:GetTeam() == 3) then
		botTeamName = "Dire"
	end;

   if(bot:GetHealth()/bot:GetMaxHealth() < .2) then  -- or tookToMuchDamange() (way too much)
      -- print("Attack -> Retreat: Health to low")
	  print(botTeamName .. " changing state from ATTACK to RETREAT")
      currentState = RETREAT;
   elseif((bot:GetHealth() < 500
	      and GetUnitToUnitDistance(bot, GetTower(getEnemyTeam(), TOWER_MID_1)) < 1050)
	 or enemyGone()
   ) then
      --  or tookToMuchDamange
      -- print("Attack -> Lane: Tower to dangerous")
	  print(botTeamName .. " changing state from ATTACK to LANE")
      currentState = LANE;
   end
end

function attackThink()
   -- Get current bot and enemy bot
   local bot = GetBot();
   local enemyBot = getEnemyBot();

   -- Temp to keep it alive
   bot:Action_AttackUnit(enemyBot, false);

end

-- Retreat
function retreatUpdateState()

	local bot = GetBot();
	local targetTower; 
	
	if(bot:GetTeam() == 3) then
		targetTower = GetTower(TEAM_DIRE, TOWER_MID_1);
	elseif(bot:GetTeam() == 2) then 
		targetTower = GetTower(TEAM_RADIANT, TOWER_MID_1);
	end

	local botTeamName = "Glitch";
	if (bot:GetTeam() == 2) then
		botTeamName = "Radi";
	elseif (bot:GetTeam() == 3) then
		botTeamName = "Dire"
	end;

	-- Move to Lane State if health becomes larger than certain value
	if ((not shouldRetreat()) and bot:GetHealth()/bot:GetMaxHealth() > 0.6) then 
		print(botTeamName .. " changing state from RETREAT to LANE")
		currentState = LANE; 
	end 
	
	-- Defend the tower if the it is low health and you can afford to risk your life
	--if (targetTower:GetHealth()/targetTower:GetMaxHealth() <= 0.2) and (bot:GetHealth()/bot:GetMaxHealth() >= 0.75 or GetHeroDeaths(bot:GetPlayerID()) < 1) then 
		--currentState = DEFEND;
	--end
end
function retreatThink()
	--print("Retreating");
	local bot = GetBot();
	local enemyBot = getEnemyBot();
	
	-- where bot needs to go
	local target;
	
	-- determine where base is 
	target = GetLocationAlongLane(LANE_MID, .05);
	
	local salveSlot = bot:FindItemSlot("item_flask");
	--print(salveSlot);
	
	local salve = bot:GetItemInSlot(salveSlot)
	--print(salve);
	
	
	if ((salveSlot > -1) and (GetUnitToUnitDistance(bot, enemyBot) > 1500) and (bot:GetMaxHealth() - bot:GetHealth() > 400)) then
		bot:Action_UseAbilityOnEntity(salve, bot);
		print("Salving");
	else
		-- move to base
		bot:Action_MoveToLocation(target);
	end;

end

-- Other Helper functions
function getEnemyTeam()
   local myTeam = GetTeam();
   local enemyTeam;
   if(myTeam == TEAM_RADIANT) then
      enemyTeam = TEAM_DIRE;
   else
      enemyTeam = TEAM_RADIANT;
   end
   return enemyTeam;
end

function getEnemyBot()
   local enemyBot;
   -- get enemy hero list and loop through looking for the nevermore bots
   local enemyList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
   local listLength = table.getn(enemyList);
   --print("Number of enemies: " .. listLength);
   for i = 1, listLength do
		--print(GetSelectedHeroName(enemyList[i]:GetPlayerID()));
		if (GetSelectedHeroName(enemyList[i]:GetPlayerID()) == "npc_dota_hero_nevermore") then
			enemyBot = enemyList[i];
		end
   end
   return enemyBot
end

-- Function to determine if the enemy is "gone" (gone is subjective)
function enemyGone()
   local bot = GetBot()
   enemyBot = getEnemyBot()
   
   	local target;
	if (bot:GetPlayerID() == 4) then
		target = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, -200);
	end
	if (bot:GetPlayerID() == 9) then
		target = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, -200);
	end
   
   return (enemyBot == nil or GetUnitToLocationDistance(enemyBot, target) > GONE_DISTANCE_CONSTANT)
end

-- Function to decide if the bot should retreat
function shouldRetreat()
   local bot = GetBot()
   return (
      bot:GetHealth()/bot:GetMaxHealth() < .2
	 or bot:WasRecentlyDamagedByCreep(1)
	 or bot:WasRecentlyDamagedByTower(2)
      -- or tookToMuchDamange
   )
end
----------------------------------------------------------------------------------------------------

