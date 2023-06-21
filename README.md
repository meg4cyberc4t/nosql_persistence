 <div align="center">
    <h1>nosql_persistence</h1>
    <p>Using nosql databases with migrations</p>
</div>


Using NoSQL databases is now easier. We restrict them using our interface, and set the database version record. In the end, working with the database will be something like this:

```dart
final class HiveExampleDataSource extends HiveDataSource {
  HiveExampleDataSource(super.hive)
      : super(
          boxName: 'example',
          currentStorageVersion: 2,
        );

  @override
  @protected
  Future<void> migrate(int oldVersion, int currentVersion) async {
    if (await read(_counterKey) == null) {
      await saveCounter(0);
    }

    return super.migrate(oldVersion, currentVersion);
  }

  final String _counterKey = "counter";

  Future<String> getCounter() async =>
      (await read(_counterKey))!; // It's not just force unwrap, see migrate()

  Future<void> saveCounter(int counter) => write(
        key: _counterKey,
        value: counter.toString(),
      );
}
```
