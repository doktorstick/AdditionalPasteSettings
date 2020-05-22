data:extend({
	{
		type = "string-setting",
		name = "additional-paste-settings-options-requester-multiplier-type",
		setting_type = 'runtime-per-user',
		allow_blank = false,
		allowed_values = {
			"additional-paste-settings-per-stack-size",
			"additional-paste-settings-per-recipe-size",
			"additional-paste-settings-per-time-size"
		},
		default_value = "additional-paste-settings-per-recipe-size",
		order = "ba"
	},
	{
		type = "double-setting",
		name = "additional-paste-settings-options-requester-multiplier-value",
		setting_type = 'runtime-per-user',
		minimum_value = 0,
		default_value = 1,
		order = "bb"
	},
	{
		type = "int-setting",
		name = "additional-paste-settings-options-buffer-multiplier-value",
		setting_type = 'runtime-per-user',
		minimum_value = 0,
		default_value = 0,
		order = "bc"
	},
	{
		type = "string-setting",
		name = "additional-paste-settings-options-inserter-multiplier-type",
		setting_type = 'runtime-per-user',
		allow_blank = false,
		allowed_values = {
			"additional-paste-settings-per-stack-size",
			"additional-paste-settings-per-recipe-size",
			"additional-paste-settings-per-time-size"
		},
		default_value = "additional-paste-settings-per-recipe-size",
		order = "ca"
	},
	{
		type = "double-setting",
		name = "additional-paste-settings-options-inserter-multiplier-value",
		setting_type = 'runtime-per-user',
		minimum_value = 0,
		default_value = 1,
		order = "cb"
	},
	{
		type = "string-setting",
		name = "additional-paste-settings-options-combinator-multiplier-type",
		setting_type = 'runtime-per-user',
		allow_blank = false,
		allowed_values = {
			"additional-paste-settings-per-stack-size",
			"additional-paste-settings-per-recipe-size",
			"additional-paste-settings-per-time-size"
		},
		default_value = "additional-paste-settings-per-recipe-size",
		order = "da"
	},
	{
		type = "double-setting",
		name = "additional-paste-settings-options-combinator-multiplier-value",
		setting_type = 'runtime-per-user',
		minimum_value = 0,
		default_value = 1,
		order = "db"
	},
	{
		type = "bool-setting",
		name = "additional-paste-settings-options-sumup",
		setting_type = 'runtime-per-user',
		default_value = false,
		order = "a"
	},
})