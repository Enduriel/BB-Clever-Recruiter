::CleverRecruiter.HookMod.hook("scripts/ui/global/data_helper", function(q)
{
	q.convertEntityHireInformationToUIData = @(__original) function( _entity )
	{
		local ret = __original(_entity);

		ret.CleverRecruiter <- {
			Legends = ::Hooks.hasMod("mod_legends"),
			Traits = [],
			Attributes = []
		}
		local getMySettingValue = @(_id) ::CleverRecruiter.Mod.ModSettings.getSetting(_id).getValue();

		local dataToShow = {
			Traits = _entity.isTryoutDone() ? "None" : getMySettingValue("TraitInfo"),
			Attributes = _entity.isTryoutDone() ? getMySettingValue("AttributeInfoPostTryout") : getMySettingValue("AttributeInfoPreTryout")
		}

		local traits;
		if (dataToShow.Traits == "All")
		{
			traits = _entity.getSkills().getSkillsByFunction(@(_skill) _skill.getType() == ::Const.SkillType.Trait && !_skill.isHidden());
		}
		else if (dataToShow.Traits == "Alternate")
		{
			traits = _entity.getSkills().getSkillsByFunction(@(_skill) ::CleverRecruiter.AlternateTraits.find(_skill.getID()) != null);
		}

		if (dataToShow.Traits != "None")
		{
			foreach (trait in traits)
			{
				ret.CleverRecruiter.Traits.push({
					id = trait.getID(),
					icon = trait.getIconColored()
				});
			}
		}

		local backgroundAttributes = _entity.getSkills().getAllSkillsOfType(::Const.SkillType.Background)[0].onChangeAttributes();
		foreach (ID, property in ::CleverRecruiter.BaseAttributes)
		{
			ret.CleverRecruiter.Attributes.push([
				_entity.getBaseProperties()[ID],
				backgroundAttributes[ID][1] + property,
				_entity.getTalents()[::Const.Attributes[ID == "Stamina" ? "Fatigue" : ID]],
				null
			]);
		}
		if (dataToShow.Attributes == "OnlyNumbers"  || dataToShow.Attributes == "None")
		{
			foreach (attributeInfo in ret.CleverRecruiter.Attributes)
			{
				attributeInfo[2] = 0;
			}
		}

		if (dataToShow.Attributes == "OnlyTalents" || dataToShow.Attributes == "None")
		{
			foreach (attributeInfo in ret.CleverRecruiter.Attributes)
			{
				attributeInfo[0] = null;
			}
		}

		if (dataToShow.Attributes == "Random")
		{
			if (!_entity.CleverRecruiter_hasRolled())
				_entity.CleverRecruiter_rollRandoms();

			local numAttributesToShow = _entity.isTryoutDone() ? getMySettingValue("NumRandomStatsVisiblePostTryout") : getMySettingValue("NumRandomStatsVisiblePreTryout");
			local numTalentsToShow = _entity.isTryoutDone() ? getMySettingValue("NumRandomTalentsVisiblePostTryout") : getMySettingValue("NumRandomTalentsVisiblePreTryout");

			local attributes = array(ret.CleverRecruiter.Attributes.len());
			foreach (i, attributeInfo in ret.CleverRecruiter.Attributes)
			{
				if (_entity.CleverRecruiter_getRandAttributes().find(i) + 1 > numAttributesToShow)
					attributeInfo[0] = null;
				attributes[i] = [i, attributeInfo];
			}

			local attributesWithTalents = attributes.map(@(_e) [_entity.CleverRecruiter_getRandTalents().find(_e[0]), _e[1]]);
			attributesWithTalents.sort(@(_a, _b) _a[0] <=> _b[0])
			attributesWithTalents.apply(@(_e) _e[1]);

			local j = 0;
			foreach (i, attributeInfo in attributesWithTalents)
			{
				if (j >= numTalentsToShow)
					attributeInfo[2] = 0;
				else if (attributeInfo[2] != 0)
					++j;
			}
		}

		local talents = ret.CleverRecruiter.Attributes.map(@(_e) _e[2]);
		local maxLvlPotentials = ::CleverRecruiter.Mod.ModSettings.getSetting("MaxLvlPotential").getValue() ? _entity.CleverRecruiter_getMaxLvlPotentials(talents) : ::array(8);

		foreach (i, attributeInfo in ret.CleverRecruiter.Attributes)
		{
			if (attributeInfo[0] != null) {
				attributeInfo[3] = maxLvlPotentials[i];
			}
		}

		return ret;
	}
})
