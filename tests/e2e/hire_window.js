// UI half of hire_window.nut: what the hire dialog shows once the crowd building was clicked.
ClaudeProbe.run = function ()
{
	setTimeout(function ()
	{
		try
		{
			var c = $('.l-hire-dialog-container');
			var r = {
				visible: c.hasClass('display-block'),
				entries: c.find('.list-entry').length,
				hasInfo: c.find('.list-entry').map(function () { return $(this).data('entry').CleverRecruiter !== undefined; }).get(),
				grid: $('.clever-recruiter-stats-grid').length,
				icons: [],
				texts: [],
				talents: []
			};
			$('.clever-recruiter-stats-grid .stat-icon').each(function () { r.icons.push($(this).attr('src').replace(/.*\//, '')); });
			$('.clever-recruiter-stats-grid .stat-text').each(function () { r.texts.push($(this).text()); });
			$('.clever-recruiter-stats-grid .talent').each(function () { r.talents.push($(this).attr('src').replace(/.*\//, '')); });
			ClaudeProbe.send("hire", JSON.stringify(r));
		}
		catch (e) { console.error("probe: " + e); }
		ClaudeProbe.done();
	}, 9000);
};
