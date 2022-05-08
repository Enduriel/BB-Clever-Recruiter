::mods_hookExactClass("states/world_state", function (o)
{
	local onInit = o.onInit;
	o.onInit = function()
	{
		onInit();

		::World.createRoster(::CleverRecruiter.ID);
		local tempPlayer = ::World.getRoster(::CleverRecruiter.ID).create("scripts/entity/tactical/player");
		local tempBackground = ::new("scripts/skills/backgrounds/character_background");
		tempPlayer.getSkills().add(tempBackground);
		tempPlayer.setHitpoints = function( _hitpoints ) {}
		local rand = ::Math.rand;
		::Math.rand = @(_a, _b) _b;
		tempBackground.buildAttributes();
		::Math.rand = rand;
		::CleverRecruiter.BaseProperties = {
			Hitpoints = tempPlayer.getBaseProperties().Hitpoints,
			Bravery = tempPlayer.getBaseProperties().Bravery,
			Stamina = tempPlayer.getBaseProperties().Stamina,
			MeleeSkill = tempPlayer.getBaseProperties().MeleeSkill,
			RangedSkill = tempPlayer.getBaseProperties().RangedSkill,
			MeleeDefense = tempPlayer.getBaseProperties().MeleeDefense,
			RangedDefense = tempPlayer.getBaseProperties().RangedDefense,
			Initiative = tempPlayer.getBaseProperties().Initiative
		}
		::World.deleteRoster(::CleverRecruiter.ID);
	}
});
