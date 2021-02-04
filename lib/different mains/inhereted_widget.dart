import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InheritedWidget playground',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: MyStatefulWidget(
          child: MyContainer(
            child: DummyContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CounterLabel(),
                  CounterValue(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  final Widget child;

  const MyStatefulWidget({Key key, @required this.child}) : super(key: key);

  static MyStatefulWidgetState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>().data;
  }

  @override
  State<StatefulWidget> createState() {
    return MyStatefulWidgetState();
  }
}

class MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _counterValue = 0;

  int get counterValue => _counterValue;

  void addCounterBy1() {
    setState(() {
      _counterValue += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyInheritedWidget(
      child: widget.child,
      data: this,
    );
  }
}

class MyInheritedWidget extends InheritedWidget {
  final MyStatefulWidgetState data;

  MyInheritedWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class MyContainer extends StatelessWidget {
  final Widget child;

  MyContainer({
    Key key,
    @required this.child,
  })  : super(key: key);

  void onPressed(BuildContext context) {
    MyStatefulWidget.of(context).addCounterBy1();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        child: RaisedButton(
          color: Colors.red,
          onPressed: (){
            onPressed(context);
          },
          child: child,
        ),
      ),
    );
  }
}

class DummyContainer extends StatelessWidget {
  final Widget child;

  const DummyContainer({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class CounterLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "Counter",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    );
  }
}

class CounterValue extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CounterValueState();
  }
}

class CounterValueState extends State<CounterValue> {
  int counterValue;
  double fontSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyStatefulWidgetState data = MyStatefulWidget.of(context);
    counterValue = data.counterValue;
    fontSize = 50.0 + counterValue;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "$counterValue",
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
      ),
    );
  }
}
