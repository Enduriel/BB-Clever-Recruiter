::CleverRecruiter.HookMod.hook("scripts/entity/tactical/player", function(q) {
	q.m.CleverRecruiter_RandAttributes <- null;
	q.m.CleverRecruiter_RandTalents <- null;

	q.create = @(__original) function() {
		__original();
		this.m.CleverRecruiter_RandAttributes = [];
		this.m.CleverRecruiter_RandTalents = [];
	}

	q.getTryoutCost = @(__original) function() {
		return __original() * ::CleverRecruiter.Mod.ModSettings.getSetting("TryoutCostMult").getValue();
	}

	q.onSerialize = @(__original) function( _out ) {
		::CleverRecruiter.Mod.Serialization.flagSerialize("RandTalents", this.m.CleverRecruiter_RandTalents, this.getFlags());
		::CleverRecruiter.Mod.Serialization.flagSerialize("RandAttributes", this.m.CleverRecruiter_RandAttributes, this.getFlags());
		__original(_out);
	}

	q.onDeserialize = @(__original) function( _in ) {
		__original(_in);
		if (::CleverRecruiter.Mod.Serialization.isSavedVersionAtLeast("2.0.0-alpha.1", _in.getMetaData()))
		{
			this.m.CleverRecruiter_RandTalents = ::CleverRecruiter.Mod.Serialization.flagDeserialize("RandTalents", [], null, this.getFlags())
			this.m.CleverRecruiter_RandAttributes = ::CleverRecruiter.Mod.Serialization.flagDeserialize("RandAttributes", [], null,	 this.getFlags())
		}
	}

	q.CleverRecruiter_rollRandoms <- function()
	{
		this.m.CleverRecruiter_RandAttributes = [0, 1, 2, 3, 4, 5, 6, 7];
		this.m.CleverRecruiter_RandTalents = clone this.m.CleverRecruiter_RandAttributes;
		::MSU.Array.shuffle(this.m.CleverRecruiter_RandAttributes);
		::MSU.Array.shuffle(this.m.CleverRecruiter_RandTalents);
	}

	q.CleverRecruiter_clearRandoms <- function()
	{
		this.m.CleverRecruiter_RandAttributes.clear();
		this.m.CleverRecruiter_RandTalents.clear();
	}

	q.CleverRecruiter_hasRolled <- function()
	{
		return this.m.CleverRecruiter_RandTalents.len() != 0;
	}

	q.CleverRecruiter_getRandTalents <- function()
	{
		return this.m.CleverRecruiter_RandTalents;
	}

	q.CleverRecruiter_getRandAttributes <- function()
	{
		return this.m.CleverRecruiter_RandAttributes;
	}

	q.CleverRecruiter_getMaxLvlPotentials <- function()
	{
		local attributes = ::array(::Const.Attributes.COUNT);
		local numLevelUpsLeft = ::Const.XP.MaxLevelWithPerkpoints - this.m.LevelUpsSpent;
		local attributeKeys = ::CleverRecruiter.BaseAttributes.keys();
		local properties = this.getBaseProperties();
		for (local i = 0; i < attributes.len(); ++i)
		{
			local id = attributeKeys[i];
			local talent = this.m.Talents[::Const.Attributes[id == "Stamina" ? "Fatigue" : id]];
			local min = ::Const.AttributesLevelUp[i].Min + (talent == 3 ? 2 : talent);
			local max = ::Const.AttributesLevelUp[i].Max + (talent == 3 ? 1 : 0);
			attributes[i] = {
				Min = min * numLevelUpsLeft + properties[id],
				Max = max * numLevelUpsLeft + properties[id],
				Mean = ::Math.round((min + max) / 2.0 * numLevelUpsLeft) + properties[id]
			};
		}
		return attributes;
	}
})
