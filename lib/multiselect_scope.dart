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
  List _dataSource = [];

  List<int> get selectedIndexes => _selectedIndexes;
  bool get selectionAttached => _selectedIndexes.any((element) => true);

  int _itemsCount;

  void select(int index, {SelectionEvent event = SelectionEvent.auto}) {
    final indexContains = _selectedIndexes.contains(index);
    final computedEvent = event == SelectionEvent.auto
        ? indexContains
            ? SelectionEvent.unselect
            : SelectionEvent.select
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

  List getSelectedItems() {
    final selectedItems = selectedIndexes.map((e) => _dataSource[e]).toList();

    return selectedItems;
  }

  void clearSelection() {
    if (selectedIndexes.any((element) => true)) {
      selectedIndexes.clear();
      notifyListeners();
    }
  }

  void invertSelection() {
    _selectedIndexes = List<int>.generate(_itemsCount, (i) => i)
        .toSet()
        .difference(_selectedIndexes.toSet())
        .toList();

    notifyListeners();
  }

  void selectAll() {
    _selectedIndexes = List<int>.generate(_itemsCount, (i) => i);
    notifyListeners();
  }

  bool indexIsSelected(int index) {
    return _selectedIndexes.contains(index);
  }

  @deprecated
  void _setItemsCount(int itemsCount) {
    _itemsCount = itemsCount;
  }

  void _setDataSource(List dataSource) {
    _dataSource = dataSource;
    _itemsCount = dataSource.length;
  }

  void _setSelectedIndexes(List<int> newIndexes) {
    _selectedIndexes = newIndexes;
  }
}

typedef SelectionChangedCallback<T> = void Function(
    List<int> selectedIndexes, List<T> selectedItems);
//typedef SelectionItemsChangedCallback = void Function(List selectedItems);
//List<int> intList2 = dynList.cast<int>();

class MultiselectScope<T> extends StatefulWidget {
  final Widget child;
  final SelectionChangedCallback<T> onSelectionChanged;
  final MultiselectController controller;
  final List<T> dataSource;
  final bool clearSelectionOnPop;
  final bool preserveSelectedItemsBetweenUpdates;
  final List<int> initialSelectedIndexes;

  MultiselectScope({
    Key key,
    @required this.controller,
    @required this.dataSource,
    this.onSelectionChanged,
    this.clearSelectionOnPop = false,
    this.preserveSelectedItemsBetweenUpdates = true,
    @required this.child,
    this.initialSelectedIndexes,
  })  : assert(dataSource != null),
        assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  _MultiselectScopeState<T> createState() => _MultiselectScopeState<T>();

  static MultiselectController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedMultiselectNotifier>()
        .controller;
  }
}

class _MultiselectScopeState<T> extends State<MultiselectScope<T>> {
  List<int> _hashesCopy;

  @override
  void initState() {
    super.initState();

    debugPrint('_GreatMultiselectState init()');

    _hashesCopy = _createHashesCopy();
    widget.controller._setDataSource(widget.dataSource);

    if (widget.initialSelectedIndexes != null) {
      widget.controller._setSelectedIndexes(widget.initialSelectedIndexes);
    }

    if (widget.onSelectionChanged != null) {
      widget.controller.addListener(() {
        widget.onSelectionChanged.call(widget.controller.selectedIndexes,
            widget.controller.getSelectedItems().cast<T>());
      });
    }
  }

  List<int> _createHashesCopy() {
    return widget.dataSource.map((e) => e.hashCode).toList();
  }

  @override
  void didUpdateWidget(MultiselectScope oldWidget) {
    debugPrint('didUpdateWidget GreatMultiselect');
    if (widget.preserveSelectedItemsBetweenUpdates) {
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

    // widget.controller._setItemsCount(widget.dataSource.length);

    widget.controller._setDataSource(widget.dataSource);
    widget.controller._setSelectedIndexes(newIndexes);

    _hashesCopy = newHashesCopy;
  }

  // void _setInitialIndexes() {
  //   if (widget.initialSelectedIndexes != null){
  //     widget.controller._setSelectedIndexes(widget.initialSelectedIndexes);
  //   }
  // }
}

class _InheritedMultiselectNotifier
    extends InheritedNotifier<MultiselectController> {
  final MultiselectController controller;

  const _InheritedMultiselectNotifier(
      {Key key, @required Widget child, @required this.controller})
      : super(key: key, child: child, notifier: controller);
}
