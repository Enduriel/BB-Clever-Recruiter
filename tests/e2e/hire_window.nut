// Reproduces: the hire window not opening / no stats on hire (bug #1010213, comments #155992474, #162492781), the
// attribute display order (#146915046, #146718021), and with Legends the shown maximum below the current value
// (#150429053) and the traits row after tryout (#175647060).
// Mods: Modern Hooks, MSU, Clever Recruiter; optionally Reforged and its requirements, or Legends 19.4.22 + its assets.
// Mode: campaign, with --js hire_window.js (and --shots DIR --size 2560x1440 for a screenshot per recruit).
// "potentials match attributes" checks against the vanilla level up formula, so it lists mismatches with mods that
// change level ups (Reforged); Clever Recruiter itself runs the loaded fillAttributeLevelUpValues.
//
// A passing run prints, among others:
//   PROBE BaseAttributes keys = [Hitpoints,MeleeSkill,Stamina,RangedSkill,Bravery,MeleeDefense,Initiative,RangedDefense]
//   PROBE potentials match attributes = ok
//   PROBE current above shown max = none
//   PROBE RealRand (should be null) = (null : 0x00000000)
//   PROBE hire data = n=N ...                       (no ERROR)
//   PROBE edge levelUpsSpent=10 = [...]             (no THROWS; potentials equal the current values)
//   PROBE click crowd = ok
// plus one logged error "Clever Recruiter: failed to get the hire information for ..." for the recruit broken on purpose.
// From JS: "visible":true, "hasInfo" false only for that recruit, eight "texts" like "59/60»59" for the first one, and
// for the tried out recruit no talent stars (health.png, talent_N.png) in "traits".
::ClaudeProbe.str <- function( _v, _d = 0 )
{
	if (_d > 4) return "...";
	switch (typeof _v)
	{
		case "array":
			local s = "[";
			foreach (i, e in _v) s += (i ? "," : "") + ::ClaudeProbe.str(e, _d + 1);
			return s + "]";
		case "table":
			local keys = [];
			foreach (k, e in _v) keys.push(k);
			keys.sort();
			local s = "{";
			foreach (k in keys) s += k + "=" + ::ClaudeProbe.str(_v[k], _d + 1) + " ";
			return s + "}";
		default:
			return "" + _v;
	}
}
local str = ::ClaudeProbe.str;
local function p( k, f )
{
	local v;
	try { v = f(); } catch (e) { v = "ERROR: " + e; }
	::logInfo("PROBE " + k + " = " + v);
}
local function randSample()
{
	local s = "";
	for (local i = 0; i < 12; i++) s += ::Math.rand(1, 100) + ",";
	return s;
}

::ClaudeProbe.DeferDone = true;
p("CR version", @() ::CleverRecruiter.Version);
p("MSU version", @() ::MSU.Version);
p("hasMod reforged", @() ::Hooks.hasMod("mod_reforged"));
// Players' persisted settings are loaded too: pin the ones that change what is shown.
p("settings", function() {
	foreach (id, v in { TraitInfo = "All", AttributeInfoPreTryout = "Full", MaxLvlPotential = true })
		::CleverRecruiter.Mod.ModSettings.getSetting(id).set(v);
	return "ok";
});

