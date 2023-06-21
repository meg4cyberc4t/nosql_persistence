<div align="center">
  <img src="https://github.com/meg4cyberc4t/nosql_persistence/assets/66907532/9ed174b9-f31d-43c4-b811-a0f5dd84e6ad"></img>
  <h3>Using NoSQL databases with migrations</h3>
</div>
</br>


Using NoSQL databases is now easier. We want to simplify a lot of work with NoSQL databases in Flutter using migrations between versions. All the logic for working with data will remain in the class, and you will have to use the prepared methods!

### Features

💻 Good work with models from Json & toJSON.\
💐 Migrations between versions.\
🌱 Hidden logic inside the class, the connection is SOLID.\
🏁 Speed of work and data loading from <a href="https://pub.dev/packages/hive">Hive</a> and <a href="https://pub.dev/packages/flutter_secure_storage">Flutter Secure Storage</a>.

### Motivation

Using NoSQL databases is difficult when you need to update data between versions. In our package, we have tried to simplify working with them so that it is easier for you to work. Now migrations can be done like this:
```dart
@override
 Future<void> migrate(int oldVersion, int currentVersion) async {
   if (oldVersion < currentVersion) {
     await write(0);
   }
   return super.migrate(oldVersion, currentVersion);
 }
```


### Getting Started
1. Add nosql_persistence to dependencies
2. Initialize according to the instructions <a href="https://pub.dev/packages/hive">Hive</a> and <a href="https://pub.dev/packages/flutter_secure_storage">Flutter Secure Storage</a>.
3. Create your final class and inherit it from ```SecureDataSource``` (if it is protected data) and ```StorageDataSource``` (if there are a lot of them and you need fast work).
You will get something like this
```dart
final class ExampleDataSource extends SecureDataSource {
  ExampleDataSource(super.secureStorage)
      : super(
          databaseName: 'example',
          databaseVersion: 1,
        );
}
```
4. Describe the methods you need
```dart
  Future<String?> getLastEmail() async => read('last_email');

  Future<void> putLastEmail(String value) async =>
      write(key: 'last_email', value: value);
```
5. Describe the methods with the models that you need
```dart
  Future<People?> getCurrentPeople() async => getJsonTyped(
    'current',
    People.fromJson
  );

  Future<void> putCurrentPeople(People value) async => putJsonTyped(
    'current',
    value.toJson(),
  );
```
6. Use migrations between versions (the current version of the database is specified in the super constructor)
```dart
 @override
  Future<void> migrate(int oldVersion, int currentVersion) async {
    if (oldVersion < 2) {
      await delete('current');
    }
    return super.migrate(oldVersion, currentVersion);
  }
```
7. Initialize the class and be sure to call initAsync before using it!
```dart
Future<void> test() async {
  final dataSource = ExampleDataSource(secureStorage);
  await dataSource.initAsync();
  print(await dataSource.getCurrentPeople());
}
```
Here's what we'll get:
```dart

final class ExampleDataSource extends SecureDataSource {
  ExampleDataSource(super.secureStorage)
      : super(
          databaseName: 'example',
          databaseVersion: 1,
        );

  @override
  Future<void> migrate(int oldVersion, int currentVersion) async {
    if (oldVersion < 2) {
      await delete('current');
    }
    return super.migrate(oldVersion, currentVersion);
  }

  Future<String?> getLastEmail() async => read('last_email');

  Future<void> putLastEmail(String value) async =>
      write(key: 'last_email', value: value);

  Future<People?> getCurrentPeople() async =>
      getJsonTyped('current', People.fromJson);

  Future<void> putCurrentPeople(People value) async => putJsonTyped(
        'current',
        value.toJson(),
      );
}
```
Very simple and clean! 🌱
   
### Contributing 
Contributions are welcomed!
Here is a curated list of how you can help:
* Report bugs and scenarios that are difficult to implement
* Report parts of the documentation that are unclear
* Fix typos/grammar mistakes
* Update the documentation / add examples
* Implement new features by making a pull-request
