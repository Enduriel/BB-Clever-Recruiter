::CleverRecruiter <- {
	ID = "mod_clever_recruiter",
	Name = "Clever Recruiter",
	Version = "2.1.5",
	BaseAttributes = null,
	AlternateTraits = [
		"trait.asthmatic",
		"trait.athletic",
		"trait.cocky",
		"trait.determined",
		"trait.dexterous",
		"trait.dumb",
		"trait.eagle_eyes",
		"trait.fat",
		"trait.greedy",
		"trait.hesitant",
		"trait.huge",
		"trait.impatient",
		"trait.iron_jaw",
		"trait.night_owl",
		"trait.short_sighted",
		"trait.spartan",
		"trait.strong",
		"trait.swift",
		"trait.tiny"
	],
	Nan = "NOT_A_NUMBER",
	RealRand = null
}

::CleverRecruiter.HookMod <- ::Hooks.register(::CleverRecruiter.ID, ::CleverRecruiter.Version, ::CleverRecruiter.Name);

::CleverRecruiter.HookMod.require("mod_msu >= 1.2.0");
::CleverRecruiter.HookMod.conflictWith("mod_smart_recruiter", "mod_smart_recruiter_legends");

::CleverRecruiter.HookMod.queue(">mod_msu", ">mod_legends", ">mod_legends_PTR", function() {
	::CleverRecruiter.switcherooRandMax <- function() {
		::CleverRecruiter.RealRand = ::Math.rand;
		::Math.rand = function(_a = ::CleverRecruiter.Nan, _b = ::CleverRecruiter.Nan) {
			if (_b != ::CleverRecruiter.Nan) {
				return _b;
			}
			return ::CleverRecruiter.RealRand();
		};
	}

	::CleverRecruiter.switcherooRandMin <- function() {
		::CleverRecruiter.RealRand = ::Math.rand;
		::Math.rand = function(_a = ::CleverRecruiter.Nan, _b = ::CleverRecruiter.Nan) {
			if (_a != ::CleverRecruiter.Nan) {
				return _a;
			}
			return ::CleverRecruiter.RealRand();
		};
	}

	::CleverRecruiter.unswitcherooRand <- function() {
		::Math.rand = ::CleverRecruiter.RealRand;
		::CleverRecruiter.RealRand = null;
	}


	::Hooks.registerJS("ui/mods/clever_recruiter/world_town_screen_hire_dialog_module.js");
	::Hooks.registerCSS("ui/mods/clever_recruiter/css/world_town_screen_hire_dialog_module.css");

	::CleverRecruiter.Mod <- ::MSU.Class.Mod(::CleverRecruiter.ID, ::CleverRecruiter.Version, ::CleverRecruiter.Name);

	::CleverRecruiter.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/Enduriel/BB-Clever-Recruiter");
	::CleverRecruiter.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
	::CleverRecruiter.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/549");

	local page = ::CleverRecruiter.Mod.ModSettings.addPage("General");

	page.addEnumSetting("TraitInfo", "All", ["All", "Alternate", "None"], "Visible Traits Before Tryout", "All:\nAll recruit traits always visible\n\nAlternate:\nObvious traits visible without tryout\n\nNone:\nNo traits visible without tryout");
	page.addEnumSetting("AttributeInfoPreTryout", "Full", ["Full", "OnlyNumbers", "OnlyTalents", "Random", "None"], "Attribute Information Before Tryout", "Full:\nAll stats and stars visible before tryout\n\nOnlyNumbers:\nOnly stat numbers visible before tryout\n\nOnlyStars:\nOnly talents (stars) visible before tryout\n\nNone: Nothing visible before tryout");
	page.addRangeSetting("NumRandomStatsVisiblePreTryout", 1, 0, 8, 1, "Random Stats Visible Before Tryout", "Does nothing if 'Attribute Information Before Tryout' is not set to Random, otherwise determines the number of random stats which will be shown before tryout");
	page.addRangeSetting("NumRandomTalentsVisiblePreTryout", 1, 0, 8, 1, "Random Talents Visible Before Tryout", "Does nothing if 'Attribute Information Before Tryout' is not set to Random, otherwise determines the number of random talents which will be shown before tryout");

	page.addEnumSetting("AttributeInfoPostTryout", "Full", ["Full", "OnlyNumbers", "Random", "None"], "Attribute Information After Tryout", "Full:\nAll stars and stats visible after tryout\n\nOnlyNumbers:\nOnly stat numbers visible after tryout\n\nNone:\nNothing visibly after tryout.");
	page.addRangeSetting("NumRandomStatsVisiblePostTryout", 1, 0, 8, 1, "Random Stats Visible After Tryout", "Does nothing if 'Attribute Information After Tryout' is not set to Random, otherwise determines the number of random stats which will be shown after tryout");
	page.addRangeSetting("NumRandomTalentsVisiblePostTryout", 1, 0, 8, 1, "Random Talents Visible After Tryout", "Does nothing if 'Attribute Information After Tryout' is not set to Random, otherwise determines the number of random talents which will be shown after tryout");

	page.addBooleanSetting("Dismiss", true, "Add Dismiss Button", "Adds a dismiss button to throw a brother out of the hiring roster after you've tried them out")
	page.addRangeSetting("TryoutCostMult", 1.0, 0.0, 10.0, 0.1, "Tryout Cost Multiplier", "Sets the multiplier to use for the tryout price");
	if (::Hooks.hasMod("mod_legends"))
		page.addBooleanSetting("ShowPerkGroups", true, "Show Perk Groups", "Shows perk groups (currently only for legends) before tryout")
	page.addBooleanSetting("Dismiss", true, "Add Dismiss Button", "Adds a dismiss button to throw a brother out of the hiring roster after you've tried them out")

	page.addBooleanSetting("MaxLvlPotential", true, "Max Level Potential", "Shows the projected stats of a recruit based on their current level and the max level at which they still get full level up rewards (usually level 11)")

	::include("clever_recruiter/town_hire_dialog_module");
	::include("clever_recruiter/player");
	::include("clever_recruiter/world_state");
	::include("clever_recruiter/data_helper");
});
