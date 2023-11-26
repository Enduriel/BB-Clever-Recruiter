::CleverRecruiter.HookMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_hire_dialog_module", function(q)
{
	q.CleverRecruiter_onPaidDismissRosterEntity <- function( _entityID )
	{
		local entity = this.findEntityWithinRoster(_entityID)

		if (entity == null)
		{
			return {
				Result = ::Const.UI.Error.RosterEntryNotFound,
				Assets = null
			};
		}

		local tryoutCost = entity.getTryoutCost();
		if (tryoutCost > ::World.Assets.getMoney())
		{
			return {
				Result = ::Const.UI.Error.NotEnoughMoney,
				Assets = null
			};
		}
		::World.getRoster(this.m.RosterID).remove(entity);
		if (::CleverRecruiter.Mod.ModSettings.getSetting("Mode").getValue() == "Standard") ::World.Assets.addMoney(-tryoutCost);

		if (this.World.getRoster(this.m.RosterID).getSize() == 0)
		{
			this.m.Parent.getMainDialogModule().reload();
		}

		return {
			Result = 0,
			Assets = this.m.Parent.queryAssetsInformation()
		}

	}

	q.onHireRosterEntry = @(__original) function( _entityID )
	{
		local entity = this.findEntity__originalWithinRoster(_entityID);

		if (entity != null && entity.getFlags().has("CleverRecruiter_RandAttribute"))
		{
			entity.getFlags().remove("CleverRecruiter_RandAttribute")
			entity.getFlags().remove("CleverRecruiter_RandTalent")
		}
		return __original(_entityID);
	}
});
