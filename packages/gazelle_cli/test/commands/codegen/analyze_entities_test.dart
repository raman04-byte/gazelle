import 'dart:io';

import 'package:gazelle_cli/commands/codegen/analyze_entities.dart';
import 'package:test/test.dart';
import '../../commons/constants/constants.dart';


void main() {
  group('Analyze tests', () {
    test('Should analyze some dart classes', () async {
      // Arrange
      final entitiesDirectoryPath = "tmp/analyze_tests/entities";
      final entitiesDirectory = Directory(entitiesDirectoryPath);
      if (entitiesDirectory.existsSync()) {
        entitiesDirectory.deleteSync(recursive: true);
      }
      entitiesDirectory.createSync(recursive: true);
      final userFile = File("$entitiesDirectoryPath/user.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(TestStrings.analyzeEntitiesUserClass);
      final postFile = File("$entitiesDirectoryPath/post.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(TestStrings.analyzeEntitiesPostClass);

      // Act
      final result = await analyzeEntities(entitiesDirectory);

      // Assert
      final userDefinition = result
          .where((e) => e.fileName == userFile.absolute.path)
          .singleOrNull;
      final postDefinition = result
          .where((e) => e.fileName == postFile.absolute.path)
          .singleOrNull;

      expect(userDefinition, isNotNull);
      expect(postDefinition, isNotNull);

      final userClasses = userDefinition!.classes;
      final postClasses = postDefinition!.classes;

      expect(userClasses.length, 1);
      expect(postClasses.length, 1);

      final postImports = postDefinition.importsPaths;

      expect(postImports.length, 1);
      expect(postImports.first, "user.dart");

      // Tear down
      entitiesDirectory.deleteSync(recursive: true);
    });
  });
}
