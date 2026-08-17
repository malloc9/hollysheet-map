import '../models/user.dart';

/// Represents a nationality and how many users share it.
class NationalityCount {
  final String nationality;
  final int count;

  NationalityCount({required this.nationality, required this.count});
}

/// Groups users by nationality and returns counts sorted descending.
///
/// Users without a nationality (null or empty string) are grouped
/// under "Not specified".
List<NationalityCount> groupByNationality(List<User> users) {
  final Map<String, int> counts = {};

  for (final user in users) {
    final nationality = user.nationality?.trim();
    if (nationality == null || nationality.isEmpty) {
      counts.update('Not specified', (v) => v + 1, ifAbsent: () => 1);
    } else {
      counts.update(nationality, (v) => v + 1, ifAbsent: () => 1);
    }
  }

  return counts.entries
      .map((e) => NationalityCount(nationality: e.key, count: e.value))
      .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
}
