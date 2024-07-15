::CleverRecruiter.HookMod.hook("scripts/states/world_state", function(q) {
	q.onInit = @(__original) function() {
		__original();
		::World.createRoster(::CleverRecruiter.ID);
		local tempPlayer = ::World.getRoster(::CleverRecruiter.ID).create("scripts/entity/tactical/player");
		local tempBackground = ::new("scripts/skills/backgrounds/character_background");
		tempPlayer.getSkills().add(tempBackground);
		tempPlayer.setHitpoints = function( _hitpoints ) {}
		::CleverRecruiter.switcherooRandMax();
		tempBackground.buildAttributes();
		::CleverRecruiter.unswitcherooRand();
		::CleverRecruiter.BaseAttributes = ::MSU.Class.OrderedMap();
		::CleverRecruiter.BaseAttributes.Hitpoints <- tempPlayer.getBaseProperties().Hitpoints,
		::CleverRecruiter.BaseAttributes.Bravery <- tempPlayer.getBaseProperties().Bravery,
		::CleverRecruiter.BaseAttributes.Stamina <- tempPlayer.getBaseProperties().Stamina,
		::CleverRecruiter.BaseAttributes.Initiative <- tempPlayer.getBaseProperties().Initiative,
		::CleverRecruiter.BaseAttributes.MeleeSkill <- tempPlayer.getBaseProperties().MeleeSkill,
		::CleverRecruiter.BaseAttributes.RangedSkill <- tempPlayer.getBaseProperties().RangedSkill,
		::CleverRecruiter.BaseAttributes.MeleeDefense <- tempPlayer.getBaseProperties().MeleeDefense
		::CleverRecruiter.BaseAttributes.RangedDefense <- tempPlayer.getBaseProperties().RangedDefense,
		::World.deleteRoster(::CleverRecruiter.ID);
	}
})
