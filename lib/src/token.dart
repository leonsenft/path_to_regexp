/// The base type of all tokens produced by a path specification.
abstract class Token {
  /// Returns the path representation of this given [args].
  String toPath(Map<String, String> args);

  /// Returns the regular expression pattern this matches.
  String toPattern();
}

/// Corresponds to a parameter of a path specification.
class ParameterToken implements Token {
  /// Creates a parameter token for [name].
  ParameterToken(this.name, {this.pattern = r'([^/]+?)'});

  /// The parameter name.
  final String name;

  /// The regular expression pattern this matches.
  final String pattern;

  /// The regular expression compiled from [pattern].
  ///
  /// Initialized lazily to validate [toPath] arguments.
  RegExp _regExp;

  @override
  String toPath(Map<String, String> args) {
    if (args.containsKey(name)) {
      final value = args[name];
      _regExp ??= RegExp('^$pattern\$');
      if (!_regExp.hasMatch(value)) {
        throw ArgumentError.value('$args', 'args',
            'Expected "$name" to match "$pattern", but got "$value"');
      }
      return value;
    } else {
      throw ArgumentError.value('$args', 'args', 'Expected key "$name"');
    }
  }

  @override
  String toPattern() => pattern;
}

/// Corresponds to a non-parameterized section of a path specification.
class PathToken implements Token {
  /// Creates a path token with [value].
  PathToken(this.value);

  /// A substring of the path specification.
  final String value;

  @override
  String toPath(_) => value;

  @override
  String toPattern() => RegExp.escape(value);
}
