import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multiselect_scope/multiselect_scope.dart';
import 'package:collection/collection.dart';

extension on List {
  bool containsAll(Iterable items) {
    items.forEach((element) {
      if (!this.contains(element)) {
        return false;
      }
    });

    return true;
  }

  bool notContainsAll(Iterable items) {
    items.forEach((element) {
      if (this.contains(element)) {
        return false;
      }
    });

    return true;
  }
}

void main() {
  List<String> _stateItems;

  void _updateStateItems(_MyHomePageTestState stateBy) {
    _stateItems =
        stateBy.multiselectController.getSelectedItems().cast<String>();
  }

  testWidgets('Multiselect test', (WidgetTester tester) async {
    await tester.pumpWidget(MyAppTest());

    final state =
        tester.state(find.byType(MyHomePageTest)) as _MyHomePageTestState;
    debugPrint(state.items.toString());

    // 1. Ensure that two starting elements was selected
    _updateStateItems(state);
    expect(_stateItems.contains('Item 1'), true);
    expect(_stateItems.contains('Item 3'), true);

    // 2. Click on the 7th element, make sure it is selected
    await tester.tap(find.text('Item 7'));
    await tester.pump();
    _updateStateItems(state);

    expect(_stateItems.contains('Item 7'), true);
    expect(state.selectedItemsTrack.containsAll(['Item 7', 'Item 1', 'Item 3']),
        true);

    // 3. Кликнуть на кнопку Invert , убедиться, что другие элементы выделены
    await tester.tap(find.text('Invert'));
    await tester.pump();
    _updateStateItems(state);

    expect(
        _stateItems.containsAll(
            state.items.toSet().difference({'Item 7', 'Item 1', 'Item 3'})),
        true);
    expect(state.selectedIndexesTrack.containsAll([0, 2, 5]), true);
    expect(state.selectedIndexesTrack.notContainsAll([7, 1, 3]), true);

    // 4. Кликнуть на кнопку Select all, убедиться, что все элементы выделены
    await tester.tap(find.text('Select all'));
    await tester.pump();
    _updateStateItems(state);

    expect(_stateItems.containsAll(state.items.toSet()), true);

    // 5. Инвертировать (теперь список элементов пуст)
    await tester.tap(find.text('Invert'));
    await tester.pump();
    _updateStateItems(state);

    expect(
        _stateItems.isEmpty &&
            state.selectedIndexesTrack.isEmpty &&
            state.selectedItemsTrack.isEmpty,
        true);

    // 6. Выделить 4 и 7 элементы нажать на кнопку Add rand, Убедиться, что остались выделены те же эелементы
    await tester.tap(find.text('Item 4'));
    await tester.tap(find.text('Item 7'));
    await tester.pump();

    await tester.tap(find.text('Add rand'));
    await tester.pump();

    _updateStateItems(state);

    final preselected = ['Item 4', 'Item 7'];
    expect(state.selectedItemsTrack.containsAll(preselected), true);
    expect(_stateItems.containsAll(preselected), true);

    // 7.  Нажать кнопку Remove rand, убедиться, что остались выделены те же элементы (если один из них не выделен, то возможно удален)
    await tester.tap(find.text('Remove rand'));
    await tester.pump();
    _updateStateItems(state);

    preselected.forEach((String preselectedItem) {
      if (state.items.contains(preselectedItem)) {
        expect(_stateItems.containsAll(preselected), true);
      }
      ;
    });

    // 8. Нажать кнопку Clear, убедиться, что список пуст
    await tester.tap(find.text('Clear'));
    await tester.pump();
    _updateStateItems(state);

    expect(
        _stateItems.isEmpty &&
            state.selectedIndexesTrack.isEmpty &&
            state.selectedItemsTrack.isEmpty,
        true);

    // 9. Выделить 3 элемент, нажать кнопку Delete, убедиться, что он удалился
    await tester.longPress(find.text('Item 3'));
    await tester.pump();
    _updateStateItems(state);

    await tester.tap(find.text('Delete'));
    await tester.pump();
    _updateStateItems(state);

    expect(state.items.contains('Item 3'), false);

    final stateIndexes = List.from(state.selectedIndexesTrack);

    await tester.tap(find.text('No keep'));
    await tester.pump();

    await tester.tap(find.text('Add rand'));
    await tester.pump();

    _updateStateItems(state);

    Function eq = const ListEquality().equals;
    expect(eq(stateIndexes, state.selectedIndexesTrack), true);
  });
}

class MyAppTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Multiselect scope Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePageTest(title: 'Multiselect'),
    );
  }
}

class MyHomePageTest extends StatefulWidget {
  MyHomePageTest({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageTestState createState() => _MyHomePageTestState();
}

class _MyHomePageTestState extends State<MyHomePageTest> {
  List<String> items;
  List<String> selectedItemsTrack;
  List<int> selectedIndexesTrack;
  bool keepSelectedIndexes;

  MultiselectController multiselectController;
  Random random;

  @override
  void initState() {
    super.initState();
    keepSelectedIndexes = true;
    random = Random();
    items = List.generate(10, (index) => 'Item $index');

    multiselectController = MultiselectController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MultiselectScope<String>(
        controller: multiselectController,
        dataSource: items,
        clearSelectionOnPop: true,
        initialSelectedIndexes: [1, 3],
        keepSelectedItemsBetweenUpdates: keepSelectedIndexes,
        onSelectionChanged: (indexes, items) {
          selectedItemsTrack = items;
          selectedIndexesTrack = indexes;

          debugPrint(
              'Custom listener invoked! Indexes: $indexes Items: $items');
          return;
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final controller = MultiselectScope.controllerOf(
                          context); //MultiselectScope.of(context);

                      final itemIsSelected = controller.isSelected(index);

                      return InkWell(
                        onLongPress: () {
                          if (!controller.selectionAttached) {
                            controller.select(index);
                          }
                        },
                        onTap: () {
                          debugPrint('Item is selected: $itemIsSelected');

                          if (controller.selectionAttached) {
                            controller.select(index);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: itemIsSelected
                                ? Theme.of(context).primaryColor
                                : null,
                            child: Text(
                              items[index],
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Wrap(
                children: <Widget>[
                  RawMaterialButton(
                    child: Text('Add rand'),
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    fillColor: Colors.blueGrey,
                    onPressed: () {
                      setState(() {
                        final randItem =
                            'RandItem' + random.nextInt(256).toString();

                        final randomIndex = items.isEmpty
                            ? 0
                            : random.nextInt(items.length - 1);
                        items.insert(randomIndex,
                            randItem); // TODO Fix after delete all!
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Remove rand'),
                    fillColor: Colors.lightGreen,
                    onPressed: () {
                      setState(() {
                        if (items.length == 1) {
                          items.removeAt(0);
                        } else {
                          items.removeAt(random.nextInt(items.length - 1));
                        }
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    fillColor: Colors.blueGrey,
                    child: Text('Delete'),
                    onPressed: () {
                      setState(() {
                        final itemsToRemove = multiselectController
                            .getSelectedItems()
                            .cast<String>();

                        items = items
                            .where(
                                (element) => !itemsToRemove.contains(element))
                            .toList();
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Select 0'),
                    fillColor: Colors.lightGreen,
                    onPressed: () {
                      setState(() {
                        multiselectController.select(0);
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Select all'),
                    fillColor: Colors.amber,
                    onPressed: () {
                      setState(() {
                        multiselectController.selectAll();
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Invert'),
                    fillColor: Colors.tealAccent,
                    onPressed: () {
                      setState(() {
                        multiselectController.invertSelection();
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Clear'),
                    fillColor: Colors.deepPurpleAccent,
                    onPressed: () {
                      setState(() {
                        multiselectController.clearSelection();
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('No keep'),
                    fillColor: Colors.deepPurpleAccent,
                    onPressed: () {
                      setState(() {
                        keepSelectedIndexes = !keepSelectedIndexes;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
