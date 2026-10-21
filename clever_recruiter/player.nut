::CleverRecruiter.HookMod.hook("scripts/entity/tactical/player", function(q) {
	q.m.CleverRecruiter_RandAttributes <- null;
	q.m.CleverRecruiter_RandTalents <- null;

	q.create = @(__original) function() {
		__original();
		this.m.CleverRecruiter_RandAttributes = [];
		this.m.CleverRecruiter_RandTalents = [];
	}

	q.getTryoutCost = @(__original) function() {
		return ::Math.round(__original() * ::CleverRecruiter.Mod.ModSettings.getSetting("TryoutCostMult").getValue());
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

	q.CleverRecruiter_getMaxLvlPotentials <- function(_knownTalents)
	{
		// recruits who already spent all their level ups (e.g. veterans) have none left, so their arrays stay empty
		local numLevelUps = ::Math.max(0, ::Const.XP.MaxLevelWithPerkpoints - 1 - this.m.LevelUpsSpent);
		local oldTalents = this.m.Talents;
		local oldAttributes = this.m.Attributes;
		local minAttributes = [];
		local maxAttributes = [];
		this.m.Talents = _knownTalents;
		try {
			this.m.Attributes = minAttributes;
			::CleverRecruiter.callWithRand(::CleverRecruiter.switcherooRandMin, @() this.fillAttributeLevelUpValues(numLevelUps), this);
			this.m.Attributes = maxAttributes;
			::CleverRecruiter.callWithRand(::CleverRecruiter.switcherooRandMax, @() this.fillAttributeLevelUpValues(numLevelUps), this);
		}
		catch (error) {
			this.m.Attributes = oldAttributes;
			this.m.Talents = oldTalents;
			throw error;
		}
		this.m.Attributes = oldAttributes;
		this.m.Talents = oldTalents;

		local sum = function( _values ) {
			local ret = 0;
			foreach (value in _values)
				ret += value;
			return ret;
		}
		local attributes = [];
		local properties = this.getBaseProperties();
		foreach (id, _ in ::CleverRecruiter.BaseAttributes) {
			local i = ::CleverRecruiter.getAttributeIndex(id);
			local minAttributesSum = sum(minAttributes[i]);
			local maxAttributesSum = sum(maxAttributes[i]);
			attributes.push({
				Min = minAttributesSum + properties[id],
				Max = maxAttributesSum + properties[id],
				Mean = ::Math.round((minAttributesSum + maxAttributesSum) / 2.0) + properties[id]
			});
		}
		return attributes;
	}
})
