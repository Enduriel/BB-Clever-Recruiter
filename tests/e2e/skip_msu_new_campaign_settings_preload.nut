// --preload for campaign-mode runs with a mod that adds MSU new-campaign settings (e.g. Legends): MSU then shows its
// settings screen from campaign_menu_module_onStartPressed instead of starting the campaign, which the harness can't
// click through (the screen isn't connected yet when the harness starts the campaign). Pretend it was already shown,
// so the campaign starts with the settings' defaults.
::ClaudeProbe.Mod.queue(">mod_msu", function() {
	::ClaudeProbe.Mod.hook("scripts/states/main_menu_state", function(q) {
		q.campaign_menu_module_onStartPressed = @(__original) function( _settings ) {
			this.m.ModSettingsShown = true;
			__original(_settings);
		}
	});
});
