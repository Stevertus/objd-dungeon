import 'package:objd/core.dart';


class RandomStructure extends Widget {

  List<String> structures;
  List<int> size;
  String pack;

  RandomStructure(this.structures,{this.pack,this.size = const [15,8,15]});

  @override
  Widget generate(Context context) {

    var score = Score(Entity.Selected(),"objd_random");
    return For.of([
      RandomScore(Entity.Selected(),to:structures.length -1),
      For(to: structures.length - 1,create: (int i){
        return If(Condition.score(score.matches(i)),Then:[
          SetBlock(Block.structure_block,location: Location.here(),nbt:{"name":pack == null ? structures[i] : pack + ":" + structures[i]})
        ]);
      }),
      Data.merge(Location.here(),nbt: {"mode":"LOAD","ignoreEntities":0,"showboundingbox":1,"posX":-(size[0] - 1) ~/2,"posY":0,"posZ":-(size[2] - 1) ~/2})
    ]);
  }
}