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
  //List<int> _previousSelectedIndexes = [];
  List<int> _selectedIndexes = [];
  List<int> _addedIndexes = [];
  List<int> _removedIndexes = [];

  List<int> get selectedIndexes => _selectedIndexes;
  List<int> get addedIndexes => _addedIndexes;
  List<int> get removedIndexes => _removedIndexes;

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
        _updateOnlyAddedIndexes([index]);

        notifyListeners();
      }
    } else if (computedEvent == SelectionEvent.unselect) {
      if (indexContains) {
        _selectedIndexes.remove(index);
        _updateOnlyRemovedIndexes([index]);

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
      _updateOnlyRemovedIndexes(List<int>.from(_selectedIndexes));

      selectedIndexes.clear();
      notifyListeners();
    }
  }

  void invertSelection() {}

  void selectAll() {
    final preselectIndexes = _selectedIndexes;

    _selectedIndexes = List<int>.generate(_itemsCount, (i) => i);

    final addedIndexes =
        _selectedIndexes.toSet().difference(preselectIndexes.toSet()).toList();
    _updateOnlyAddedIndexes(addedIndexes);

    notifyListeners();
  }

  bool indexIsSelected(int index) {
    return _selectedIndexes.contains(index);
  }

  void _setItemsCount(int itemsCount) {
    _itemsCount = itemsCount;
  }

  void _setSelectedIndexes(List<int> newIndexes, List<int> newAddedIndexes,
      List<int> newRemovedIndexes) {
    _selectedIndexes = newIndexes;
  }

  void _updateOnlyAddedIndexes(List<int> addedIndexes) {
    _removedIndexes = [];
    _addedIndexes = addedIndexes;
  }

  void _updateOnlyRemovedIndexes(List<int> removedIndexes) {
    _removedIndexes = removedIndexes;
    _addedIndexes = [];
  }
}

typedef SelectionChangedCallback = void Function(List<int> selectedIndexes,
    List<int> addedIndexes, List<int> removedIndexes);

class MultiselectScope<T> extends StatefulWidget {
  final Widget child;
  final SelectionChangedCallback onSelectionChanged;
  final MultiselectController controller;
  final List<T> dataSource;
  final bool clearSelectionOnPop;
  final bool preserveSelectedIndexesBetweenUpdates;
  final List<int> initialSelectedIndexes;

  MultiselectScope({
    Key key,
    @required this.controller,
    @required this.dataSource,
    this.onSelectionChanged,
    this.clearSelectionOnPop = false,
    this.preserveSelectedIndexesBetweenUpdates = true,
    @required this.child,
    this.initialSelectedIndexes,
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

    if (widget.initialSelectedIndexes != null) {
      widget.controller
          ._setSelectedIndexes(widget.initialSelectedIndexes, [], []);
    }

    if (widget.onSelectionChanged != null) {
      widget.controller.addListener(() {
        final controller = widget.controller;
        widget.onSelectionChanged.call(controller.selectedIndexes,
            controller.addedIndexes, controller.removedIndexes);
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
    final controller = widget.controller;

    //debugPrint(
    //    "Old dataSource: ${_hashesCopy} new dataSource: ${newHashesCopy}");

    final oldSelectedHashes =
        controller.selectedIndexes.map((e) => _hashesCopy[e]).toList();

    final oldAddedHashes =
        controller.addedIndexes.map((e) => _hashesCopy[e]).toList();

    // TODO Нет возможности вычислить индексы исчесзувших (удалённые) элементы!
    // Но при этом вызывающий код должен знать, какие эелементы больше не выделены!
    // Поэтому функционал added/removed крайне сложно реализуем в варианте сохранения
    // между обновлениями источника данных, обработку актуальных выделенных элементов
    // следует возложить на вызывающий код
    final oldRemovedHashed =
        controller.removedIndexes.map((e) => _hashesCopy[e]).toList();

    final newIndexes = <int>[];
    newHashesCopy.asMap().forEach((index, value) {
      //debugPrint("$index $value");

      if (oldSelectedHashes.contains(value)) {
        newIndexes.add(index);
      }
    });

    widget.controller._setItemsCount(widget.dataSource.length);

    // Пересчитаем добавленные и удаленные индексы

    widget.controller._setSelectedIndexes(newIndexes, [], []);

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
