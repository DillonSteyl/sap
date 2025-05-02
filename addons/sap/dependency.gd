class_name Dependency
extends RefCounted
## Registers a node as dependent of a specific provider type.

signal resolved

var is_resolved: bool = false


class ProviderResult:
	var node: Node
	var provider: Provider

	func _init(p_node: Node, p_provider: Provider) -> void:
		node = p_node
		provider = p_provider


## Constructs a node that's dependent on the given provider type
## e.g. Dependency.new(ApplicationContext)
func _init(
	provider_script: GDScript,
	node: Node,
	callback: Callable,
	is_strict: bool = false,
) -> void:
	var provider_result = _search_ancestors_for_provider(node, provider_script)
	if not provider_result:
		if is_strict:
			push_error(
				"{node} dependency on {provider_script} cannot be met.".format(
					{"node": node.name, "provider_script": provider_script.get_global_name()}
				)
			)
			node.get_tree().quit()
			return

		_resolve(callback, null)
		return

	provider_result = provider_result as ProviderResult
	if not provider_result.node.is_node_ready():
		provider_result.node.ready.connect(_resolve.bind(callback, provider_result.provider))
		return

	_resolve(callback, provider_result.provider)


## Search ancestors for provider matching the `provider_script` type.
func _search_ancestors_for_provider(node: Node, provider_script: GDScript):
	var tree_root = node.get_tree().root
	while node != tree_root:
		var provider = Provider.get_provider(node, provider_script)
		if provider:
			return ProviderResult.new(node, provider)

		node = node.get_parent()
	return null


func _resolve(callback: Callable, provider):
	callback.call(provider)
	is_resolved = true
	resolved.emit()
