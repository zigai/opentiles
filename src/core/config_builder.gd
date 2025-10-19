class_name ConfigBuilder
extends RefCounted


# --------------------------------------------------------------------------------------------------

static func create(descriptor: Variant, overrides: Dictionary) -> ModeConfig:
	if descriptor == null:
		push_error("ConfigBuilder: descriptor is null")
		return null
	
	var config: ModeConfig = descriptor.default_config.copy()
	if config == null:
		return null
	
	if overrides == null:
		return config

	var fields: Dictionary = {}
	for f in descriptor.settings_schema:
		fields[f.key] = f

	for key in overrides.keys():
		if not fields.has(key):
			continue

		var field = fields[key]
		var value = overrides[key]

		if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
			var minv = field.min
			var maxv = field.max if field.max > 0 else value
			if typeof(value) == TYPE_INT:
				value = int(clamp(value, int(minv), int(maxv)))
			else:
				value = float(clamp(value, float(minv), float(maxv)))

	config.set(key, value)
	return config
