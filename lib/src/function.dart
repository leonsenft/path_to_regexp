import 'parse.dart';
import 'token.dart';

/// Generates a path by populating a path specification with [args].
///
/// The [args] should map parameter name to value.
///
/// Throws an [ArgumentError] if any required arguments are missing, or if any
/// arguments don't match their parameter's regular expression.
typedef PathFunction = String Function(Map<String, String> args);

/// Creates a [PathFunction] from a [path] specification.
PathFunction pathToFunction(String path) => tokensToFunction(parse(path));

/// Creates a [PathFunction] from [tokens].
PathFunction tokensToFunction(List<Token> tokens) {
  return (args) {
    final buffer = StringBuffer();
    for (final token in tokens) {
      buffer.write(token.toPath(args));
    }
    return buffer.toString();
  };
}
