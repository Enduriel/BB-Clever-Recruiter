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
	this.mDetailsPanel.TryoutButton.bindFirst('click', function(_event)
	{
		switch(MSU.getSettingValue(CleverRecruiter.ID, "Mode"))
		{
			case "Alternate":
			case "Lite":
			case "Liter":
				if (!MSU.getSettingValue(CleverRecruiter.ID, CleverRecruiter.ShowDismiss) || !self.mSelectedEntry.data('entry')["IsTryoutDone"]) break;
			case "Standard":
				_event.stopImmediatePropagation();
				self.CleverRecruiter_dimissSelectedEntry();
		}
	});

	this.mCleverRecruiter = {
		Grid : $('<div class="clever-recruiter-stats-grid"/>'),
		Properties : [
			{
				ID : "Hitpoints",
				IconAsset : Asset.ICON_HEALTH
			},
			{
				ID : "MeleeSkill",
				IconAsset : Asset.ICON_MELEE_SKILL
			},
			{
				ID : "Stamina",
				IconAsset : Asset.ICON_FATIGUE
			},
			{
				ID : "RangedSkill",
				IconAsset : Asset.ICON_RANGE_SKILL
			},
			{
				ID : "Bravery",
				IconAsset : Asset.ICON_BRAVERY
			},
			{
				ID : "MeleeDefense",
				IconAsset : Asset.ICON_MELEE_DEFENCE
			},
			{
				ID : "Initiative",
				IconAsset : Asset.ICON_INITIATIVE
			},
			{
				ID : "RangedDefense",
				IconAsset : Asset.ICON_RANGE_DEFENCE
			}
		]
	}
	var row;
	var container;
	for (var i = 0; i < this.mCleverRecruiter.Properties.length; i++)
	{
		if (i % 2 == 0)
		{
			row = $('<div class="stat-row"/>');
			this.mCleverRecruiter.Grid.append(row);
		}
		container = $('<div class="stat-container"/>');
		row.append(container)
		container.append($('<img class="stat-icon" src="' + Path.GFX + this.mCleverRecruiter.Properties[i].IconAsset + '"/>'));
		this.mCleverRecruiter.Properties[i].Text = $('<div class="stat-text"/>');
		container.append(this.mCleverRecruiter.Properties[i].Text);
		this.mCleverRecruiter.Properties[i].Talents = $('<img class="talent" src="' + Path.GFX + 'ui/icons/talent_0.png"/>');
		container.append(this.mCleverRecruiter.Properties[i].Talents)
	}

	this.mDetailsPanel.CharacterBackgroundTextScrollContainer.before(this.mCleverRecruiter.Grid);
}

CleverRecruiter.WorldTownScreenHireDialogModule_updateDetailsPanel = WorldTownScreenHireDialogModule.prototype.updateDetailsPanel;
WorldTownScreenHireDialogModule.prototype.updateDetailsPanel = function (_element)
{
	CleverRecruiter.WorldTownScreenHireDialogModule_updateDetailsPanel.call(this, _element);
	if (_element === null || _element.length == 0) return;
	var data = _element.data('entry');

	var mode = MSU.getSettingValue(CleverRecruiter.ID, "Mode");

	if (mode == "Standard")
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

	if (mode == "Standard" || mode == "Alternate" && !data['IsTryoutDone'])
	{
		for(var i = 0; i < data.Traits.length; ++i)
		{
			var icon = $('<img src="' + Path.GFX + data.Traits[i].icon + '"/>');
			icon.bindTooltip({ contentType: 'status-effect', entityId: data.ID, statusEffectId: data.Traits[i].id });
			this.mDetailsPanel.CharacterTraitsContainer.append(icon);
		}
	}

	var value;
	var talent;

	for (var i = 0; i < this.mCleverRecruiter.Properties.length; i++)
	{
		if (mode == "Standard" || mode == "Alternate" || data['IsTryoutDone'] && mode == "Lite" || (mode == "Liter" && data['IsTryoutDone'] && data.RandAttribute == i))
		{
			value = data.Properties[this.mCleverRecruiter.Properties[i].ID][0]
		}
		else
		{
			value = "?"
		}

		if (mode == "Standard" || (data['IsTryoutDone'] && (mode == "Alternate" || mode == "Lite" || (mode == "Liter" && data.RandTalent == i))))
		{
			talent = data.Properties[this.mCleverRecruiter.Properties[i].ID][2]
		}
		else
		{
			talent = 0;
		}

		this.mCleverRecruiter.Properties[i].Text.html(value + '/' + data.Properties[this.mCleverRecruiter.Properties[i].ID][1]);
		this.mCleverRecruiter.Properties[i].Talents.attr('src', Path.GFX + 'ui/icons/talent_' + talent + '.png')
	}

	if (!data['IsTryoutDone'] && data.CleverRecruiter_IsLegends && mode == "Standard")
	{
		var perkTreesImg = this.mDetailsPanel.CharacterTraitsContainer.find('img[src="' + Path.GFX + 'ui/icons/unknown_perks.png"]:first');
		perkTreesImg.attr('src', Path.GFX + 'ui/icons/known_perks.png');
		perkTreesImg.unbindTooltip();
		perkTreesImg.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldTownScreen.HireDialogModule.KnownPerks, entityId: data.ID });
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
		var traitsContainer = entry.find('.is-traits-container');
		var data = entry.data('entry');
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

		if (!data['IsTryoutDone'] && data.CleverRecruiter_IsLegends && MSU.getSettingValue(CleverRecruiter.ID, "Mode") == "Standard" )
		{
			var perkTreesImg = traitsContainer.find('img[src="' + Path.GFX + 'ui/icons/unknown_perks.png"]:first');
			perkTreesImg.attr('src', Path.GFX + 'ui/icons/known_perks.png');
			perkTreesImg.unbindTooltip();
			perkTreesImg.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldTownScreen.HireDialogModule.KnownPerks, entityId: data.ID });
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
