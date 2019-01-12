import 'package:path_to_regexp/path_to_regexp.dart';

void main() {
  // Parse a path into tokens, and extract parameters names.
  final parameters = <String>[];
  final tokens = parse(r'/user/:id(\d+)', parameters: parameters);
  print(parameters); // [id]

  // Create a regular expression from tokens.
  final regExp = tokensToRegExp(tokens);
  print(regExp.hasMatch('/user/12')); // true
  print(regExp.hasMatch('/user/alice')); // false

  // Extract parameter arguments from a match.
  final match = regExp.matchAsPrefix('/user/12');
  print(extract(parameters, match)); // {id: 12}

  // Create a path function from tokens.
  final toPath = tokensToFunction(tokens);
  print(toPath({'id': '12'})); // /user/12
}
