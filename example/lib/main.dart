import 'package:flutter/material.dart';
import 'package:nosql_persistence/nosql_persistence.dart';

final class ExampleDataSource extends StorageDataSource {
  ExampleDataSource(super.hive)
      : super(
          databaseName: 'example',
          databaseVersion: 2,
        );

  @override
  Duration? get databaseExpiredDuration => const Duration(seconds: 5);

  @override
  Future<void> migrate(int oldVersion, int currentVersion) async {
    if (oldVersion < currentVersion) {
      await saveCounter(0);
    }
    return super.migrate(oldVersion, currentVersion);
  }

  static const String _counterKey = 'counter';

  Future<int> getCounter() async =>
      int.parse((await getExpired(_counterKey)) ?? '0');

  Future<void> saveCounter(int value) => putExpired(
        key: _counterKey,
        value: value.toString(),
      );
}

Future<void> main() async {
  await Hive.initFlutter();
  final ExampleDataSource dataSource = ExampleDataSource(Hive);
  await dataSource.initAsync();

  runApp(
    MyApp(
      dataSource: dataSource,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ExampleDataSource dataSource;

  const MyApp({
    required this.dataSource,
    super.key,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(
          title: 'Flutter Demo Home Page',
          dataSource: dataSource,
        ),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    required this.dataSource,
    super.key,
  });

  final ExampleDataSource dataSource;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<void> _incrementCounter() async {
    setState(() => _counter++);
  }

  Future<void> saveValue() async {
    await widget.dataSource.saveCounter(_counter);
  }

  Future<void> loadValue() async {
    _counter = await widget.dataSource.getCounter();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              onPressed: saveValue,
              tooltip: 'Save',
              child: const Icon(Icons.save),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: loadValue,
              tooltip: 'Upload',
              child: const Icon(Icons.upload),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      );
}