// world_state.init() runs inside world_state.onInit(), before Clever Recruiter's onInit hook finishes:
// check everything once the state is fully up.
::Time.scheduleEvent(::TimeUnit.Real, 2000, function(_d) {
	p("BaseAttributes keys", @() str(::CleverRecruiter.BaseAttributes.keys()));
	p("BaseAttributes", @() str(::CleverRecruiter.BaseAttributes.toTable()));
	p("RealRand (should be null)", @() ::CleverRecruiter.RealRand);
	p("rand not stuck", function() { local a = randSample(); local b = randSample(); return a != b; });

	local town = null;
	foreach (s in ::World.EntityManager.getSettlements())
	{
		if (s.isEnterable() && s.getBuilding("building.crowd") != null) { town = s; break; }
	}
	::ClaudeProbe.Town <- town;
	p("town found", @() town != null);
	::Math.seedRandom(1234);
	p("updateRoster", function() { town.updateRoster(true); return ::World.getRoster(town.getID()).getSize() > 0; });
	p("hire data", function() {
		local r = ::UIDataHelper.convertHireRosterToUIData(town.getID());
		local s = "n=" + r.len();
		foreach (e in r)
			s += " | lvl" + e.Level + " CR=" + str(e.CleverRecruiter);
		return s;
	});
	p("recruits", function() {
		local s = "";
		foreach (b in ::World.getRoster(town.getID()).getAll())
			s += "lvl=" + b.getLevel() + " LUS=" + b.m.LevelUpsSpent + " talents=" + str(b.getTalents()) + "; ";
		return s;
	});
	// The potentials must belong to the attribute they're shown next to, whatever the display order.
	p("potentials match attributes", function() {
		local bad = [];
		local keys = ::CleverRecruiter.BaseAttributes.keys();
		foreach (b in ::World.getRoster(town.getID()).getAll())
		{
			local info = ::UIDataHelper.convertEntityHireInformationToUIData(b).CleverRecruiter.Attributes;
			local n = ::Const.XP.MaxLevelWithPerkpoints - 1 - b.m.LevelUpsSpent;
			foreach (i, id in keys)
			{
				local a = ::Const.Attributes[id == "Stamina" ? "Fatigue" : id];
				local t = b.getTalents()[a];
				local min = b.getBaseProperties()[id] + n * (::Const.AttributesLevelUp[a].Min + (t == 3 ? 2 : t));
				local max = b.getBaseProperties()[id] + n * (::Const.AttributesLevelUp[a].Max + (t == 3 ? 1 : 0));
				if (info[i][0] != b.getBaseProperties()[id] || info[i][2] != t || info[i][3].Min != min || info[i][3].Max != max)
					bad.push(id + ":" + str(info[i]) + " expected " + min + "-" + max);
			}
		}
		return bad.len() == 0 ? "ok" : str(bad);
	});
	// The shown maximum of a stat can never be below what the recruit has (#150429053, Legends).
	p("current above shown max", function() {
		local bad = [];
		local keys = ::CleverRecruiter.BaseAttributes.keys();
		foreach (b in ::World.getRoster(town.getID()).getAll())
		{
			local info = ::UIDataHelper.convertEntityHireInformationToUIData(b).CleverRecruiter.Attributes;
			foreach (i, id in keys)
			{
				if (b.getBaseProperties()[id] > info[i][1])
					bad.push(b.getBackground().getID() + " " + id + " " + b.getBaseProperties()[id] + ">" + info[i][1]);
			}
		}
		return bad.len() == 0 ? "none" : str(bad);
	});
	// A recruit with no level ups left before the max level (e.g. a high level veteran).
	p("edge levelUpsSpent=10", function() {
		local b = ::World.getRoster(town.getID()).getAll()[0];
		local old = b.m.LevelUpsSpent;
		b.m.LevelUpsSpent = 10;
		local ret;
		try { ret = str(::UIDataHelper.convertEntityHireInformationToUIData(b).CleverRecruiter.Attributes); }
		catch (e) { ret = "THROWS: " + e; }
		b.m.LevelUpsSpent = old;
		return ret;
	});
	p("RealRand after edge (should be null)", @() ::CleverRecruiter.RealRand);
	p("rand not stuck after edge", function() { local a = randSample(); local b = randSample(); return a != b; });

	// Open the town and click the crowd building, as the player would.
	p("menu stack had backsteps", function() {
		local had = ::World.State.m.MenuStack.hasBacksteps();
		if (had) ::World.State.m.MenuStack.popAll(true);
		return had;
	});
	// The first recruit has no level ups left, the last one can't be handled at all (no talents): the window must
	// still open, with the last recruit falling back to the vanilla display.
	p("break recruits", function() {
		local all = ::World.getRoster(town.getID()).getAll();
		all[0].m.LevelUpsSpent = 10;
		all[all.len() - 1].m.Talents = [];
		if (all.len() > 2) all[1].setTryoutDone(true); // to see how a tried out recruit looks
		return all.len();
	});
	p("enterLocation", @() ::World.State.enterLocation(town));
	::Time.scheduleEvent(::TimeUnit.Real, 2500, function(_d) {
		p("town screen visible", @() ::World.State.getTownScreen().isVisible());
		p("click crowd", function() { ::ClaudeProbe.Town.getBuilding("building.crowd").onClicked(::World.State.getTownScreen()); return "ok"; });
	}, null);
}, null);
