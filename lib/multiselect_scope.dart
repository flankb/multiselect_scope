library multiselect_scope;

import 'package:flutter/cupertino.dart';

enum SelectionEvent {
  auto,

  select,

  unselect,
}

class MultiselectController extends ChangeNotifier {
  //bool _selectionAttached = false;
  List<int> _selectedIndexes = [];

  List<int> get selectedIndexes => _selectedIndexes;
  bool get selectionAttached => _selectedIndexes.any((element) => true);

  int _listLength;

  /// Sets the controller length
  set(int i) {
    _listLength = i;
    selectedIndexes.clear();

    //notifyListeners();
  }

  select(int index, {SelectionEvent event = SelectionEvent.auto}) {
    final indexContains = _selectedIndexes.contains(index);
    final computedEvent = event == SelectionEvent.auto
        ? indexContains ? SelectionEvent.unselect : SelectionEvent.select
        : event;

    if (computedEvent == SelectionEvent.select) {
      if (!indexContains) {
        _selectedIndexes.add(index);
        notifyListeners();
      }
    } else if (computedEvent == SelectionEvent.unselect) {
      if (indexContains) {
        _selectedIndexes.remove(index);
        notifyListeners();
      }
    }
  }

  List<T> getSelectedItems<T>(List<T> allItems) {
    final selectedItems = selectedIndexes.map((e) => allItems[e]).toList();

    return selectedItems;
  }

  clearSelection() {
    if (selectedIndexes.any((element) => true)) {
      selectedIndexes.clear();
      notifyListeners();
    }
  }

  invertSelection() {}

  bool indexIsSelected(int i) {
    return _selectedIndexes.contains(i);
  }
}

typedef SelectionChangedCallback = void Function(List<int> selectedIndexes);

class GreatMultiselect extends StatefulWidget {
  final Widget child;
  final SelectionChangedCallback onSelectionChanged;
  final MultiselectController controller;
  final int itemsCount;
  final bool clearSelectionOnBackPressed;

  GreatMultiselect(
      {Key key,
      @required this.child,
      this.onSelectionChanged,
      this.controller,
      @required this.itemsCount,
      this.clearSelectionOnBackPressed = false})
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

    widget.controller.set(widget.itemsCount);

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
    return widget.clearSelectionOnBackPressed
        ? WillPopScope(
            onWillPop: () async {
              if (widget.controller.selectionAttached) {
                widget.controller.clearSelection();
                return false;
              }

              return true;
            },
            child: MultiselectScope(
                child: widget.child, controller: widget.controller),
          )
        : MultiselectScope(child: widget.child, controller: widget.controller);
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
