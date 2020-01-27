import 'package:objd/core.dart';
import 'package:objd_dungeon/utils/structurePool.dart';

import '../utils/matchRange.dart';

class AddStructureTags extends Widget {
  Map<String, StructurePool> pools;

  AddStructureTags(this.pools);

  @override
  Widget generate(Context context) {
    var mirror = Tag('dungeon_isMirrored', entity: Entity.Selected());
    var rot = Score(Entity.Selected(), 'dungeon_rotation');

    return For.of([
      mirror.remove(),
      rot.set(0),
      // add mirrored tag for each mirrored pool
      For(
          to: pools.length - 1,
          create: (i) {
            var pool = pools.values.toList()[i];
            if (pool.mirror != null && pool.mirror) {
              return MatchRange(
                pool.mirroredRange2,
                mirror.add(),
              );
            }

            return null;
          }),
      // save rotation to score
      If(Entity.Selected(horizontalRotation: Range(from: -10, to: 10)),
          then: [rot.set(1)]),
      If(Entity.Selected(horizontalRotation: Range(from: 80, to: 110)),
          then: [rot.set(2)]),
      If(Entity.Selected(horizontalRotation: Range(from: 170, to: -170)),
          then: [rot.set(3)]),
      If(rot.matchesRange(Range(from: 4)), then: [rot.subtract(4)]),

      For(
          to: pools.length - 1,
          create: (i) {
            var pool = pools.values.toList()[i];
            if (pool.mirror != null && pool.mirror) {
              return For.of([
                _matchRangeAddTag(pool.mirroredRange1,
                    front: pool.front, right: false, left: true),
                _matchRangeAddTag(pool.mirroredRange2,
                    front: pool.front, right: true, left: false)
              ]);
            }
            return _matchRangeAddTag(pool.range,
                front: pool.front, right: pool.right, left: pool.left);
          }),
    ]);
  }
}

Widget _matchRangeAddTag(Range range,
    {bool left = false, bool right = false, bool front = false}) {
  var isLeft = Tag('dungeon_door_left', entity: Entity.Selected()).add();
  var isRight = Tag('dungeon_door_right', entity: Entity.Selected()).add();
  var isFront = Tag('dungeon_door_front', entity: Entity.Selected()).add();
  var isEnd = Tag('dungeon_end', entity: Entity.Selected()).add();

  var tags = <Tag>[];

  if (left != null && left) tags.add(isLeft);
  if (right != null && right) tags.add(isRight);
  if (front != null && front) tags.add(isFront);
  if (tags.isEmpty) tags = [isEnd];

  return MatchRange(range, tags);
}
