::CleverRecruiter.HookMod.hook("scripts/skills/backgrounds/character_background", function(q) {
	// Remember the highest value each attribute could have rolled, by first running the background's own buildAttributes
	// with every roll at its maximum. So the shown maximum includes whatever the loaded mods add on top of the background's
	// ranges, e.g. Legends' attributes from the perk groups. The rolls are pinned, so this uses up no random numbers.
	q.buildAttributes = @(__original) function( ... ) {
		vargv.insert(0, this);
		local actor = this.getContainer().getActor();
		if (::CleverRecruiter.RealRand == null && "CleverRecruiter_MaxAttributes" in actor.m) {
			::CleverRecruiter.callWithRand(::CleverRecruiter.switcherooRandMax, @() __original.acall(vargv), this);
			local properties = actor.getBaseProperties();
			local maxAttributes = {};
			foreach (id in ::CleverRecruiter.AttributeIDs)
				maxAttributes[id] <- properties[id];
			actor.m.CleverRecruiter_MaxAttributes = maxAttributes;
		}
		return __original.acall(vargv);
	}
})
