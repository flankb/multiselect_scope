import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multiselect_scope/multiselect_scope.dart';

void main() {
  testWidgets('Multiselect test', (WidgetTester tester) async {
    await tester.pumpWidget(MyAppTest());

    final state =
        tester.state(find.byType(MyHomePageTest)) as _MyHomePageTestState;
    debugPrint(state.items.toString());

    // 1. Убедиться, что выделены 2 элемента (1 и 3)

    // 2. Кликнуть на 7-м эелементе, убедиться, что он выделился

    // 3. Кликнуть на кнопку Invert , убедиться, что другие элементы выделены

    // 4. Кликнуть на кнопку Select all, убедиться, что все элементы выделены

    // 5. Инвертировать (теперь список элементов пуст)

    // 6. Выделить 4 и 7 элементы нажать на кнопку Add rand, Убедиться, что остались выделены те же эелементы

    // 7.  Нажать кнопку Remove rand, убедиться, что остались выделены те же элементы (если один из них не выделен, то возможно удален)

    // 8. Нажать кнопку Clear, убедиться, что список пуст

    // 9. Выделить 3 элемент, нажать кнопку Delete, убедиться, что он удалился
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
  MultiselectController multiselectController;
  Random random;

  @override
  void initState() {
    super.initState();
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
        onSelectionChanged: (indexes, items) {
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
                      final controller = MultiselectScope.of(
                          context); //MultiselectScope.of(context);

                      final itemIsSelected = controller.indexIsSelected(index);

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
                ],
              )
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
