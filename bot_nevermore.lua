

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
	updateState();
	--print("Applying state " .. currentState);	
	--currentState = DEFEND;
	
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
	
	-- Attempting to make enemy bot be normal Dota bot
	--[[if (bot:GetPlayerID() == 9) then
		nevermoreBot:Think(bot);
		do return end
	end

	print("Dota bot Nevermore at time: " .. DotaTime());
	print("Game time (Nevermore): " .. GameTime());
	print("Game State: " .. GetGameState());
	print("Game Mode: " .. GetGameMode());
	
	-- Getting current bot and the enemy bot
	local bot = GetBot();
	local enemyBot;
	
	print("My current level is " .. GetHeroLevel(bot:GetPlayerID()));
	
	-- get enemy hero list and loop through looking for the nevermore bots 
	local enemyList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local listLength = table.getn(enemyList);
	--print("Number of enemies: " .. listLength);
	for i = 1, listLength do
		print("Enemy " .. i .. " is " .. enemyList[i]:GetPlayerID());
		if (enemyList[i]:GetPlayerID() == 4 or enemyList[i]:GetPlayerID() == 9) then
			enemyBot = enemyList[i];
		end
	end
	
	--print("Enemy bot of " .. bot:GetPlayerID() .. " is " .. enemyBot:GetPlayerID());
	
	-- move to the center of mid and attack any enemy in range
	local target = GetLocationAlongLane(LANE_MID, 0.52);
    --bot:Action_MoveToLocation(target);
	bot:Action_AttackMove(target);
	
    --nevermoreBot:Think(bot)--]]
	
end

-- State Machine Funtions
-- Lane
function laneUpdateState()
	local bot = GetBot();
	local enemyBot;
	local enemyList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local listLength = table.getn(enemyList);
	for i = 1, listLength do
		--print("Enemy " .. i .. " is " .. enemyList[i]:GetPlayerID());
		if (enemyList[i]:GetPlayerID() == 4 or enemyList[i]:GetPlayerID() == 9) then
			enemyBot = enemyList[i];
		end
	end
	
	local tower;
	local creepsLoc;
	if (bot:GetPlayerID() == 4) then
		--print("A");
		tower = GetTower(TEAM_RADIANT,TOWER_MID_1)
		creepsLoc = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 0);
	end
	if (bot:GetPlayerID() == 9) then
		--print("B");
		tower = GetTower(TEAM_DIRE,TOWER_MID_1);
		creepsLoc = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 0);
	end

	local creepsUnderTower = false;
	if (GetUnitToLocationDistance(tower, creepsLoc) < 900) then
		creepsUnderTower = true;
	end;
	
	if (bot:GetHealth() < 400) then
		currentState = RETREAT;
		print("Changing state from LANE TO RETREAT")
	elseif (enemyGone()) then
		currentState = PUSH;
		print("Changing state from LANE TO PUSH")
	elseif (creepsUnderTower) then
		currentState = DEFEND;
		print("Changing state from LANE to DEFEND");
	elseif (enemyBot:GetHealth() < 500) then
		currentState = ATTACK;
		print("Changing state from LANE to ATTACK");
	end
