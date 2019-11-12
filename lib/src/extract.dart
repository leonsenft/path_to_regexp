/// Extracts arguments from [match] and maps them by parameter name.
///
/// The [parameters] should originate from the same path specification used to
/// create the [RegExp] that produced the [match].
Map<String, String> extract(List<String> parameters, Match match) {
  final length = parameters.length;
  return {
    // Offset the group index by one since the first group is the entire match.
    for (var i = 0; i < length; ++i) parameters[i]: match.group(i + 1)
  };
}
