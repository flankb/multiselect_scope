import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multiselect_scope/multiselect_scope.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Multiselect Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Multiselect'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<String> _items;
  late MultiselectController _multiselectController;
  late Random random;

  @override
  void initState() {
    super.initState();
    random = Random();
    _items = List.generate(10, (index) => 'Item $index');

    _multiselectController = MultiselectController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: MultiselectScope<String>(
        controller: _multiselectController,
        dataSource: _items,
        clearSelectionOnPop: true,
        keepSelectedItemsBetweenUpdates: false,
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
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final controller =
                          MultiselectScope.controllerOf(context)!;

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
                              _items[index],
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

                        final randomIndex = _items.isEmpty
                            ? 0
                            : random.nextInt(_items.length - 1);
                        _items.insert(randomIndex,
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
                        if (_items.length == 1) {
                          _items.removeAt(0);
                        } else {
                          _items.removeAt(random.nextInt(_items.length - 1));
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
                        final itemsToRemove = _multiselectController
                            .getSelectedItems()
                            .cast<String>();

                        _items = _items
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
                        _multiselectController.select(0);
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Select all'),
                    fillColor: Colors.amber,
                    onPressed: () {
                      setState(() {
                        _multiselectController.selectAll();
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Invert'),
                    fillColor: Colors.tealAccent,
                    onPressed: () {
                      setState(() {
                        _multiselectController.invertSelection();
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Clear'),
                    fillColor: Colors.deepPurpleAccent,
                    onPressed: () {
                      setState(() {
                        _multiselectController.clearSelection();
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
