# godot-voxel_line <a href="/addons/voxel_line/voxel_line.png?raw=true"><img width=24 src="/addons/voxel_line/voxel_line.png"></a> 
A Simple plugin for creating voxel lines. (WIP)


<a href="Screenshot 2023-04-11 123609.png?raw=true"><img width=1024 src="Screenshot 2023-04-11 123609.png"></a>

## Example:

``` gdscript
var node : VoxelLine = VoxelLine.new()
add_child(node)

...

node.voxel_line(Vector3(0, 0, 0), Vector3(0, 8, 16), 1.0, Color.CYAN)

```

## Notes:
Currently you can toggle between using a multimesh instance or not (for testing) but i will eventually remove that along with old code as its not needed. 

## TODO:

- Materials.
- Multiple Lines (Editor).
- Editor Parameters.
