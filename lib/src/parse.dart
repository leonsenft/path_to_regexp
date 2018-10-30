import 'escape.dart';
import 'token.dart';

/// The default pattern used for matching parameters.
const _defaultPattern = '([^/]+?)';

/// The regular expression used to extract parameters from a path specification.
///
/// Capture groups:
///   1. The parameter name.
///   2. An optional pattern.
final _parameterRegExp = RegExp(
    /* (1) */ r':(\w+)'
    /* (2) */ r'(\((?:\\.|[^\\()])+\))?');

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
    final name = match[1];
    final pattern = match[2] != null ? escapeGroup(match[2]) : _defaultPattern;
    tokens.add(ParameterToken(name, pattern: pattern));
    parameters?.add(name);
    start = match.end;
  }
  if (start < length) {
    tokens.add(PathToken(path.substring(start)));
  }
  return tokens;
}
