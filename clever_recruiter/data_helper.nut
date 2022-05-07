::logInfo("convertEntityHireInformationToUIData");
::mods_hookNewObjectOnce("ui/global/data_helper", function(o)
{
	local convertEntityHireInformationToUIData = o.convertEntityHireInformationToUIData;
	o.convertEntityHireInformationToUIData = function( _entity )
	{
		::logInfo("convertEntityHireInformationToUIData");
		local ret = convertEntityHireInformationToUIData(_entity);
		if (!_entity.isTryoutDone())
		{
			local traits = []
			if (::CleverRecruiter.Mod.ModSettings.getSetting("Mode").getValue() == "Alternate")
			{
				local allowedTraits = [
					"trait.asthmatic",
					"trait.athletic",
					"trait.cocky",
					"trait.determined",
					"trait.dexterous",
					"trait.dumb",
					"trait.eagle_eyes",
					"trait.fat",
					"trait.greedy",
					"trait.hesitant",
					"trait.huge",
					"trait.impatient",
					"trait.iron_jaw",
					"trait.night_owl",
					"trait.short_sighted",
					"trait.spartan",
					"trait.strong",
					"trait.swift",
					"trait.tiny"
				];
				traits = _entity.getSkills().getSkillsByFunction(function(_skill)
				{
					return allowedTraits.find(_skill) != null;
				});
			}
			else if (::CleverRecruiter.Mod.ModSettings.getSetting("Mode").getValue() == "Standard")
			{
				traits = _entity.getSkills().getSkillsByFunction(function(_skill)
				{
					return _skill.getType() == ::Const.SkillType.Trait;
				});
			}

			foreach (trait in traits)
			{
				ret.Traits.push({
					id = trait.getID(),
					icon = trait.getIconColored()
				});
			}
		}
		return ret;
	}
})
