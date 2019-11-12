import 'parse.dart';
import 'token.dart';

/// Creates a [RegExp] that matches a [path] specification.
///
/// See [parse] for details about the optional [parameters] parameter.
///
/// See [tokensToRegExp] for details about the optional [prefix] and
/// [caseSensitive] parameters and the return value.
RegExp pathToRegExp(
  String path, {
  List<String> parameters,
  bool prefix = false,
  bool caseSensitive = true,
}) =>
    tokensToRegExp(
      parse(path, parameters: parameters),
      prefix: prefix,
      caseSensitive: caseSensitive,
    );

/// Creates a [RegExp] from [tokens].
///
/// If [prefix] is true, the returned regular expression matches the beginning
/// of input until a delimiter or end of input. Otherwise it matches the entire
/// input.
///
/// The resulting [RegExp] will respect the [caseSensitive] parameter.
RegExp tokensToRegExp(
  List<Token> tokens, {
  bool prefix = false,
  bool caseSensitive = true,
}) {
  final buffer = StringBuffer('^');
  String lastPattern;
  for (final token in tokens) {
    lastPattern = token.toPattern();
    buffer.write(lastPattern);
  }
  if (!prefix) {
    buffer.write(r'$');
  } else if (lastPattern != null && !lastPattern.endsWith('/')) {
    // Match until a delimiter or end of input, unless
    //  (a) there are no tokens (matching the empty string), or
    //  (b) the last token itself ends in a delimiter
    // in which case, anything may follow.
    buffer.write(r'(?=/|$)');
  }
  return RegExp(buffer.toString(), caseSensitive: caseSensitive);
}
