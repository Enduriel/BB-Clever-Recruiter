::CleverRecruiter <- {
	ID = "mod_clever_recruiter",
	Name = "Clever Recruiter",
	Version = "1.0.0",
	BaseProperties = null
}

::CleverRecruiter.HookMod <- ::Hooks.register(::CleverRecruiter.ID, ::CleverRecruiter.Version, ::CleverRecruiter.Name);

::CleverRecruiter.HookMod.require("mod_msu >= 1.2.0");
::CleverRecruiter.HookMod.conflictWith("mod_smart_recruiter", "mod_smart_recruiter_legends");

::CleverRecruiter.HookMod.queue(">mod_legends", ">mod_legends_PTR", function() {
	::Hooks.registerJS("ui/mods/clever_recruiter/world_town_screen_hire_dialog_module.js");
	::Hooks.registerCSS("ui/mods/clever_recruiter/css/world_town_screen_hire_dialog_module.css");

	::CleverRecruiter.Mod <- ::MSU.Class.Mod(::CleverRecruiter.ID, ::CleverRecruiter.Version, ::CleverRecruiter.Name);

	::CleverRecruiter.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/Enduriel/BB-Clever-Recruiter");
	::CleverRecruiter.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
	::CleverRecruiter.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/549");

	local page = ::CleverRecruiter.Mod.ModSettings.addPage("Main");
	page.addEnumSetting("Mode", "Standard", ["Standard", "Alternate", "Lite", "Liter", "Talents"], null, "Standard:\nAll recruit info always visible\n\nAlternate:\nObvious traits visible, attributes visible. Try out shows remaining traits and all talents\n\nLite:\nNothing is normally visible. Try out shows all info.\n\nLiter:\nNothing is normally visible. Try out shows 1 attribute and 1 talent\n\nTalents:\nNothing is normally visible, tryout reveals all talents");
	page.addBooleanSetting("Dismiss", true, "Add Dismiss Button", "Adds a dismiss button to throw a brother out of the hiring roster after you've tried them out (does nothing in Standard mode)")

	::include("clever_recruiter/town_hire_dialog_module");
	::include("clever_recruiter/world_state");
	::include("clever_recruiter/data_helper");
})
