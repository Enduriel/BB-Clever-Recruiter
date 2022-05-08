::CleverRecruiter <- {
	ID = "mod_clever_recruiter",
	Name = "Clever Recruiter",
	Version = "1.0.0-beta",
	BaseProperties = null
}

::mods_registerMod(::CleverRecruiter.ID, ::CleverRecruiter.Version, ::CleverRecruiter.Name);

::mods_queue(null, "mod_msu(>=1.0.0-beta), !mod_smart_recruiter, !mod_smart_recruiter_legends, >mod_legends", function()
{
	::mods_registerJS("clever_recruiter/world_town_screen_hire_dialog_module.js")
	::mods_registerCSS("clever_recruiter/css/world_town_screen_hire_dialog_module.css")

	::CleverRecruiter.Mod <- ::MSU.Class.Mod(::CleverRecruiter.ID, ::CleverRecruiter.Version, ::CleverRecruiter.Name);

	local page = ::CleverRecruiter.Mod.ModSettings.addPage("Main");
	page.addEnumSetting("Mode", "Standard", ["Standard", "Alternate", "Lite", "Liter"], null, "Standard:\ndefault\n\nAlternate:\nBasic info always visible\n\nLite:\nRequires tryout");
	page.addBooleanSetting("Dismiss", true, "Add Dismiss Button", "Adds a dismiss button to throw a brother out of the hiring roster after you've tried them out (does nothing in Standard mode)")

	::include("clever_recruiter/town_hire_dialog_module");
	::include("clever_recruiter/world_state");
	::include("clever_recruiter/data_helper");
});
