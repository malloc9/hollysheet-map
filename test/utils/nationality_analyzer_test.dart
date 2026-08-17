import 'package:flutter_test/flutter_test.dart';
import 'package:holysheet_map/utils/nationality_analyzer.dart';
import 'package:holysheet_map/models/user.dart';
import 'package:holysheet_map/models/role.dart';

void main() {
  group('groupByNationality', () {
    User buildUser(String uid, String? nationality) {
      return User(
        uid: uid,
        userId: uid,
        displayName: 'User $uid',
        approved: true,
        role: Role.member,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nationality: nationality,
      );
    }

    test('returns empty list when no users provided', () {
      expect(groupByNationality([]), isEmpty);
    });

    test('groups users by nationality', () {
      final users = [
        buildUser('1', 'American'),
        buildUser('2', 'American'),
        buildUser('3', 'British'),
      ];

      final result = groupByNationality(users);

      expect(result.length, 2);
      expect(result[0].nationality, 'American');
      expect(result[0].count, 2);
      expect(result[1].nationality, 'British');
      expect(result[1].count, 1);
    });

    test('sorts descending by count', () {
      final users = [
        buildUser('1', 'Canadian'),   // 1
        buildUser('2', 'American'),   // 3
        buildUser('3', 'American'),
        buildUser('4', 'American'),
        buildUser('5', 'British'),    // 2
        buildUser('6', 'British'),
      ];

      final result = groupByNationality(users);

      expect(result[0].nationality, 'American');
      expect(result[0].count, 3);
      expect(result[1].nationality, 'British');
      expect(result[1].count, 2);
      expect(result[2].nationality, 'Canadian');
      expect(result[2].count, 1);
    });

    test('groups users with null or empty nationality as "Not specified"', () {
      final users = [
        buildUser('1', null),
        buildUser('2', null),
        buildUser('3', ''),
        buildUser('4', ''),
        buildUser('5', 'American'),
      ];

      final result = groupByNationality(users);

      expect(result[0].nationality, 'Not specified');
      expect(result[0].count, 4);
      expect(result[1].nationality, 'American');
      expect(result[1].count, 1);
    });

    test('trims whitespace in nationality before grouping', () {
      final users = [
        buildUser('1', '  American '),
        buildUser('2', 'American'),
        buildUser('3', '  American '),
      ];

      final result = groupByNationality(users);

      expect(result.length, 1);
      expect(result[0].nationality, 'American'); // trimmed key
      expect(result[0].count, 3);
    });
  });
}
