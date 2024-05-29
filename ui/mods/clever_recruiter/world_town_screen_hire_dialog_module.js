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
		if (!MSU.getSettingValue(CleverRecruiter.ID, "Dismiss") || !self.mSelectedEntry.data('entry').IsTryoutDone)
			return;
		_event.stopImmediatePropagation();
		self.CleverRecruiter_dimissSelectedEntry();
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
	for (var i = 0; i < this.mCleverRecruiter.Properties.length; i++)
	{
		if (i % 2 == 0)
		{
			row = $('<div class="stat-row"/>');
			this.mCleverRecruiter.Grid.append(row);
		}
		var container = $('<div class="stat-container"/>');
		row.append(container)
		var iconStarsColumn = $('<div class="icon-stars-column"/>');
		container.append(iconStarsColumn);
		iconStarsColumn.append($('<img class="stat-icon" src="' + Path.GFX + this.mCleverRecruiter.Properties[i].IconAsset + '"/>'));
		this.mCleverRecruiter.Properties[i].Talents = $('<img class="talent" src="' + Path.GFX + 'ui/icons/talent_0.png"/>');
		iconStarsColumn.append(this.mCleverRecruiter.Properties[i].Talents);
		this.mCleverRecruiter.Properties[i].Text = $('<div class="stat-text"/>');
		container.append(this.mCleverRecruiter.Properties[i].Text);
	}

	this.mDetailsPanel.CharacterBackgroundTextScrollContainer.before(this.mCleverRecruiter.Grid);
}

CleverRecruiter.WorldTownScreenHireDialogModule_updateDetailsPanel = WorldTownScreenHireDialogModule.prototype.updateDetailsPanel;
WorldTownScreenHireDialogModule.prototype.updateDetailsPanel = function (_element)
{
	CleverRecruiter.WorldTownScreenHireDialogModule_updateDetailsPanel.call(this, _element);
	if (_element === null || _element.length == 0) return;
	var data = _element.data('entry');

	if (data.IsTryoutDone)
	{
		if (MSU.getSettingValue(CleverRecruiter.ID, "Dismiss"))
		{
			this.mDetailsPanel.TryoutButton.addClass('display-block').removeClass('display-none');
			this.mDetailsPanel.TryoutButton.findButtonText().html("Dismiss");
			this.mDetailsPanel.TryoutButton.enableButton(true);
		}
		else
		{
			this.mDetailsPanel.TryoutButton.findButtonText().html("Try out");
		}
	}
	else
	{
		this.mDetailsPanel.TryoutButton.findButtonText().html("Try out");
		if (MSU.getSettingValue(CleverRecruiter.ID, "TraitInfo") == "All")
		{
			var icon = this.mDetailsPanel.CharacterTraitsContainer.find('[src="' + Path.GFX + Asset.ICON_UNKNOWN_TRAITS + '"]').filter(':first')
			icon.unbindTooltip();
			icon.remove();
		}
		if (data.CleverRecruiter_IsLegends && MSU.getSettingValue(CleverRecruiter.ID, "ShowPerkGroups"))
		{
			var perkTreesImg = this.mDetailsPanel.CharacterTraitsContainer.find('img[src="' + Path.GFX + 'ui/icons/unknown_perks.png"]').filter(':first');
			perkTreesImg.attr('src', Path.GFX + 'ui/icons/known_perks.png');
			perkTreesImg.unbindTooltip();
			perkTreesImg.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldTownScreen.HireDialogModule.KnownPerks, entityId: data.ID });
		}
	}

	for (var i = 0; i < data.CleverRecruiter.Traits.length; ++i)
	{
		var icon = $('<img src="' + Path.GFX + data.CleverRecruiter.Traits[i].icon + '"/>');
		icon.bindTooltip({ contentType: 'status-effect', entityId: data.ID, statusEffectId: data.CleverRecruiter.Traits[i].id });
		this.mDetailsPanel.CharacterTraitsContainer.append(icon);
	}

	for (var i = 0; i < data.CleverRecruiter.Attributes.length; ++i)
	{
		var values = data.CleverRecruiter.Attributes[i]
		var text = (values[0] == null ? '??' : values[0]) + '/' + values[1];
		this.mCleverRecruiter.Properties[i].Talents.attr('src', Path.GFX + 'ui/icons/talent_' + values[2] + '.png')
		if (values[3] != null) // level 11 projections
		{
			text += '→' + (values[3].Min == values[3].Max ? values[3].Mean : '~' + values[3].Mean);
		}
		this.mCleverRecruiter.Properties[i].Text.text(text);
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

		if (data.IsTryoutDone)
			return;

		if (MSU.getSettingValue(CleverRecruiter.ID, "TraitInfo") == "All")
		{
			var icon = traitsContainer.find('[src="' + Path.GFX + Asset.ICON_UNKNOWN_TRAITS + '"]').filter(':first')
			icon.unbindTooltip();
			icon.remove();
		}

		for (var i = 0; i < data.CleverRecruiter.Traits.length; ++i)
		{
			var icon = $('<img src="' + Path.GFX + data.CleverRecruiter.Traits[i].icon + '"/>');
			icon.bindTooltip({ contentType: 'status-effect', entityId: data.ID, statusEffectId: data.CleverRecruiter.Traits[i].id });
			traitsContainer.append(icon);
		}

		if (data.CleverRecruiter.Legends && MSU.getSettingValue(CleverRecruiter.ID, "ShowPerkGroups"))
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
			this.CleverRecruiter_notifyBackendDismissRosterEntity(data['ID'], function (_data)
			{
				if (_data.Result != 0)
				{
					console.error("Failed to hire. Reason: Unknown");
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

WorldTownScreenHireDialogModule.prototype.CleverRecruiter_notifyBackendDismissRosterEntity = function(_entityID, _callback)
{
	SQ.call(this.mSQHandle, "CleverRecruiter_onDismissRosterEntity", _entityID, _callback);
}
