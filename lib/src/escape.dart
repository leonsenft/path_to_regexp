/// Matches any characters that could prevent a group from capturing.
final _groupRegExp = RegExp(r'[:=!]');

/// Escapes a single character [match].
String _escape(Match match) => '\\${match[0]}';

/// Escapes a [group] to ensure it remains a capturing group.
///
/// This prevents turning the group into a non-capturing group `(?:...)`, a
/// lookahead `(?=...)`, or a negative lookahead `(?!...)`. Allowing these
/// patterns would break the assumption used to map parameter names to match
/// groups.
String escapeGroup(String group) =>
    group.replaceFirstMapped(_groupRegExp, _escape);
