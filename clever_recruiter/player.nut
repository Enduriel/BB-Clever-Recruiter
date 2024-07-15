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

	q.CleverRecruiter_getMaxLvlPotentials <- function()
	{
		local attributes = ::array(::Const.Attributes.COUNT);
		local oldAttributes = this.m.Attributes;
		local minAttributes = [];
		this.m.Attributes = minAttributes;
		::CleverRecruiter.switcherooRandMin();
		this.fillAttributeLevelUpValues(::Const.XP.MaxLevelWithPerkpoints - 1 - this.m.LevelUpsSpent);
		::CleverRecruiter.unswitcherooRand();
		local maxAttributes = [];
		this.m.Attributes = maxAttributes;
		::CleverRecruiter.switcherooRandMax();
		this.fillAttributeLevelUpValues(::Const.XP.MaxLevelWithPerkpoints - 1 - this.m.LevelUpsSpent);
		::CleverRecruiter.unswitcherooRand();
		this.m.Attributes = oldAttributes;
		local attributeKeys = ::CleverRecruiter.BaseAttributes.keys();
		local properties = this.getBaseProperties();
		for (local i = 0; i < attributes.len(); ++i) {
			local id = attributeKeys[i];
			local minAttributesSum = minAttributes[i].reduce(@(_a, _b) _a + _b);
			local maxAttributesSum = maxAttributes[i].reduce(@(_a, _b) _a + _b);
			attributes[i] = {
				Min = minAttributesSum + properties[id],
				Max = maxAttributesSum + properties[id],
				Mean = ::Math.round((minAttributesSum + maxAttributesSum) / 2.0) + properties[id]
			};
		}
		local unMovedAttributes = ::array(attributes.len());
		for (local i = 0; i < attributes.len(); ++i) {
			unMovedAttributes[i] = {
				Min = attributes[i].Min - properties[attributeKeys[i]],
				Max = attributes[i].Max - properties[attributeKeys[i]],
				Mean = attributes[i].Mean - properties[attributeKeys[i]]
			}
		}
		::MSU.Log.printData(attributes, 2, false, 100);
		::MSU.Log.printData(unMovedAttributes, 2, false, 100);
		return attributes;
	}
})
