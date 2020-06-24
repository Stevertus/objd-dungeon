import 'package:meta/meta.dart';
import 'package:objd/core.dart';
import 'package:objd_dungeon/utils/structurePool.dart';

import '../utils/matchRange.dart';

class CreateNew extends Widget {
  List<int> size;
  Map<String, StructurePool> pools;

  Widget summon;
  Entity entity;

  Widget after;

  CreateNew(this.pools,
      {@required this.summon,
      this.after,
      @required this.entity,
      this.size = const [15, 8, 15]}) {
    if (summon == null ||
        !(summon is Summon ||
            summon is ArmorStand ||
            summon is AreaEffectCloud)) throw ('You need a summon widget');
    if (entity == null) {
      throw ('Please define an entity on which you want to apply generation');
    }
  }

  @override
  Widget generate(Context context) {
    return For.of([
      For(
          to: pools.length - 1,
          create: (i) {
            var pool = pools.values.toList()[i];
            if (pool.mirror != null && pool.mirror) {
              return For.of([
                _createRoom(pool.mirroredRange1,
                    front: pool.front, right: false, left: true),
                _createRoom(pool.mirroredRange2,
                    front: pool.front, right: true, left: false)
              ]);
            }
            return _createRoom(pool.range,
                front: pool.front, right: pool.right, left: pool.left);
          }),
      if (after != null) after,
      Score(Entity.Self(), 'dungeon_type').reset(),
      Entity.Self().removeTag('dungeon_new')
    ]);
  }

  Widget _createRoom(Range range,
      {bool front = false, bool left = false, bool right = false}) {
    var rooms = <_NewRoom>[];
    if (front != null && front) {
      rooms.add(_NewRoom(
        Location.local(x: 0, y: 0, z: size[0].toDouble()),
        entity: entity,
        summon: summon,
      ));
    }
    if (left != null && left) {
      rooms.add(_NewRoom(
        Location.local(x: size[0].toDouble(), y: 0, z: 0),
        entity: entity,
        summon: summon,
      ));
    }
    if (right != null && right) {
      rooms.add(_NewRoom(
        Location.local(x: -size[0].toDouble(), y: 0, z: 0),
        entity: entity,
        summon: summon,
      ));
    }
    return MatchRange(range, rooms);
  }
}

class _NewRoom extends Widget {
  Location loc;
  Widget summon;
  Entity entity;

  _NewRoom(this.loc, {this.entity, this.summon});

  @override
  Widget generate(Context context) {
    final s = Scoreboard('dungeon_iter');

    entity.arguments['distance'] = '..1';
    return Execute(location: loc, targetFileName: 'summonroom', children: [
      summon,
      Teleport(entity, to: Location.here(), facing: Entity.Self()),
      entity.addTag('dungeon_created_now'),
      If(
        Condition.not(
          s[Entity.Self()] < 1000,
        ),
        then: [
          s[Entity.Self()] >> 0,
        ],
      ),
      s[entity] >> s[Entity.Self()],
      s[entity] + 1,
    ]);
  }
}
