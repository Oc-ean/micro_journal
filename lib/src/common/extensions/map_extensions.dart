extension MapExtensions on Map {
  Map<K, V> removeNullValues<K, V>() {
    final filteredEntries = entries
        .where(
          (element) => element.value != null,
        )
        .map(
          (e) => MapEntry<K, V>(e.key as K, e.value as V),
        );

    return Map<K, V>.fromEntries(filteredEntries);
  }
}
