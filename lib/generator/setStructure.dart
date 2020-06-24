import 'package:meta/meta.dart';
import 'package:objd/core.dart';
import 'package:objd_dungeon/utils/structurePool.dart';
import '../utils/matchRange.dart';
import '../utils/randomStructure.dart';

class SetStructure extends Widget {
  List<int> size;
  Entity entity;
  Map<String, StructurePool> pools;
  SetStructure(
    this.pools, {
    this.size = const [15, 8, 15],
    @required this.entity,
  });

  @override
  Widget generate(Context context) {
    var tag = Tag('dungeon_isblocked', entity: Entity.Self());

    return For.of([
      tag.remove(),
      If(
          Condition.not(
              Score(Entity.Self(), 'dungeon_type').matchesRange(Range(0, 100))),
          then: [
            RandomScore(Entity.Self(), to: 100, targetFileName: 'random'),
            Score(Entity.Self(), 'dungeon_type')
                .setEqual(Score(Entity.Self(), 'objd_random')),
          ]),
      // set structure block
      For(
          to: pools.length - 1,
          create: (i) {
            var pool = pools.values.toList()[i];
            return MatchRange(
              pool.range,
              File.execute(
                'setstruct/' + pools.keys.toList()[i],
                child: RandomStructure(pool.getStructures(context), size: size),
              ),
            );
          }),
      // test for available space
      For(
          to: pools.length - 1,
          create: (i) {
            var pool = pools.values.toList()[i];
            if (pool.mirror != null && pool.mirror) {
              return For.of([
                _matchRangeAndSpace(pool.mirroredRange1,
                    front: pool.front, right: false, left: true),
                _matchRangeAndSpace(pool.mirroredRange2,
                    front: pool.front, right: true, left: false)
              ]);
            }
            return _matchRangeAndSpace(pool.range,
                front: pool.front, right: pool.right, left: pool.left);
          }),
      // if space blocked repeat
      If(tag, then: [
        Score(Entity.Self(), 'dungeon_type').add(15),
        File.recursive()
      ]),
    ]);
  }

  Widget _matchRangeAndSpace(
    Range range, {
    bool front = false,
    bool left = false,
    bool right = false,
  }) {
    var conds = <Widget>[];
    var tag = Entity.Self().addTag('dungeon_isblocked');
    var ent = If(
      Entity(
          type: entity.arguments['type'] == null
              ? Entities.armor_stand
              : EntityType(entity.arguments['type'] as String),
          distance: Range.to(1)),
      then: [tag],
    );

    if (front != null && front) {
      conds.add(
        Execute.positioned(
          Location.local(x: 0, y: 0, z: size[2].toDouble()),
          children: [ent],
        ),
      );
    }
    if (left != null && left) {
      conds.add(
        Execute.positioned(
          Location.local(x: size[0].toDouble(), y: 0, z: 0),
          children: [ent],
        ),
      );
    }
    if (right != null && right) {
      conds.add(
        Execute.positioned(
          Location.local(x: -size[0].toDouble(), y: 0, z: 0),
          children: [ent],
        ),
      );
    }
    return MatchRange(range, conds);
  }
}
