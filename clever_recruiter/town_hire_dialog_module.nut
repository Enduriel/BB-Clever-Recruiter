::mods_hookExactClass("ui/screens/world/modules/world_town_screen/town_hire_dialog_module", function(o)
{
	o.CleverRecruiter_onPaidDismissRosterEntity <- function( _entityID )
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
		::World.Assets.addMoney(-tryoutCost);

		if (this.World.getRoster(this.m.RosterID).getSize() == 0)
		{
			this.m.Parent.getMainDialogModule().reload();
		}

		return {
			Result = 0,
			Assets = this.m.Parent.queryAssetsInformation()
		}

	}
});
