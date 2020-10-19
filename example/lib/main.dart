import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multiselect_scope/multiselect_scope.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;
  List<String> _items;
  MultiselectController _multiselectController;

  @override
  void initState() {
    super.initState();
    _multiselectController = MultiselectController();
    // _multiselectController.addListener(() {
    //   debugPrint("Custom listener invoked!");
    // });

    _items = List.generate(10, (index) => 'Item $index');
  }

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    //ToggleButtons

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: MultiselectScope<String>(
        controller: _multiselectController,
        dataSource: _items,
        clearSelectionOnPop: true,
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
                              _items[index],
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Rectangle(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RawMaterialButton(
                    child: Text('Add rand'),
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    fillColor: Colors.blueGrey,
                    onPressed: () {
                      setState(() {
                        final randItem = 'RandItem';
                        _items.insert(3, randItem);
                      });
                    },
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Remove rand'),
                    fillColor: Colors.lightGreen,
                    onPressed: () {
                      setState(() {
                        _items.removeAt(Random().nextInt(_items.length - 1));
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

                        //_multiselectController.clearSelection();

                        _items = _items
                            .where(
                                (element) => !itemsToRemove.contains(element))
                            .toList();
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _multiselectController.select(0);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Rectangle extends StatelessWidget {
  Rectangle({Key key /*, MultiselectController controller*/}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('build Rectangle');

    return Container(
      height: 50,
      width: 50,
      color: Colors.red,
    );
  }
}

class RectangleStateful extends StatefulWidget {
  const RectangleStateful({Key key}) : super(key: key);

  @override
  _RectangleStatefulState createState() => _RectangleStatefulState();
}

class _RectangleStatefulState extends State<RectangleStateful> {
  @override
  Widget build(BuildContext context) {
    debugPrint('build Rectangle stateful');

    return Container(
      height: 50,
      width: 50,
      color: Colors.red,
    );
  }
}
