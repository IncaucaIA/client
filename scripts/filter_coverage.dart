import 'dart:io';

void main(List<String> args) {
  final inputFile = File('coverage/lcov.info');
  if (!inputFile.existsSync()) {
    print('Error: coverage/lcov.info not found');
    exit(1);
  }

  final lines = inputFile.readAsLinesSync();
  final filteredLines = <String>[];
  bool skipCurrentFile = false;

  final patternsToExclude = [
    'domain/',
    'domain\\',
    'firebase_options.dart',
  ];

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      final path = line.substring(3);
      skipCurrentFile = patternsToExclude.any((pattern) => path.contains(pattern));
    }

    if (!skipCurrentFile) {
      filteredLines.add(line);
    }

    if (line == 'end_of_record') {
      skipCurrentFile = false;
    }
  }

  inputFile.writeAsStringSync(filteredLines.join('\n'));
  print('Filtered coverage/lcov.info successfully.');
}
