## 0.3.1 
* Upgrade flutter_secure_storage version to ">=8.0.0 <10.0.0"

## 0.3.0
* Add getBool, putBool, getInt, putBool methods for new PersistenceBaseTypesResolver. It can be used in any datasources.
* Add getJsonListTyped and putJsonListTyped on PersistenseJsonResolver.

## 0.2.0

* Add the getExpired, putExpired, getExpiredTyped and putExpiredTyped methods for new expired system to the data sources
* Fix typos
* Updating the architecture to the implementation of "PersistenceInterface" and adding logic through mixins "PersistenceMigrationsResolver", "PersistenceExpiredSystemResolver", "PersistenseJsonResolver".

## 0.1.1

**Breaking changes:**
* Rename "write" method "put"
* Rename "read" method "get"
---
* Fix typos


## 0.1.0

* Initial version of this package
