--[[
Pudge AI
]]

require( "ai/ai_core_new" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 1 )
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorVortex } ) 
    --thisEntity:FindAbilityByName("tiny_grow"):SetLevel(3)
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

--------------------------------------------------------------------------------------------------------

BehaviorNone = {}

function BehaviorNone:Evaluate()
	return 1 -- must return a value > 0, so we have a default
end

function BehaviorNone:Begin()
	self.endTime = GameRules:GetGameTime() + .1
	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = thisEntity.nextTarget
	}
end

function BehaviorNone:Continue()
	self.endTime = GameRules:GetGameTime() + .1
end

--------------------------------------------------------------------------------------------------------

BehaviorVortex = {}

function BehaviorVortex:Evaluate()
	self.VortexAbility = thisEntity:FindAbilityByName("ancient_apparition_ice_vortex")
	local desire = 0
	local target

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.VortexAbility and self.VortexAbility:IsFullyCastable() then
		local range = 600
		local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false )
		if #enemies > 0 then target = enemies[1] end
	end

	if target then
		desire = 3
		self.target = target
	else
		desire = 0
	end

	return desire
end

function BehaviorVortex:Begin()
	self.endTime = GameRules:GetGameTime() + .1

	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		UnitIndex = thisEntity:entindex(),
		Position = self.target:GetAbsOrigin(),
		AbilityIndex = self.VortexAbility:entindex(),
		TargetIndex = nil
	}
end

BehaviorVortex.Continue = BehaviorVortex.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

--------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorVortex }
