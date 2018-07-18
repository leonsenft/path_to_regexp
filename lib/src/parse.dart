import 'escape.dart';
import 'token.dart';

/// The default pattern used for matching parameters.
const _defaultPattern = '([^/]+?)';

/// The regular expression used to extract wildcards and parameters.
///
/// Capture groups:
///   1. A wildcard '*'.
///   2. An optional leading '/'.
///   3. The parameter name.
///   4. An optional pattern.
///   5. An optional quantifier.
final _parameterRegExp = RegExp(
    /* (1) */ r'(\*)'
    '|'
    '(?:'
    /* (2) */ '(/)?'
    /* (3) */ r':(\w+)'
    /* (4) */ r'(\((?:\\.|[^\\()])+\))?'
    /* (5) */ r'(\?)?'
    ')');

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
    start = match.end;
    if (match[1] != null) {
      tokens.add(WildcardToken());
    } else {
      final prefixed = match[2] != null;
      final name = match[3];
      final pattern =
          match[4] != null ? escapeGroup(match[4]) : _defaultPattern;
      final optional = match[5] != null;
      final partial =
          !prefixed || start < length && path.codeUnitAt(start) != _slash;
      tokens.add(ParameterToken(
        name,
        optional: optional,
        partial: partial,
        pattern: pattern,
        prefixed: prefixed,
      ));
      parameters?.add(name);
    }
  }
  if (start < length) {
    tokens.add(PathToken(path.substring(start)));
  }
  return tokens;
}
