EXPORTS = {}

EXPORTS.Init = function( self )
	self:SetContextThink( "init_think", function()
		self:FindAbilityByName("ember_spirit_flame_guard"):SetLevel(1)
		self.aiThink = aiThinkStandardSkill
		self.CheckIfHasAggro = CheckIfHasAggro
		self.Skill = UseSkillNoTarget
		self.ability = self:FindAbilityByName("ember_spirit_flame_guard")
		self.Unstuck = Unstuck
		self:SetContextThink( "ai_fireelemental.aiThink", Dynamic_Wrap( self, "aiThink" ), 0 )
	end, 0 )
end

return EXPORTS
