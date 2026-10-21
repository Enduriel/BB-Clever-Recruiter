// UI half of hire_window.nut: what the hire dialog shows once the crowd building was clicked, for each recruit.
// With --shots, also screenshots the dialog for each recruit (hire_<n>.png).
ClaudeProbe.run = function ()
{
	var report = function (_key)
	{
		var c = $('.l-hire-dialog-container');
		var r = {
			visible: c.hasClass('display-block'),
			entries: c.find('.list-entry').length,
			hasInfo: c.find('.list-entry').map(function () { return $(this).data('entry').CleverRecruiter !== undefined; }).get(),
			grid: $('.clever-recruiter-stats-grid').length,
			gridShown: $('.clever-recruiter-stats-grid').css('display'),
			icons: [],
			texts: [],
			talents: [],
			traits: c.find('.traits-container img').map(function () { return $(this).attr('src').replace(/.*\//, ''); }).get(),
			button: c.find('.details-container .text-button .label, .details-container .ui-control.button .label').map(function () { return $(this).text(); }).get()
		};
		$('.clever-recruiter-stats-grid .stat-icon').each(function () { r.icons.push($(this).attr('src').replace(/.*\//, '')); });
		$('.clever-recruiter-stats-grid .stat-text').each(function () { r.texts.push($(this).text()); });
		$('.clever-recruiter-stats-grid .talent').each(function () { r.talents.push($(this).attr('src').replace(/.*\//, '')); });
		ClaudeProbe.send(_key, JSON.stringify(r));
	};
	var entries;
	var step = function (_i)
	{
		if (_i >= entries.length)
		{
			ClaudeProbe.done();
			return;
		}
		$(entries[_i]).click();
		setTimeout(function ()
		{
			try { report("hire_" + _i); } catch (e) { console.error("probe: " + e); }
			ClaudeProbe.shot("hire_" + _i, function () { step(_i + 1); });
		}, 1000);
	};
	setTimeout(function ()
	{
		try
		{
			report("hire");
			entries = $('.l-hire-dialog-container .list-entry').filter(function () { return $(this).data('entry') !== undefined; }).get();
		}
		catch (e) { console.error("probe: " + e); entries = []; }
		step(0);
	}, 9000);
};
