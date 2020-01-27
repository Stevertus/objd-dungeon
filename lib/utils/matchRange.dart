import 'package:objd/core.dart';

class MatchRange extends Widget {
  List<Widget> then;
  Range range;
  MatchRange(this.range, dynamic widget) {
    if (widget is List<Widget>) then = widget;
    if (widget is Widget) then = [widget];
  }

  @override
  Widget generate(Context context) {
    if (then.isEmpty) return For.of([]);
    var rnd = Score(Entity.Selected(), 'dungeon_type');
    return If(Condition.score(rnd.matchesRange(range)), then: then);
  }
}
