data:extend({
	{
		type = "string-setting",
		name = "additional-paste-settings-options-requester-multiplier-type",
		setting_type = 'runtime-per-user',
		allow_blank = false,
		allowed_values = {
			"additional-paste-settings-per-stack-size",
			"additional-paste-settings-per-recipe-size"
		},
		default_value = "additional-paste-settings-per-recipe-size"
	},
	{
		type = "double-setting",
		name = "additional-paste-settings-options-requester-multiplier-value",
		setting_type = 'runtime-per-user',
		minimum_value = 0,
		default_value = 1
	},
	{
		type = "double-setting",
		name = "additional-paste-settings-options-inserter-multiplier-value",
		setting_type = 'runtime-per-user',
		minimum_value = 0,
		default_value = 1
	}
})