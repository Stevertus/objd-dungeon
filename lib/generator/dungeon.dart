import 'package:meta/meta.dart';
import 'package:objd/core.dart';
import 'package:objd_dungeon/utils/structurePool.dart';

import '../utils/randomStructure.dart';
import 'createNew.dart';
import 'addTags.dart';
import 'rotateStructure.dart';
import 'setStructure.dart';

class Dungeon extends Widget {
  Map<String, StructurePool> pools;
  Pack pack;
  List<int> size;
  int iterations;
  StructurePool start;
  int startAndTimer;
  StructurePool end;
  Widget afterGeneration;
  Widget summon;
  Entity entity;

  Dungeon(
    this.pools, {
    @required this.pack,
    this.size = const [15, 8, 15],
    Entity clearEntity,
    this.afterGeneration,
    @required this.entity,
    @required this.summon,
    this.start,
    this.end,
    this.startAndTimer = 10,
    this.iterations = 5,
  }) {
    _computePool();
    pack.files ??= [];
    if (clearEntity != null) {
      var x = (size[0] - 1) / 2;
      var z = (size[2] - 1) / 2;
      pack.files.add(
        File(
          'clear',
          child: Execute.asat(
            clearEntity,
            children: [
              Fill(
                Blocks.air,
                area: Area.fromLocations(
                  Location.rel(x: -x, z: -z),
                  Location.rel(x: x, y: size[1].toDouble(), z: z),
                ),
              ),
              Kill(
                Entity.Self(),
              )
            ],
          ),
        ),
      );
    }
  }

  void _computePool() {
    var perc = 100;
    var currentLowest = 0;
    var length = pools.length;
    // split the remaining percent
    pools.values.forEach((pool) {
      if (pool.bias != null) perc -= pool.bias;
      if (pool.mirror != null && pool.mirror) length++;
    });
    if (perc < 0) perc = 0;
    var average = (perc ~/ length);
    pools.values.forEach((pool) {
      var adding = average;
      if (pool.bias != null) adding = pool.bias;
      if (pool.mirror != null && pool.mirror) {
        pool.range = Range(currentLowest, currentLowest + 2 * adding - 1);
        pool.mirroredRange1 = Range(currentLowest, currentLowest + adding - 1);
        currentLowest += adding;
        pool.mirroredRange2 = Range(currentLowest, currentLowest + adding - 1);
      } else {
        pool.range = Range(currentLowest, currentLowest + adding - 1);
      }
      if (pool.range.to >= 99) pool.range.to = 100;
      currentLowest += adding;
    });
  }

  @override
  Widget generate(Context context) {
    pack.files.add(
      File(
        'generate',
        child: For.of([
          Score(Entity.Self(), 'dungeon_type').reset(),
          If(
            Condition.not(Score(Entity.Self(), 'dungeon_iter')
                .matchesRange(Range.from(iterations - 1))),
            then: [
              File.execute('setstructure',
                  child: SetStructure(pools, size: size, entity: entity))
            ],
          ),
          end != null
              ? If(
                  Score(Entity.Self(), 'dungeon_iter')
                      .matchesRange(Range.from(iterations - 1)),
                  then: [
                    File.execute(
                      'end',
                      child: For.of(
                        [
                          RandomStructure(end.getStructures(context),
                              size: size),
                        ],
                      ),
                    )
                  ],
                )
              : For.of([]),
          File.execute('addtags', child: AddStructureTags(pools)),
          File.execute('rotate', child: RotateStructure(pools, size: size)),
          File.execute(
            'createnew',
            child: CreateNew(
              pools,
              size: size,
              entity: entity,
              summon: summon,
              after: afterGeneration,
            ),
          ),
          Execute.asat(
            Entity(
              tags: ['dungeon_created_now'],
            ),
            children: [
              Teleport(
                Entity.Self(),
                to: Location.here(),
                rot: Rotation.rel(x: 180, y: 0),
              ),
              Entity.Self().removeTag('dungeon_created_now'),
            ],
          )
        ]),
      ),
    );
    if (start != null) {
      entity.arguments['distance'] = '..1';
      pack.files.add(
        File(
          'start',
          child: Execute.align('xz', children: [
            summon,
            entity.addTag('dungeon_start'),
            entity.removeTag('dungeon_new'),
            RandomStructure(start.getStructures(context), size: size),
            SetBlock(Blocks.redstone_block, location: Location.rel(y: 1)),
            AroundLocation(size[0].toDouble(), top: false, bottom: false,
                build: (Location loc) {
              return Execute.positioned(loc, children: [
                summon,
                Teleport(entity, to: Location.here(), facing: loc)
              ]);
            }),
            Builder(
              (context) {
                entity.arguments.remove('distance');
                return startAndTimer != null && startAndTimer >= 0
                    ? Repeat(
                        'repeat_gen',
                        to: iterations - 1,
                        ticks: startAndTimer,
                        child: Execute.asat(
                          entity,
                          children: [File.execute('generate', create: false)],
                        ),
                      )
                    : null;
              },
            ),
          ]).positioned(
            Location.rel(x: 0.5, z: 0.5),
          ),
        ),
      );
    }

    return For.of([pack]);
  }
}
