import 'escape.dart';
import 'token.dart';

/// The default pattern used for matching parameters.
const _defaultPattern = '([^/]+?)';

/// The regular expression used to extract parameters from a path specification.
///
/// Capture groups:
///   1. An optional leading '/'.
///   2. The parameter name.
///   3. An optional pattern.
///   4. An optional quantifier.
final _parameterRegExp = RegExp(
    /* (1) */ '(/)?'
    /* (2) */ r':(\w+)'
    /* (3) */ r'(\((?:\\.|[^\\()])+\))?'
    /* (4) */ r'(\?)?');

/// The Unicode code point for '/'.
const _slash = 0x2f;

/// Parses a [path] specification.
///
/// Parameter names are added, in order, to [parameters] if provided.
List<Token> parse(String path, {List<String> parameters}) {
  final length = path.length;
  final matches = _parameterRegExp.allMatches(path);
  final tokens = <Token>[];
  var start = 0;
  for (final match in matches) {
    if (match.start > start) {
      tokens.add(PathToken(path.substring(start, match.start)));
    }
    final prefixed = match[1] != null;
    final name = match[2];
    final pattern = match[3] != null ? escapeGroup(match[3]) : _defaultPattern;
    final optional = match[4] != null;
    final end = match.end;
    final partial = !prefixed || end < length && path.codeUnitAt(end) != _slash;
    tokens.add(ParameterToken(
      name,
      optional: optional,
      partial: partial,
      pattern: pattern,
      prefixed: prefixed,
    ));
    parameters?.add(name);
    start = end;
  }
  if (start < length) {
    tokens.add(PathToken(path.substring(start)));
  }
  return tokens;
}
