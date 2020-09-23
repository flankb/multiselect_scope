library multiselect_scope;

import 'package:flutter/cupertino.dart';

enum SelectionEvent {
  /// Unselect item if it selected, select otherwise
  auto,

  /// Select item
  select,

  /// Deselect item
  unselect,
}

class MultiselectController extends ChangeNotifier {
  //bool _selectionAttached = false;
  List<int> _selectedIndexes = [];

  List<int> get selectedIndexes => _selectedIndexes;
  bool get selectionAttached => _selectedIndexes.any((element) => true);

  int _itemsCount;

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

  selectAll() {
    _selectedIndexes = List<int>.generate(_itemsCount, (i) => i);
    notifyListeners();
  }

  bool indexIsSelected(int i) {
    return _selectedIndexes.contains(i);
  }

  _setItemsCount(int itemsCount) {
    _itemsCount = itemsCount;
  }

  void _setSelectedIndexes(List<int> newIndexes) {
    _selectedIndexes = newIndexes;
    //notifyListeners();
  }
}

typedef SelectionChangedCallback = void Function(List<int> selectedIndexes);

typedef SelectedItemBuilder = G Function<G>(int index);

class GreatMultiselect<T> extends StatefulWidget {
  final Widget child;
  final SelectionChangedCallback onSelectionChanged;
  final MultiselectController controller;
  final List<T> dataSource;
  final bool clearSelectionOnPop;
  final bool preserveSelectedIndexesBetweenUpdates;

  GreatMultiselect({
    Key key,
    @required this.child,
    @required this.dataSource,
    this.onSelectionChanged,
    this.controller,
    this.clearSelectionOnPop = false,
    this.preserveSelectedIndexesBetweenUpdates = true,
  })  : assert(dataSource != null),
        super(key: key);

  @override
  _GreatMultiselectState createState() => _GreatMultiselectState();

  static MultiselectController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MultiselectScope>()
        .controller;
  }
}

class _GreatMultiselectState extends State<GreatMultiselect> {
  List<int> _hashesCopy;

  @override
  void initState() {
    super.initState();

    debugPrint("_GreatMultiselectState init()");

    _hashesCopy = _createHashesCopy();
    widget.controller._setItemsCount(widget.dataSource.length);

    if (widget.onSelectionChanged != null) {
      widget.controller.addListener(() {
        widget.onSelectionChanged.call(widget.controller.selectedIndexes);
      });
    }
  }

  List<int> _createHashesCopy() {
    return widget.dataSource.map((e) => e.hashCode).toList();
  }

  @override
  void didUpdateWidget(GreatMultiselect oldWidget) {
    debugPrint("didUpdateWidget GreatMultiselect");
    if (widget.preserveSelectedIndexesBetweenUpdates) {
      _updateController(oldWidget);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build GreatMultiselect");
    return widget.clearSelectionOnPop
        ? WillPopScope(
            onWillPop: () async {
              if (widget.controller.selectionAttached) {
                widget.controller.clearSelection();
                return false;
              }

              return true;
            },
            child: _buildMultiselectScope(),
          )
        : _buildMultiselectScope();
  }

  MultiselectScope _buildMultiselectScope() =>
      MultiselectScope(child: widget.child, controller: widget.controller);

  void _updateController(GreatMultiselect oldWidget) {
    //_hashesCopy = widget.dataSource.map((e) => e.hashCode).toList();

    final newHashesCopy = _createHashesCopy();

    //debugPrint(
    //    "Old dataSource: ${_hashesCopy} new dataSource: ${newHashesCopy}");

    final oldSelectedHashes =
        widget.controller.selectedIndexes.map((e) => _hashesCopy[e]).toList();

    final newIndexes = <int>[];
    newHashesCopy.asMap().forEach((index, value) {
      //debugPrint("$index $value");

      if (oldSelectedHashes.contains(value)) {
        newIndexes.add(index);
      }
    });

    widget.controller._setItemsCount(widget.dataSource.length);
    widget.controller._setSelectedIndexes(newIndexes);

    _hashesCopy = newHashesCopy;
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
