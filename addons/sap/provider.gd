class_name Provider
extends RefCounted
## Provide a 'context' to descendent nodes.

static var _node_to_providers: Dictionary = {}


static func get_provider(node: Node, provider_type: GDScript):
	for provider in _node_to_providers.get(node, []):
		if provider.get_script() == provider_type:
			return provider
	return null


static func _register(node: Node, provider: Provider):
	if not _node_to_providers.has(node):
		_node_to_providers[node] = []

	_node_to_providers[node].append(provider)


func _init(node: Node):
	Provider._register(node, self)

