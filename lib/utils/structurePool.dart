import 'package:objd/core.dart';

class StructurePool {
  List<String> structures;
  int bias;
  String path;
  String pack;
  Range range;
  Range mirroredRange1;
  Range mirroredRange2;
  bool mirror, front, left, right;
  StructurePool(
    this.structures, {
    double bias,
    this.path,
    this.front,
    this.left,
    this.right,
    this.mirror,
    this.pack,
  }) {
    if (bias != null) {
      if (bias > 1 || bias <= 0) {
        throw ('You can\'t have a chance of more than 1 on a pool!');
      }
      this.bias = (bias * 100).floor();
    }
  }
  List<String> getStructures(Context context) {
    pack ??= context.packId;
    path = path != null ? path + '/' : '';
    path = pack + ':' + path;
    return List<String>.from(structures)
        .map<String>((struct) => path + struct)
        .toList();
  }
}
