# SAP

SAP (Scene Access Provider) is an extremely lightweight dependency injection plugin for Godot / GDScript. SAP implements the [provider pattern](https://www.patterns.dev/vanilla/provider-pattern/), allowing you to define *providers* and have them inject themselves into *dependent* nodes by walking up the scene tree.

For C# users, consider ChickenSoft's excellent [AutoInject](https://github.com/chickensoft-games/AutoInject) package instead.

## Usage

Suppose we have a node-based state machine that requires access to a parent node. For example:

```
- Player (player.tscn)
  - PlayerController (player_controller.tscn)
    - StateMachine
      - Grounded
```

Here, the `Grounded` node might need access to the player to trigger animations, etc. We could make the player available through a series of `@export` variables, which wouldn't be too bad in this case - but what if the nodes are more deeply nested? React solves this problem with [context](https://react.dev/learn/passing-data-deeply-with-context) - and SAP provides a similar solution (although much simpler, more lightweight and less feature-complete).

### 1. Define a Provider

First we must define the provider and the data it contains:
```gdscript
# player_context.gd

class_name PlayerContext
extends Provider

var player: Player

func _init(node: Node):
  super(node)
  player = node
```

...and attach this provider to the player:
```gdscript
# player.gd
var context = PlayerContext.new(self)
```

### 2. Setup the dependency

Now, in the `Grounded` state script, we can set up the dependency.

```gdscript
# grounded.gd

var player_dependency = Dependency.new(PlayerContext, self, _setup_player)
var player: Player

func _setup_player(context: PlayerContext):
  if not context:
    # If no node is found providing the `PlayerContext`, this callback will still fire,
    #   but `context` will be null. This is useful for setting up default fallback values.
    return

  player = context.player
```

...and that's it! By creating the Dependency this way, SAP knows to walk up the scene tree looking for a node that provides the `PlayerContext`. When one is found, it will register the `Grounded` node as a dependent.

- If the provider node is already `ready`, the `_setup_player` function will immediately be called with the found context.
- If the provider node is not `ready`, the `_setup_player` function will be called once it has finished readying.
- If no provider node is found, the `_setup_player` function will immediately be called with `null`.

## Installation

If you're using [GodotEnv](https://github.com/chickensoft-games/GodotEnv) to manage your addons & godot installations, simply add this to your `addons.jsonc` file:

```json
"sap": {
  "url": "https://github.com/DillonSteyl/sap.git",
  "subfolder": "addons/sap"
}
```
and then run `godotenv addons install`.

Otherwise, see the Godot docs for other installation methods: [Installing Plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).
