
--[[require( GetScriptDirectory().."/constants" )

local heroData = require( GetScriptDirectory().."/hero_data" )
local utils = require( GetScriptDirectory().."/utility" )
local dt = require( GetScriptDirectory().."/decision" )
local gHeroVar = require( GetScriptDirectory().."/global_hero_data" )
local ability = require( GetScriptDirectory().."/abilityUse/abilityUse_nevermore" )

local SKILL_Q = heroData.nevermore.SKILL_0 -- 1 & 2 are the other razes
local SKILL_W = heroData.nevermore.SKILL_3
local SKILL_E = heroData.nevermore.SKILL_4
local SKILL_R = heroData.nevermore.SKILL_5

local TALENT1 = heroData.nevermore.TALENT_0
local TALENT2 = heroData.nevermore.TALENT_1
local TALENT3 = heroData.nevermore.TALENT_2
local TALENT4 = heroData.nevermore.TALENT_3
local TALENT5 = heroData.nevermore.TALENT_4
local TALENT6 = heroData.nevermore.TALENT_5
local TALENT7 = heroData.nevermore.TALENT_6
local TALENT8 = heroData.nevermore.TALENT_7

local AbilityPriority = {
    SKILL_W,    SKILL_Q,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_R,    TALENT2,
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_E,    TALENT4,
    SKILL_E,    SKILL_R,    TALENT6,    TALENT7
}

local botSF = dt:new()

function botSF:new(o)
    o = o or dt:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

local nevermoreBot = botSF:new{abilityPriority = AbilityPriority}

function nevermoreBot:DoHeroSpecificInit(bot)
end

function nevermoreBot:ConsiderAbilityUse()
    return ability.AbilityUsageThink(GetBot())
end

function nevermoreBot:GetNukeDamage(bot, target)
    return ability.nukeDamage( bot, target )
end

function nevermoreBot:QueueNuke(bot, target, actionQueue, engageDist)
    return ability.queueNuke( bot, target, actionQueue, engageDist )
end--]]


--State machine shit

--Constants for states
local LANE = 1;
local PUSH = 2;
local DEFEND = 3;
local ATTACK = 4;
local RETREAT = 5;

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
	 currentState = PUSH;

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
end

-- Push
function pushUpdateState()
end
function pushThink()
	--print("Thinkin to push");
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
		print("See attackable creep");
		bot:Action_AttackUnit(attackableCreeps[1], true);
	else 
		bot:Action_MoveToLocation(target);
	end
	
end

-- Defend
function defendUpdateState()
end
function defendThink()
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

