# objD Dungeon
The objd_dungeon package is a set of widgets that allow you to build a dungeon generator as a datapack easily by just defining some arguments in objD.
The Dungeon Widget **will** change your output files, the load function and the behavior of the game.
Nonetheless this is just an extension for my framework objD, so you are able to change the way it generates a Minecraft Datapack and add content to it.

### Getting started
Let's get started by taking a look at this dungeon that it generated with this package:
https://streamable.com/s/vaq26/wnests

We can divide this into several 'Structurepools' the pieces that make up the dungeon. 
![enter image description here](https://cdn.discordapp.com/attachments/554075979383963679/554419066807255080/2019-03-10_22.37.10.png)
We notice it is actually just 6 different types here. Some have a connection to another room, some don't.
In objd this setup looks like this:
```dart
Dungeon(
{
	"straight":  StructurePool(["straight/straight"], front: true),
	"curve":  StructurePool(["curve/curve"], mirror: true),
	"split":  StructurePool(["split/split"], left: true, right: true),
	"t":  StructurePool(["t/t"], mirror: true, front: true),
	"x":  StructurePool(["x/x"], right: true, left: true, front: true),
	"end":  StructurePool(["end/end"])
}
)
```
## Structure Pools
So in the first argument, we can define our room types and assign a StructurePool to each type.
This StructurePool is a group of structures, that get randomly chosen in the game, and a definition for the next room(s):

| StructurePool  |  |
|--|--|
| List of Strings | A list of structures(without the namespace, this can be done with the pack property) |
|front| should the structure generate a new room in front?(optional) |
|left| should the structure generate a new room on the left side?(optional) |
|right| should the structure generate a new room on the right side?(optional) |
|mirror| should the structure choose randomly between right and left and mirror the structure(you just have to build turns for example just once) |
|bias| There is a certain chance to get a StructurePool that is usually divided between all pools. With this double you can force the percentage(0.05 ⇒ 5%) | 
|path| a String that is added in front of all structures as a folder path(optional) |
|pack| the namespace where the structure files lay(default = current pack) |

That's a lot of properties, but if you consider the complexity this becomes really simple.

You can also say what size your structures are with a list of integers representing coordinates:
```dart
...
size: [21,9,21]
```
Although there is an option for the z-coordinate this generator just supports squared rooms.

The position handling and the structure loading is done by entities. So you have to define what kind of entity you want to **summon** and from where to execute functions.

In the dungeon Widget this can be done with:
**summon** - A summon Widget, Armorstand or Areaeffectcloud that should be created as new room(I encourage to use the tags `dungeon_room` as well as `dungeon_new` here)
**entity** - The entity from where to generate a room: same tags, etc. as summon but as Entity.

In code this could look like this:
```dart
...
summon: Armorstand(Location.here(),tags:["dungeon_room","dungeon_new"],gravity:false),
entity: Entity(type: EntityType.armor_stand,tags:["dungeon_room","dungeon_new"])
```

To make the Dungeon Widget functional we also need to define a pack, where it should generate.
This pack has to have a load file to generate all the scoreboards properly:
```dart
pack: Pack(name:"dungeon",load:File(path:"load")),
```

Our entire code looks like this: 
```dart
Dungeon(
  {
   "straight": StructurePool(["straight/straight"], front: true),
   "curve": StructurePool(["curve/curve"], mirror: true),
   "split": StructurePool(["split/split"],left: true, right: true),
   "t": StructurePool(["t/t"], mirror: true, front: true),
   "x": StructurePool(["x/x"], bias: 0.05, right: true, left: true, front: true),
   "end": StructurePool(["end/end"], bias: 0.05),
  },
  pack: Pack(name: "dungeon", load: File(path: "load")),
  summon: ArmorStand(
   Location.here(),
   tags: ["dungeon_room", "dungeon_new"],
   basePlate: false,
  ),
  entity: Entity(
   type: EntityType.armor_stand,
   tags: ["dungeon_room","dungeon_new"],
  ),
```
which is actually not that much. When you build the project you get a fully functioning datapack with many functions.
The most important function for you is the `generate` function.

If you run this function from an entity ingame, a random structure would appear at the entities position.
### Generate Function
The generate function can be split into 4 parts:
* **setstructure** - This part randomly chooses a StructurePool with the specified percentages depending of the open area and a random structure from that pool and sets a structureblock
* **addtags** - The entity gets some tags here defining the directions of the doors etc. (e.g. dungeon_end, dungeon_door_left...)
* **rotatestructure** - The structure is rotated and mirrored in this part to match the entities rotation and local coordinates. That way all the entrances and exists of the rooms align perfectly. The structure is also loaded.
* **summonnew** - This step summons new entities in the specified directions(front,left,right,mirror) to generate a new room.

### Start and End Pools
But this generate function is not everything. If you don't want to code the generation yourself or do it manually there is a start option and a timer that generates all new rooms every defined ticks:
```dart
start:  StructurePool(["start","start2"]),
startAndTimer:  5, 			// 5 ticks delay
```
Of course this is not infinite because the amount of entities is growing exponentially. So you can set a limit here with the iterations(default = 5).
```dart
iterations: 8,
```

And if the timer reaches this limit, you can also define an end structure pool to pick a random dead end structure:
```dart
end:  StructurePool(["end/end"]),
```

## Dungeon Widget
So to recap here are all potential properties of the Dungeon Widget:

|Dungeon|  |
|--|--|
| Map of StructurePools | name-value pairs that specify the different room types and tell the widget where to generate new rooms(required)|
|size| List of integers defining the size in each direction(default = 15x8x15) |
|pack| a Pack to generate the files into(need load file!) \| required |
|summon| an Armorstand, Areaeffectcloud or Summon Widget to create a new entity that generates a room \| required |
|entity| an Entity that should generate a room(by tag ...) \| required |
|start| a StructurePool defining the structures generated with the start function|
|startAndTimer| amount of ticks between each generation of the specified entity, set to -1 to disable the timer(default = 10) |
|iterations| how many iterations the timer passes(default = 5) |
|end| a StructurePool defining the structures that generate if the iteration limit is reached(dead end) |
|clearEntity| if specified generates a clear function that let's you clear the generated dungeon based on an Entity  | 
|afterGeneration| another Widget to execute after each generate function finished, good for removing tags etc. |

I hope this article gave you a good overview over my Dungeon extension. If you have questions or suggestions though feel free to contact me via discord: https://discord.gg/WVDFXUv or take a look at my youtube video: [here](https://youtu.be/SuLf8RINL4o)