var CleverRecruiter = {
	ID : "mod_clever_recruiter",
	ModeID : "Mode",
	ShowDismiss : "Dismiss"
}



CleverRecruiter.WorldTownScreenHireDialogModule_createDIV = WorldTownScreenHireDialogModule.prototype.createDIV
WorldTownScreenHireDialogModule.prototype.createDIV = function (_parentDiv)
{
	CleverRecruiter.WorldTownScreenHireDialogModule_createDIV.call(this, _parentDiv);
	var self = this;
	// this.mDetailsPanel.TryoutButton.findButtonText().html(MSU.getSettingValue(CleverRecruiter.ID, "Mode") == "Standard" ? "Dismiss" : "Try out");


	this.mDetailsPanel.TryoutButton.bindFirst('click', function(_event)
	{
		console.error("hi")
		switch(MSU.getSettingValue(CleverRecruiter.ID, "Mode"))
		{
			case "Alternate":
			case "Lite":
				if (!MSU.getSettingValue(CleverRecruiter.ID, CleverRecruiter.ShowDismiss) || !self.mSelectedEntry.data('entry')["IsTryoutDone"]) break;
			case "Standard":
				_event.stopImmediatePropagation();
				self.CleverRecruiter_dimissSelectedEntry();
		}
	})
}

CleverRecruiter.WorldTownScreenHireDialogModule_updateDetailsPanel = WorldTownScreenHireDialogModule.prototype.updateDetailsPanel;
WorldTownScreenHireDialogModule.prototype.updateDetailsPanel = function (_element)
{
	CleverRecruiter.WorldTownScreenHireDialogModule_updateDetailsPanel.call(this, _element);
	if (_element === null || _element.length == 0) return;
	var data = _element.data('entry');

	if (MSU.getSettingValue(CleverRecruiter.ID, "Mode") == "Standard")
	{
		var icon = this.mDetailsPanel.CharacterTraitsContainer.find('[src="' + Path.GFX + Asset.ICON_UNKNOWN_TRAITS + '"]:first')
		icon.unbindTooltip();
		icon.remove();

		this.mDetailsPanel.TryoutButton.findButtonText().html("Dismiss");
		this.mDetailsPanel.TryoutButton.addClass('display-block').removeClass('display-none');
	}
	else
	{
		if (MSU.getSettingValue(CleverRecruiter.ID, CleverRecruiter.ShowDismiss) && data['IsTryoutDone'])
		{
			this.mDetailsPanel.TryoutButton.addClass('display-block').removeClass('display-none');
			this.mDetailsPanel.TryoutButton.findButtonText().html("Dismiss");
		}
		else
		{
			this.mDetailsPanel.TryoutButton.findButtonText().html("Try out");
		}
	}

	if (MSU.getSettingValue(CleverRecruiter.ID, "Mode") == "Standard" || MSU.getSettingValue(CleverRecruiter.ID, "Mode") == "Alternate" && !data['IsTryoutDone'])
	{
		for(var i = 0; i < data.Traits.length; ++i)
		{
		    var icon = $('<img src="' + Path.GFX + data.Traits[i].icon + '"/>');
		    icon.bindTooltip({ contentType: 'status-effect', entityId: data.ID, statusEffectId: data.Traits[i].id });
		    this.mDetailsPanel.CharacterTraitsContainer.append(icon);
		}
	}
}

CleverRecruiter.WorldTownScreenHireDialogModule_updateListEntryValues = WorldTownScreenHireDialogModule.prototype.updateListEntryValues;
WorldTownScreenHireDialogModule.prototype.updateListEntryValues = function()
{
	CleverRecruiter.WorldTownScreenHireDialogModule_updateListEntryValues.call(this);
	var self = this;
    this.mListContainer.findListScrollContainer().find('.list-entry').each(function(index, element)
	{
		var entry = $(element);
	    var initialMoneyCostElement = entry.find('.is-initial-money-cost');
	    var traitsContainer = entry.find('.is-traits-container');
	    var data = entry.data('entry');
	    var initialMoneyCost = data['InitialMoneyCost'];
	    if (MSU.getSettingValue(CleverRecruiter.ID, "Mode") == "Standard")
	    {
	    	var icon = traitsContainer.find('[src="' + Path.GFX + Asset.ICON_UNKNOWN_TRAITS + '"]:first')
	    	icon.unbindTooltip();
	    	icon.remove();
	    }
	    if (MSU.getSettingValue(CleverRecruiter.ID, "Mode") == "Standard" || MSU.getSettingValue(CleverRecruiter.ID, "Mode") == "Alternate" && !data['IsTryoutDone'])
	    {
	    	for(var i = 0; i < data.Traits.length; ++i)
	    	{
	    	    var icon = $('<img src="' + Path.GFX + data.Traits[i].icon + '"/>');
	    	    icon.bindTooltip({ contentType: 'status-effect', entityId: data.ID, statusEffectId: data.Traits[i].id });
	    	    traitsContainer.append(icon);
	    	}
	    }
	});
}

WorldTownScreenHireDialogModule.prototype.CleverRecruiter_dimissSelectedEntry = function ()
{
	var self = this;
	if(this.mSelectedEntry !== null)
	{
		var data = this.mSelectedEntry.data('entry');
		if ('ID' in data && data['ID'] !== null)
		{
			this.CleverRecruiter_notifyBackendPaidDismissRosterEntity(data['ID'], function (_data)
			{
				if (_data.Result != 0)
				{
					if (_data.Result == ErrorCode.NotEnoughMoney) self.mAssets.mMoneyAsset.shakeLeftRight();
					else console.error("Failed to hire. Reason: Unknown");
					return;
				}

				for (var i = 0; i < self.mRoster.length; ++i)
				{
					if (self.mRoster[i]['ID'] == data['ID'])
					{
						self.removeRosterEntry({ item: self.mRoster[i], index: i });
						break;
					}
				}

				self.mParent.loadAssetData(_data.Assets);
				self.updateListEntryValues();
				self.updateDetailsPanel(self.mSelectedEntry);
			});
		}
	}
}

WorldTownScreenHireDialogModule.prototype.CleverRecruiter_notifyBackendPaidDismissRosterEntity = function(_entityID, _callback)
{
	SQ.call(this.mSQHandle, "CleverRecruiter_onPaidDismissRosterEntity", _entityID, _callback);
}
