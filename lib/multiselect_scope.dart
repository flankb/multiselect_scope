library multiselect_scope;

import 'package:flutter/cupertino.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class MultiselectController extends ChangeNotifier {
  List<int> _selectedIndexes = [];
  List<int> get selectedIndexes => _selectedIndexes;

  select(int index) {
    if (!_selectedIndexes.contains(index)) {
      _selectedIndexes.add(index);
    }

    notifyListeners();
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
