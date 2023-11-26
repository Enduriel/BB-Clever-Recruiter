::CleverRecruiter.HookMod.hook("scripts/states/world_state", function (q)
{
	q.onInit = @(__original) function()
	{
		__original();
		::World.createRoster(::CleverRecruiter.ID);
		local tempPlayer = ::World.getRoster(::CleverRecruiter.ID).create("scripts/entity/tactical/player");
		local tempBackground = ::new("scripts/skills/backgrounds/character_background");
		tempPlayer.getSkills().add(tempBackground);
		tempPlayer.setHitpoints = function( _hitpoints ) {}
		local rand = ::Math.rand;
		::Math.rand = @(_a, _b) _b;
		tempBackground.buildAttributes();
		::Math.rand = rand;
		::CleverRecruiter.BaseProperties = ::MSU.Class.OrderedMap();
		::CleverRecruiter.BaseProperties.Hitpoints <- tempPlayer.getBaseProperties().Hitpoints,
		::CleverRecruiter.BaseProperties.MeleeSkill <- tempPlayer.getBaseProperties().MeleeSkill,
		::CleverRecruiter.BaseProperties.Stamina <- tempPlayer.getBaseProperties().Stamina,
		::CleverRecruiter.BaseProperties.RangedSkill <- tempPlayer.getBaseProperties().RangedSkill,
		::CleverRecruiter.BaseProperties.Bravery <- tempPlayer.getBaseProperties().Bravery,
		::CleverRecruiter.BaseProperties.MeleeDefense <- tempPlayer.getBaseProperties().MeleeDefense,
		::CleverRecruiter.BaseProperties.Initiative <- tempPlayer.getBaseProperties().Initiative
		::CleverRecruiter.BaseProperties.RangedDefense <- tempPlayer.getBaseProperties().RangedDefense,
		::World.deleteRoster(::CleverRecruiter.ID);
	}
});
