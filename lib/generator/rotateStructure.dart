import 'package:objd/core.dart';
import 'package:objd_dungeon/utils/structurePool.dart';
import '../utils/changeRot.dart';

class RotateStructure extends Widget {
  List<int> size;
  Map<String, StructurePool> pools;
  RotateStructure(this.pools, {this.size = const [15, 8, 15]});

  @override
  Widget generate(Context context) {
    var mirror = Tag('dungeon_isMirrored', entity: Entity.Selected());
    var rot = Score(Entity.Selected(), 'dungeon_rotation');

    return For.of([
      If(rot.matches(1), then: [
        Data.merge(Location.here(), nbt: {'rotation': 'CLOCKWISE_90'})
      ]),
      If(rot.matches(2), then: [
        Data.merge(Location.here(), nbt: {'rotation': 'CLOCKWISE_180'})
      ]),
      If(rot.matches(3), then: [
        Data.merge(Location.here(), nbt: {'rotation': 'COUNTERCLOCKWISE_90'})
      ]),
      If(mirror, then: [
        Data.merge(Location.here(), nbt: {'mirror': 'LEFT_RIGHT'})
      ]),

      ChangeRot(rot.matches(0), mirror: mirror, z: 1, size: size),

      ChangeRot(rot.matches(1), x: 1, size: size),
      ChangeRot(rot.matches(1), mirror: mirror, x: -1, size: size),

      ChangeRot(rot.matches(2), x: 1, z: 1, size: size),
      ChangeRot(rot.matches(2), z: -1, mirror: mirror, size: size),

      ChangeRot(rot.matches(3), z: 1, size: size),
      ChangeRot(rot.matches(3), x: 1, mirror: mirror, size: size),

      // activate structure
      SetBlock(Blocks.redstone_block, location: Location.rel(x: 0, y: 1, z: 0)),

      // clear blocks
      If(
          Condition.block(Location.rel(x: 0, y: 1, z: 0),
              block: Blocks.redstone_block),
          then: [
            SetBlock(Blocks.air, location: Location.rel(x: 0, y: 1, z: 0))
          ]),
      //If(Condition.block(Location.here(),block:Blocks.structure_block),then:[SetBlock(Blocks.air,location:Location.here())]),
    ]);
  }
}
