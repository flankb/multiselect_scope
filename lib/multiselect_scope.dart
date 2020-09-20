library multiselect_scope;

import 'package:flutter/cupertino.dart';

class MultiselectController extends ChangeNotifier {
  //TODO Инкапсулировать
  List<int> _selectedIndexes = [];
  List<int> get selectedIndexes => _selectedIndexes;

  select(int index) {
    if (!_selectedIndexes.contains(index)) {
      //debugPrint("!_selectedIndexes.contains");
      _selectedIndexes.add(index);
      notifyListeners();
    }
  }

  unselectItem(int index) {
    if (_selectedIndexes.contains(index)) {
      _selectedIndexes.remove(index);
      notifyListeners();
    }
  }

  detachSelection() {
    if (selectedIndexes.any((element) => true)) {
      selectedIndexes.clear();
      notifyListeners();
    }
  }

  bool indexIsSelected(int i) {
    return _selectedIndexes.contains(i);
  }
}

typedef SelectionChangedCallback = void Function(List<int> selectedIndexes);

class GreatMultiselect extends StatefulWidget {
  final Widget child;
  final SelectionChangedCallback onSelectionChanged;
  final MultiselectController controller;
  GreatMultiselect(
      {Key key, this.child, this.onSelectionChanged, this.controller})
      : super(key: key);

  @override
  _GreatMultiselectState createState() => _GreatMultiselectState();

  static MultiselectController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MultiselectScope>()
        .controller;
  }
}

class _GreatMultiselectState extends State<GreatMultiselect> {
  @override
  void initState() {
    super.initState();

    if (widget.onSelectionChanged != null) {
      widget.controller.addListener(() {
        widget.onSelectionChanged.call(widget.controller.selectedIndexes);
      });
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiselectScope(child: widget.child, controller: widget.controller);
  }
}

class MultiselectScope extends InheritedNotifier<MultiselectController> {
  final MultiselectController controller;

  const MultiselectScope(
      {Key key, @required Widget child, @required this.controller})
      : super(key: key, child: child, notifier: controller);

  static MultiselectController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MultiselectScope>()
        .controller;
  }
}
