import 'escape.dart';

/// The base type of all tokens produced by a path specification.
abstract class Token {
  /// Returns the path representation of this given [args].
  String toPath(Map<String, String> args);

  /// Returns the regular expression pattern this matches.
  String toPattern();
}

/// Corresponds to a parameter of a path specification.
class ParameterToken implements Token {
  /// The parameter name.
  final String name;

  /// Whether the parameter may be omitted from the match.
  final bool optional;

  /// Whether the parameter is a partial path segment.
  final bool partial;

  /// The regular expression pattern this matches.
  final String pattern;

  /// Whether the parameter is prefixed with a '/'.
  final bool prefixed;

  /// The regular expression compiled from [pattern].
  ///
  /// Initialized lazily to validate [toPath] arguments.
  RegExp _regExp;

  /// Creates a parameter token for [name].
  ParameterToken(
    this.name, {
    this.optional: false,
    this.partial: false,
    this.pattern: r'([^/]+?)',
    this.prefixed: true,
  });

  @override
  String toPath(Map<String, String> args) {
    if (args.containsKey(name)) {
      final value = args[name];
      _regExp ??= RegExp('^$pattern\$');
      if (!_regExp.hasMatch(value)) {
        throw ArgumentError.value('$args', 'args',
            'Expected "$name" to match "$pattern", but got "$value"');
      }
      return prefixed ? '/$value' : value;
    } else if (optional) {
      return partial && prefixed ? '/' : '';
    } else {
      throw ArgumentError.value('$args', 'args', 'Expected key "$name"');
    }
  }

  @override
  String toPattern() {
    final result = prefixed ? '/$pattern' : pattern;
    if (!optional) {
      return result;
    } else if (partial) {
      return '$result?';
    } else {
      return '(?:$result)?';
    }
  }
}

/// Corresponds to a non-parameterized section of a path specification.
class PathToken implements Token {
  /// A substring of the path specification.
  final String value;

  /// Creates a path token with [value].
  PathToken(this.value);

  @override
  String toPath(_) => value;

  @override
  String toPattern() => escapePath(value);
}

/// Corresponds to a wildcard '*' that matches anything.
class WildcardToken implements Token {
  @override
  String toPath(_) => '';

  @override
  String toPattern() => '.*';
}
