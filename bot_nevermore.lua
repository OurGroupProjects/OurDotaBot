

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
	print("Applying state " .. currentState);
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
end
function laneThink()
end

-- Push
function pushUpdateState()
end
function pushThink()
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
end
function attackThink()
end

-- Retreat
function retreatUpdateState()
end
function retreatThink()
end

----------------------------------------------------------------------------------------------------

