/// Extracts arguments from [match] and maps them by parameter name.
///
/// The [parameters] should originate from the same path specification used to
/// create the [RegExp] that produced the [match].
///
/// Optional [parameters] that weren't matched are omitted from the result.
Map<String, String> extract(List<String> parameters, Match match) {
  final args = <String, String>{};
  final length = parameters.length;
  for (var i = 0; i < length; ++i) {
    // Offset the group index by one since the first group is the entire match.
    final group = match.group(i + 1);
    if (group != null) {
      args[parameters[i]] = group;
    }
  }
  return args;
}
