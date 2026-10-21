::CleverRecruiter.initBaseAttributes <- function() {
	::World.createRoster(::CleverRecruiter.ID);
	try {
		local tempPlayer = ::World.getRoster(::CleverRecruiter.ID).create("scripts/entity/tactical/player");
		local tempBackground = ::new("scripts/skills/backgrounds/character_background");
		tempPlayer.getSkills().add(tempBackground);
		tempPlayer.setHitpoints = function( _hitpoints ) {}
		::CleverRecruiter.callWithRand(::CleverRecruiter.switcherooRandMax, tempBackground.buildAttributes, tempBackground);
		local baseAttributes = ::MSU.Class.OrderedMap();
		baseAttributes.Hitpoints <- tempPlayer.getBaseProperties().Hitpoints;
		baseAttributes.Bravery <- tempPlayer.getBaseProperties().Bravery;
		baseAttributes.Stamina <- tempPlayer.getBaseProperties().Stamina;
		baseAttributes.Initiative <- tempPlayer.getBaseProperties().Initiative;
		baseAttributes.MeleeSkill <- tempPlayer.getBaseProperties().MeleeSkill;
		baseAttributes.RangedSkill <- tempPlayer.getBaseProperties().RangedSkill;
		baseAttributes.MeleeDefense <- tempPlayer.getBaseProperties().MeleeDefense;
		baseAttributes.RangedDefense <- tempPlayer.getBaseProperties().RangedDefense;
		::CleverRecruiter.BaseAttributes = baseAttributes;
	}
	catch (error) {
		::World.deleteRoster(::CleverRecruiter.ID);
		throw error;
	}
	::World.deleteRoster(::CleverRecruiter.ID);
}

::CleverRecruiter.HookMod.hook("scripts/states/world_state", function(q) {
	q.onInit = @(__original) function() {
		__original();
		try {
			::CleverRecruiter.initBaseAttributes();
		}
		catch (error) {
			// retried when the hire window is opened, see data_helper.nut
			::logError("Clever Recruiter: failed to work out the base attribute ranges: " + error);
		}
	}
})
