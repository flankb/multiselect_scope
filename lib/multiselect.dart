import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Multiselect extends StatefulWidget {
  final Widget child;
  Multiselect({Key key, @required this.child}) : super(key: key);

  static MultiselectState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedMultiselect>()
        .data;
  }

  @override
  MultiselectState createState() => MultiselectState();
}

class MultiselectState extends State<Multiselect> {
  List<int> _selectedIndexes = [];
  List<int> get selectedIndexes => _selectedIndexes;

  select(int index) {
    if (!_selectedIndexes.contains(index)) {
      //debugPrint("!_selectedIndexes.contains");
      setState(() {
        _selectedIndexes.add(index);
      });
    }
  }

  unselectItem(int index) {
    if (_selectedIndexes.contains(index)) {
      setState(() {
        _selectedIndexes.remove(index);
      });
    }
  }

  bool indexIsSelected(int i) {
    return _selectedIndexes.contains(i);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedMultiselect(child: widget.child, data: this);
  }
}

class _InheritedMultiselect extends InheritedWidget {
  _InheritedMultiselect({this.data, Key key, this.child})
      : super(key: key, child: child);

  final Widget child;
  final MultiselectState data;

  // static _InheritedMultiselect of(BuildContext context) {
  //   return context.dependOnInheritedWidgetOfExactType<_InheritedMultiselect>();
  // }

  @override
  bool updateShouldNotify(_InheritedMultiselect oldWidget) {
    return true; //oldWidget.data != data;
  }
}
