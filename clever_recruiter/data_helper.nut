::mods_hookNewObjectOnce("ui/global/data_helper", function(o)
{
	local convertEntityHireInformationToUIData = o.convertEntityHireInformationToUIData;
	o.convertEntityHireInformationToUIData = function( _entity )
	{
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
				traits = _entity.getSkills().getSkillsByFunction(@(_skill) allowedTraits.find(_skill.getID()) != null);
			}
			else if (::CleverRecruiter.Mod.ModSettings.getSetting("Mode").getValue() == "Standard")
			{
				traits = _entity.getSkills().getSkillsByFunction(@(_skill) _skill.getType() == ::Const.SkillType.Trait);
			}

			foreach (trait in traits)
			{
				ret.Traits.push({
					id = trait.getID(),
					icon = trait.getIconColored()
				});
			}
		}

		ret.Properties <- {};
		local backgroundProperties = _entity.getSkills().getAllSkillsOfType(::Const.SkillType.Background)[0].onChangeAttributes();

		foreach (ID, property in ::CleverRecruiter.BaseProperties)
		{
			ret.Properties[ID] <- array(3);
			ret.Properties[ID][0] = _entity.getBaseProperties()[ID];
			ret.Properties[ID][1] = backgroundProperties[ID][1] + property;
			ret.Properties[ID][2] = _entity.getTalents()[::Const.Attributes[ID == "Stamina" ? "Fatigue" : ID]];
		}

		if (::CleverRecruiter.Mod.ModSettings.getSetting("Mode").getValue() == "Liter")
		{
			if (!_entity.getFlags().has("CleverRecruiter_RandAttribute"))
			{
				_entity.getFlags().add("CleverRecruiter_RandAttribute", ::Math.rand(0, ::CleverRecruiter.BaseProperties.len() - 1))
			}
			if (!_entity.getFlags().has("CleverRecruiter_RandTalent"))
			{
				local hasTalents = [];
				local i = 0;
				foreach (ID, property in ::CleverRecruiter.BaseProperties)
				{
					if (ret.Properties[ID][2] != 0) hasTalents.push(i);
					i++;
				}
				_entity.getFlags().add("CleverRecruiter_RandTalent", ::MSU.Array.rand(hasTalents))
			}
			ret.RandAttribute <- _entity.getFlags().getAsInt("CleverRecruiter_RandAttribute")
			ret.RandTalent <- _entity.getFlags().getAsInt("CleverRecruiter_RandTalent")
		}

		return ret;
	}
})