end
function laneThink()

	--print("Laning");
	local bot = GetBot();
	local enemyBot = getEnemyBot();
	local enemyList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local listLength = table.getn(enemyList);
	
	local target;
	if (bot:GetPlayerID() == 4) then
		target = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, -300);
	end
	if (bot:GetPlayerID() == 9) then
		target = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, -300);
	end
	
	local attackableCreeps = bot:GetNearbyLaneCreeps(800, true);
	local denyableCreeps = bot:GetNearbyLaneCreeps(800, false);
	
	
	for i=1,#denyableCreeps do
        attackableCreeps[#attackableCreeps+1] = denyableCreeps[i]
    end

	local myDamage = bot:GetAttackDamage();
	
	local hitsAvailable = false;
	
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

			if (myDamage > creepEHP) then
				hitsAvailable = true;
			end
		end
	end
	
	--If there are creeps to last hit, hit them
	if (hitsAvailable) then
		print("Last-hitting a creep");
		for i = 1, table.getn(attackableCreeps) do
			local creep = attackableCreeps[i];
			local creepHP = creep:GetHealth();
			local creepEHP = creepHP;
			if (creep:WasRecentlyDamagedByCreep(5)) then
				if (creep:TimeSinceDamagedByCreep() > .6 and creep:TimeSinceDamagedByCreep() < 1) then
					creepEHP = creepEHP - 17; --17 is aprox dmg of a creep melee
				end
			end
			if (myDamage > creepEHP) then
				bot:Action_AttackUnit(attackableCreeps[i], true);
			end
		end
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
	
	if (bot:GetHealth() < 400) then
		currentState = RETREAT;
		print("Changing state from PUSH TO RETREAT")
	elseif (enemyGone()) then
		currentState = LANE;
		print("Changing state from PUSH TO LANE")
	end
end
function pushThink()
	--print("Pushing");
	local bot = GetBot();
	local enemyBot= getEnemyBot();
	local enemyList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local listLength = table.getn(enemyList);
	
	local target;
	if (bot:GetPlayerID() == 4) then
		target = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, -200);
	end
	if (bot:GetPlayerID() == 9) then
		target = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, -200);
	end
	
	local attackableCreeps = bot:GetNearbyLaneCreeps(500, true);
	
	--Later, maybe make this prioritize low creeps, so it can get lh while pushing
	if (table.getn(attackableCreeps) > 0) then
		--print("See attackable creep");
		bot:Action_AttackUnit(attackableCreeps[1], true);
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
	if (bot:GetPlayerID() == 9) then -- bot is Dire
		targetTower = GetTower(TEAM_DIRE, TOWER_MID_1);
		creepsLocation = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 0);
	elseif (bot:GetPlayerID() == 4) then -- bot is Radiant
		targetTower = GetTower(TEAM_RADIANT, TOWER_MID_1);
		creepsLocation = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 0);
	end
	
	-- are creeps under allied tower
	local creepsUnderTower = false;
	if (GetUnitToLocationDistance(targetTower, creepsLocation) < 900) then
		creepsUnderTower = true;
	end
	
	-- if deaths > 0 and health < 50% and tower health > 30% --> retreat 
	if ((GetHeroDeaths(bot:GetPlayerID()) > 0) and (bot:GetHealth() < (bot:GetMaxHealth()/100)*50) and (targetTower:GetHealth() > (targetTower:GetMaxHealth()/100)*30)) then
		print("Changing state from DEFEND to RETREAT");
		currentState = RETREAT;
	elseif (not creepsUnderTower) then -- if there are no enemies under tower --> lane
		print("Changing state from DEFEND to LANE");
		currentState = LANE;
	end
end

function defendThink()

	--print("Defending");
	local bot = GetBot();
	
	-- where bot needs to go
	local target;
	
	-- determine where mid tower is 
	if (bot:GetPlayerID() == 9) then -- bot is Dire
		target = GetLocationAlongLane(LANE_MID, 0.51);
	elseif (bot:GetPlayerID() == 4) then -- bot is Radiant
		target = GetLocationAlongLane(LANE_MID, 0.45);
	end
	
	-- attack anything that is near the tower
	bot:Action_AttackMove(target);

end

-- Attack
function attackUpdateState()
   local bot = GetBot();
   if(bot:GetHealth()/bot:GetMaxHealth() < .2) then  -- or tookToMuchDamange() (way too much)
      -- print("Attack -> Retreat: Health to low")
      currentState = RETREAT;
   elseif((bot:GetHealth() < 500
	      and GetUnitToUnitDistance(bot, GetTower(getEnemyTeam(), TOWER_MID_1)) < 1050)
	 or enemyGone()
   ) then
      --  or tookToMuchDamange
      -- print("Attack -> Lane: Tower to dangerous")
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
	
	if(bot:GetPlayerID() == 9) then
		targetTower = GetTower(TEAM_DIRE, TOWER_MID_1);
	elseif(bot:GetPlayerID() == 4) then 
		targetTower = GetTower(TEAM_RADIANT, TOWER_MID_1);
	end

	-- Move to Lane State if health becomes larger than certain value
	if (bot:GetHealth()/bot:GetMaxHealth() > 0.6) then 
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
	
	-- where bot needs to go
	local target;
	
	-- determine where base is 
	target = GetLocationAlongLane(LANE_MID, .05);
	
	-- move to base
	bot:Action_MoveToLocation(target);

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
      if (enemyList[i]:GetPlayerID() == 4 or enemyList[i]:GetPlayerID() == 9) then
	 enemyBot = enemyList[i];
      end
   end
   return enemyBot
end

-- Function to determine if the enemy is "gone" (gone is subjective)
function enemyGone()
   local bot = GetBot()
   enemyBot = getEnemyBot()
   return (GetUnitToUnitDistance(bot, enemyBot) > GONE_DISTANCE_CONSTANT or not enemyBot:CanBeSeen())
end
----------------------------------------------------------------------------------------------------

