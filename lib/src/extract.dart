/// Extracts arguments from [match] and maps them by parameter name.
///
/// The [parameters] should originate from the same path specification used to
/// create the [RegExp] that produced the [match].
Map<String, String> extract(List<String> parameters, Match match) {
  final args = <String, String>{};
  final length = parameters.length;
  for (var i = 0; i < length; ++i) {
    // Offset the group index by one since the first group is the entire match.
    args[parameters[i]] = match.group(i + 1);
  }
  return args;
}
