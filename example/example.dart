// import the core of the framework:
import 'package:objd/core.dart';
// import the generator:
import 'package:objd_dungeon/generator.dart';

void main() {
  createProject(
    Project(
      name: 'Dungeon Pack',
      target: "./", // path for where to generate the project
      generate: Dungeon(
          // defining the structure pools:
          {
            "straight": StructurePool(["straight/straight"], front: true),
            "curve": StructurePool(["curve/curve"], mirror: true),
            "split": StructurePool(["split/split"], left: true, right: true),
            "t": StructurePool(["t/t"], mirror: true, front: true),
            "x": StructurePool(["x/x"],
                bias: 0.05, right: true, left: true, front: true),
            "end": StructurePool(["end/end"], bias: 0.05),
          },
          end: StructurePool(["end/end"]),
          start: StructurePool(["start"]),
          // delay between generations:
          startAndTimer: 5,
          // how often to repeat:
          iterations: 8,
          // the underlying pack:
          pack: Pack(name: "dungeon", load: File("load")),
          summon: ArmorStand(
            Location.here(),
            tags: ["dungeon_room", "dungeon_new"],
            basePlate: false,
          ),
          entity: Entity(
            type: Entities.armor_stand,
            tags: ["dungeon_room", "dungeon_new"],
          ),
          afterGeneration:
              Tag("dungeon_new", entity: Entity.Selected()).remove()),
    ),
  );
}
