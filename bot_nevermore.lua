

--State machine shit

--Constants for states
local LANE = 1; -- Laning involves staying in mid and last hitting creeps, this happens when the creeps are not near the ally tower or under the enemy tower
local PUSH = 2; -- Pushing involves attacking the enemy tower, this happens when there are ally creeps under the enemy tower who are attacking the tower
local DEFEND = 3; -- Defending involves attacking anything that is attacking the ally tower, this happens when enemy creeps or heroes are attacking the ally tower
local ATTACK = 4; -- Attacking involves hitting and chasing an enemy hero, this happens when the enemy hero's health is low
local RETREAT = 5; -- Retreating involves running back to base (or shrine?) to heal, this happens when the hero's health is low

-- Holds the initial state
local initialState = PUSH;

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
end
function laneThink()

	--print("Thinkin to lane");
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
	elseif (GetUnitToUnitDistance(bot, enemyBot) < 500) then
		currentState = LANE;
		print("Changing state from PUSH TO LANE")
	end
end
function pushThink()
	--print("Thinkin to push");
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
end
function defendThink()

	print("in defendThink");
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
end
function retreatThink()

	print("in retreatThink");
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
   return (GetUnitToUnitDistance(bot, enemyBot) > 2000 or not enemyBot:CanBeSeen())
end
----------------------------------------------------------------------------------------------------

