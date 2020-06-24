import 'package:objd/core.dart';

class ChangeRot extends Widget {
  List<Widget> ret = [];
  Tag mirror;
  Score rot;

  ChangeRot(this.rot,
      {int x, int z, this.mirror, List<int> size = const [15, 8, 15]}) {
    if (x != null) {
      ret.add(
          Data.merge(Location.here(), nbt: {'posX': x * (size[0] - 1) ~/ 2}));
    }
    if (z != null) {
      ret.add(
          Data.merge(Location.here(), nbt: {'posZ': z * (size[0] - 1) ~/ 2}));
    }
  }

  @override
  Widget generate(Context context) {
    if (mirror != null) {
      return If(
        Condition.and([rot, mirror]),
        then: ret,
        assignTag: Entity.Self(),
      );
    }
    return If(rot, then: ret);
  }
}
