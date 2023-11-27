::CleverRecruiter.HookMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_hire_dialog_module", function(q)
{
	q.CleverRecruiter_onDismissRosterEntity <- function( _entityID )
	{
		local entity = this.findEntityWithinRoster(_entityID)

		if (entity == null)
		{
			return {
				Result = ::Const.UI.Error.RosterEntryNotFound,
				Assets = null
			};
		}
		::World.getRoster(this.m.RosterID).remove(entity);

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
		local entity = this.findEntityWithinRoster(_entityID);
		entity.CleverRecruiter_clearRandoms();
		return __original(_entityID);
	}
});
