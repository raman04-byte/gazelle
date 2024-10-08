import 'dart:io';

import 'package:gazelle_cli/commands/dockerize/create_docker_files.dart';
import 'package:test/test.dart';

void main() {
  group("CreateDockerFiles tests", () {
    // Arrange
    const mainFilePath = "bin/main.dart";
    const exposedPort = 8080;
    test("Should return Dockerfile contents", () {
      // Act
      final result = generateDockerFileContent(
        mainFilePath: mainFilePath,
        exposedPort: exposedPort,
      );

      // Assert
      expect(result.contains(mainFilePath), isTrue);
      expect(result.contains("$exposedPort"), isTrue);
    });

    test("Should create docker files", () async {
      // Arrange
      const path = "tmp/docker_files_tests";

      try {
        await Directory(path).delete(recursive: true);
      } catch (_) {
        print("$path does not exist, creating it now.");
      }

      await Directory(path).create(recursive: true);

      // Act
      await createDockerFiles(
        path: path,
        mainFilePath: mainFilePath,
        exposedPort: exposedPort,
      );

      // Assert
      expect(await File("$path/.dockerignore").exists(), isTrue);
      expect(await File("$path/Dockerfile").exists(), isTrue);

      await Directory(path).delete(recursive: true);
    });
  });
}
