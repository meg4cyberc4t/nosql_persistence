const double _deletedRatio = 0.15;
const int _deletedThreshold = 60;

/// Default compaction strategy compacts if 15% of total values and at least 60
/// values have been deleted
bool defaultCompactionStrategy(int entries, int deletedEntries) =>
    deletedEntries > _deletedThreshold &&
    deletedEntries / entries > _deletedRatio;
