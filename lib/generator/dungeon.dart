import 'package:meta/meta.dart';
import 'package:objd/core.dart';
import 'package:objd_dungeon/utils/structurePool.dart';

import '../utils/randomStructure.dart';
import 'createNew.dart';
import 'addTags.dart';
import 'rotateStructure.dart';
import 'setStructure.dart';

class Dungeon extends Widget {
  Map<String,StructurePool> pools;
  Pack pack;
  List<int> size;
  int iterations;
  StructurePool start;
  int startAndTimer;
  StructurePool end;
  Widget afterGeneration;
  Widget summon;
  Entity entity;

  Dungeon(this.pools,{@required this.pack,this.size = const [15,8,15],this.afterGeneration,this.entity,this.summon,this.start,this.end,this.startAndTimer = 10,this.iterations = 5}){
    _computePool();
    if(pack.files == null) pack.files = [];
    pack.files.add(File(path: "generate",child: For.of([
      Score(Entity.Selected(),"dungeon_type").reset(),
      If(Condition.not(Score(Entity.Selected(),"dungeon_iter").matchesRange(Range(from: iterations-1))),Then:[
        File.execute(path: "setstructure",child:SetStructure(pools,size:size,entity: entity))
      ]),
      this.end != null ?If(Score(Entity.Selected(),"dungeon_iter").matchesRange(Range(from: iterations-1)),Then:[
        File.execute(path: "end",child:For.of([
          RandomStructure(end.structures,size:size,pack:end.pack),
        ]))
      ]) : For.of([]),
      File.execute(path: "addtags",child:AddStructureTags(pools)),
      File.execute(path: "rotate",child:RotateStructure(pools,size: size)),
      File.execute(path: "createnew",child:CreateNew(pools,size: size,entity: entity,summon: summon,after:afterGeneration)),
      Execute.asat(Entity(tags:["dungeon_created_now"]),children:[
        Teleport(Entity.Selected(),to:Location.here(),rot: Rotation.rel(x:180,y:0)),
        Entity.Selected().removeTag("dungeon_created_now")
      ])
    ])));
    if(start != null){
      entity.arguments["distance"] = "..1";
      pack.files.add(File(path: "start",child: Execute.align("xz",children: [
        RandomStructure(start.structures,size:size,pack:end.pack),
        SetBlock(Block.redstone_block,location:Location.rel(y:1)),
        AroundLocation(size[0].toDouble(),top:false,bottom:false,build: (Location loc){
          return Execute.positioned(loc,children: [summon,Teleport(entity,to:Location.here(),facing: loc)]);
        }),
        For(to:1,create: (i){
          entity.arguments.remove("distance");
        }),
        startAndTimer != null && startAndTimer >= 0 ? Repeat("repeat_gen",to:iterations - 1,ticks: startAndTimer,child:Execute.asat(entity,children:[File.execute(path: "generate",create: false)])) : For.of([])
      ]).positioned(Location.rel(x:0.5,z:0.5))));
    }
  }

  _computePool(){
    int perc = 100;
    int currentLowest = 0;
    int length = pools.length;
    // split the remaining percent
    pools.values.forEach((pool){
      if(pool.bias != null) perc -= pool.bias;
      if(pool.mirror != null && pool.mirror) length++;
    });
    if(perc < 0) perc = 0;
    int average = (perc ~/ pools.length);
    pools.values.forEach((pool){
      var adding = average;
      if(pool.bias != null) adding = pool.bias;
        if(pool.mirror != null && pool.mirror){
          pool.range = Range(from:currentLowest,to:currentLowest + 2*adding - 1);
          pool.mirroredRange1 = Range(from:currentLowest,to:currentLowest + adding - 1);
          currentLowest += adding;
          pool.mirroredRange2 = Range(from:currentLowest,to:currentLowest + adding - 1);
        } else {
          pool.range = Range(from:currentLowest,to:currentLowest + adding - 1);
        }
        currentLowest += adding;
    });
  }


  @override
  Widget generate(Context context) {
    return For.of([pack]);
  }
}