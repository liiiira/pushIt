import 'dart:io';

/// The automated checks of docs/CONVENTIONS.md §8, as pure functions over
/// source text, so each rule can be tested on samples as well as on `lib/`.
abstract final class Rules {
  static const flutterInDomain = 'no Flutter import in lib/domain';
  static const rawColour =
      'no Color(0x…), Color.from…() or Colors. outside the tokens';
  static const rawTextStyle = 'no TextStyle( outside lib/core/design_system';
  static const literalText = "no Text('literal'): use context.l10n";
  static const deepFeatureImport =
      'import another feature only through its barrel';
}

final class SourceFile {
  const new(this.path, this.content);

  /// Relative to the package root, with forward slashes: `lib/…`.
  final String path;
  final String content;
}

final class Violation {
  const new(this.path, this.line, this.rule);

  final String path;
  final int line;
  final String rule;

  @override
  String toString() => '$path:$line: $rule';
}

const _generatedDir = 'lib/core/l10n/generated/';
const _domainDir = 'lib/domain/';
const _tokensDir = 'lib/core/design_system/tokens/';
const _designSystemDir = 'lib/core/design_system/';
const _sharedWidgetsDir = 'lib/core/design_system/widgets/';
const _featuresDir = 'lib/features/';

final _flutterImport = RegExp(
  r'''^\s*(?:import|export)\s+['"](?:package:(?:flutter|flutter_\w+|material_ui|cupertino_ui)/|dart:ui['"])''',
  multiLine: true,
);
final _rawColour = RegExp(
  r'\bColor\(\s*0x|\bColor\.from(?:ARGB|RGBO)\(|\bColors\.',
);
final _rawTextStyle = RegExp(r'\bTextStyle\(');
final _literalText = RegExp(r'''\bText\(\s*r?['"]''');
final _featureImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]package:pushit/features/(\w+)/([^'"]+)['"]''',
  multiLine: true,
);
final _featureOfPath = RegExp(r'^lib/features/(\w+)/');

/// Every violation in [file].
List<Violation> checkSource(SourceFile file) {
  final path = file.path;
  final code = _withoutCommentLines(file.content);
  final violations = <Violation>[];

  void flag(RegExp pattern, String rule) {
    for (final match in pattern.allMatches(code)) {
      violations.add(Violation(path, _lineOf(code, match.start), rule));
    }
  }

  if (path.startsWith(_domainDir)) flag(_flutterImport, Rules.flutterInDomain);
  if (!path.startsWith(_tokensDir)) flag(_rawColour, Rules.rawColour);
  if (!path.startsWith(_designSystemDir)) {
    flag(_rawTextStyle, Rules.rawTextStyle);
  }
  if (path.startsWith(_featuresDir) || path.startsWith(_sharedWidgetsDir)) {
    flag(_literalText, Rules.literalText);
  }

  final ownFeature = _featureOfPath.firstMatch(path)?.group(1);
  for (final match in _featureImport.allMatches(code)) {
    final feature = match.group(1);
    final rest = match.group(2);
    if (feature != ownFeature && rest != '$feature.dart') {
      violations.add(
        Violation(path, _lineOf(code, match.start), Rules.deepFeatureImport),
      );
    }
  }
  return violations;
}

/// Checks every Dart file under `lib/`, except the gen-l10n output.
List<Violation> scanLib() {
  final files =
      Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.path.replaceAll(r'\', '/'))
          .where((path) => !path.startsWith(_generatedDir))
          .toList()
        ..sort();
  return [
    for (final path in files)
      ...checkSource(SourceFile(path, File(path).readAsStringSync())),
  ];
}

/// Blanks `//` comment lines (doc comments included), keeping line numbers.
String _withoutCommentLines(String content) => content
    .split('\n')
    .map((line) => line.trimLeft().startsWith('//') ? '' : line)
    .join('\n');

int _lineOf(String code, int offset) =>
    '\n'.allMatches(code.substring(0, offset)).length + 1;
