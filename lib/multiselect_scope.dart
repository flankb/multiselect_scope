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
  List<int> _selectedIndexes = [];

  List<int> get selectedIndexes => _selectedIndexes;
  bool get selectionAttached => _selectedIndexes.any((element) => true);

  int _itemsCount;

  void select(int index, {SelectionEvent event = SelectionEvent.auto}) {
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

  void clearSelection() {
    if (selectedIndexes.any((element) => true)) {
      selectedIndexes.clear();
      notifyListeners();
    }
  }

  void invertSelection() {}

  void selectAll() {
    _selectedIndexes = List<int>.generate(_itemsCount, (i) => i);
    notifyListeners();
  }

  bool indexIsSelected(int index) {
    return _selectedIndexes.contains(index);
  }

  void _setItemsCount(int itemsCount) {
    _itemsCount = itemsCount;
  }

  void _setSelectedIndexes(List<int> newIndexes) {
    _selectedIndexes = newIndexes;
  }
}

typedef SelectionChangedCallback = void Function(List<int> selectedIndexes);

class MultiselectScope<T> extends StatefulWidget {
  final Widget child;
  final SelectionChangedCallback onSelectionChanged;
  final MultiselectController controller;
  final List<T> dataSource;
  final bool clearSelectionOnPop;
  final bool preserveSelectedIndexesBetweenUpdates;

  MultiselectScope({
    Key key,
    @required this.controller,
    @required this.dataSource,
    this.onSelectionChanged,
    this.clearSelectionOnPop = false,
    this.preserveSelectedIndexesBetweenUpdates = true,
    @required this.child,
  })  : assert(dataSource != null),
        assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _MultiselectScopeState createState() => _MultiselectScopeState();

  static MultiselectController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedMultiselectNotifier>()
        .controller;
  }
}

class _MultiselectScopeState extends State<MultiselectScope> {
  List<int> _hashesCopy;

  @override
  void initState() {
    super.initState();

    debugPrint('_GreatMultiselectState init()');

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
  void didUpdateWidget(MultiselectScope oldWidget) {
    debugPrint('didUpdateWidget GreatMultiselect');
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
    debugPrint('build GreatMultiselect');
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

  _InheritedMultiselectNotifier _buildMultiselectScope() =>
      _InheritedMultiselectNotifier(
          child: widget.child, controller: widget.controller);

  void _updateController(MultiselectScope oldWidget) {
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

class _InheritedMultiselectNotifier
    extends InheritedNotifier<MultiselectController> {
  final MultiselectController controller;

  const _InheritedMultiselectNotifier(
      {Key key, @required Widget child, @required this.controller})
      : super(key: key, child: child, notifier: controller);
}
