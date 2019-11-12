import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:test/test.dart';

void main() {
  group('simple path', () {
    tests(
      '/',
      tokens: [
        path('/'),
      ],
      regExp: [
        matches('/', ['/']),
        mismatches('/foo'),
      ],
      toPath: [
        returns('/'),
        returns('/', given: {'id': '12'}),
      ],
    );
    tests(
      '/foo',
      tokens: [
        path('/foo'),
      ],
      regExp: [
        matches('/foo', ['/foo']),
        mismatches('/bar'),
        mismatches('/foo/bar'),
      ],
      toPath: [
        returns('/foo'),
      ],
    );
    tests(
      '/foo/',
      tokens: [
        path('/foo/'),
      ],
      regExp: [
        matches('/foo/', ['/foo/']),
        mismatches('/foo'),
      ],
      toPath: [
        returns('/foo/'),
      ],
    );
    tests(
      '/:key',
      tokens: [
        path('/'),
        parameter('key'),
      ],
      regExp: [
        matches('/foo', ['/foo', 'foo'], extracts: {'key': 'foo'}),
        matches(
          '/foo.json',
          ['/foo.json', 'foo.json'],
          extracts: {'key': 'foo.json'},
        ),
        matches(
          '/foo%2Fbar',
          ['/foo%2Fbar', 'foo%2Fbar'],
          extracts: {'key': 'foo%2Fbar'},
        ),
        matches(
          r'/;,:@&=+$-_.!~*()',
          [r'/;,:@&=+$-_.!~*()', r';,:@&=+$-_.!~*()'],
          extracts: {'key': r';,:@&=+$-_.!~*()'},
        ),
        mismatches('/foo/bar'),
      ],
      toPath: [
        returns('/foo', given: {'key': 'foo'}),
      ],
    );
  });

  group('prefix path', () {
    tests(
      '',
      prefix: true,
      regExp: [
        matches('', ['']),
        matches('/', ['']),
        matches('foo', ['']),
        matches('/foo', ['']),
        matches('/foo/', ['']),
      ],
      toPath: [
        returns(''),
      ],
    );
    tests(
      '/foo',
      prefix: true,
      tokens: [
        path('/foo'),
      ],
      regExp: [
        matches('/foo', ['/foo']),
        matches('/foo/', ['/foo']),
        matches('/foo/bar', ['/foo']),
        mismatches('/bar'),
      ],
      toPath: [
        returns('/foo'),
      ],
    );
    tests(
      '/foo/',
      prefix: true,
      tokens: [
        path('/foo/'),
      ],
      regExp: [
        matches('/foo/bar', ['/foo/']),
        matches('/foo//', ['/foo/']),
        matches('/foo//bar', ['/foo/']),
        mismatches('/foo'),
      ],
      toPath: [
        returns('/foo/'),
      ],
    );
    tests(
      '/:key',
      prefix: true,
      tokens: [
        path('/'),
        parameter('key'),
      ],
      regExp: [
        matches('/foo', ['/foo', 'foo'], extracts: {'key': 'foo'}),
        matches(
          '/foo.json',
          ['/foo.json', 'foo.json'],
          extracts: {'key': 'foo.json'},
        ),
        matches('/foo//', ['/foo', 'foo'], extracts: {'key': 'foo'}),
      ],
      toPath: [
        returns('/foo', given: {'key': 'foo'}),
        throws(),
      ],
    );
    tests(
      '/:key/',
      prefix: true,
      tokens: [
        path('/'),
        parameter('key'),
        path('/'),
      ],
      regExp: [
        matches('/foo/', ['/foo/', 'foo'], extracts: {'key': 'foo'}),
        mismatches('/foo'),
      ],
      toPath: [
        returns('/foo/', given: {'key': 'foo'}),
      ],
    );
  });

  group('custom parameter', () {
    tests(
      r'/:key(\d+)',
      tokens: [
        path('/'),
        parameter('key', pattern: r'(\d+)'),
      ],
      regExp: [
        matches('/12', ['/12', '12'], extracts: {'key': '12'}),
        mismatches('/foo'),
        mismatches('/foo/12'),
      ],
      toPath: [
        returns('/12', given: {'key': '12'}),
        throws(given: {'key': 'foo'}),
      ],
    );
    tests(
      r'/:key(\d+)',
      prefix: true,
      tokens: [
        path('/'),
        parameter('key', pattern: r'(\d+)'),
      ],
      regExp: [
        matches('/12', ['/12', '12'], extracts: {'key': '12'}),
        matches('/12/foo', ['/12', '12'], extracts: {'key': '12'}),
        mismatches('/foo'),
      ],
      toPath: [
        returns('/12', given: {'key': '12'}),
      ],
    );
    tests(
      '/:key(.*)',
      tokens: [
        path('/'),
        parameter('key', pattern: '(.*)'),
      ],
      regExp: [
        matches(
          '/foo/bar/baz',
          ['/foo/bar/baz', 'foo/bar/baz'],
          extracts: {'key': 'foo/bar/baz'},
        ),
        matches(
          r'/;,:@&=/+$-_.!/~*()',
          [r'/;,:@&=/+$-_.!/~*()', r';,:@&=/+$-_.!/~*()'],
          extracts: {'key': r';,:@&=/+$-_.!/~*()'},
        )
      ],
      toPath: [
        returns('/', given: {'key': ''}),
        returns('/foo', given: {'key': 'foo'}),
      ],
    );
    tests(
      '/:key([a-z]+)',
      tokens: [
        path('/'),
        parameter('key', pattern: '([a-z]+)'),
      ],
      regExp: [
        matches('/foo', ['/foo', 'foo'], extracts: {'key': 'foo'}),
        mismatches('/12'),
      ],
      toPath: [
        returns('/foo', given: {'key': 'foo'}),
        throws(),
        throws(given: {'key': '12'}),
      ],
    );
    tests(
      '/:key(foo|bar)',
      tokens: [
        path('/'),
        parameter('key', pattern: '(foo|bar)'),
      ],
      regExp: [
        matches('/foo', ['/foo', 'foo'], extracts: {'key': 'foo'}),
        matches('/bar', ['/bar', 'bar'], extracts: {'key': 'bar'}),
        mismatches('/baz'),
      ],
      toPath: [
        returns('/foo', given: {'key': 'foo'}),
        returns('/bar', given: {'key': 'bar'}),
        throws(given: {'key': 'baz'}),
      ],
    );
  });

  group('relative path', () {
    tests(
      'foo',
      tokens: [
        path('foo'),
      ],
      regExp: [
        matches('foo', ['foo']),
        mismatches('/foo'),
      ],
      toPath: [
        returns('foo'),
      ],
    );
    tests(
      ':key',
      tokens: [
        parameter('key'),
      ],
      regExp: [
        matches('foo', ['foo', 'foo'], extracts: {'key': 'foo'}),
        mismatches('/foo'),
      ],
      toPath: [
        returns('foo', given: {'key': 'foo'}),
        throws(),
        throws(given: {'key': ''}),
      ],
    );
    tests(
      ':key',
      prefix: true,
      tokens: [
        parameter('key'),
      ],
      regExp: [
        matches('foo', ['foo', 'foo'], extracts: {'key': 'foo'}),
        matches('foo/bar', ['foo', 'foo'], extracts: {'key': 'foo'}),
        mismatches('/foo'),
      ],
      toPath: [
        returns('foo', given: {'key': 'foo'}),
      ],
    );
  });

  group('complex path', () {
    tests(
      '/:foo/:bar',
      tokens: [
        path('/'),
        parameter('foo'),
        path('/'),
        parameter('bar'),
      ],
      regExp: [
        matches(
          '/foo/bar',
          ['/foo/bar', 'foo', 'bar'],
          extracts: {'foo': 'foo', 'bar': 'bar'},
        ),
      ],
      toPath: [
        returns('/baz/qux', given: {'foo': 'baz', 'bar': 'qux'}),
      ],
    );
    tests(
      r'/:remote([\w-.]+)/:user([\w-]+)',
      tokens: [
        path('/'),
        parameter('remote', pattern: r'([\w-.]+)'),
        path('/'),
        parameter('user', pattern: r'([\w-]+)'),
      ],
      regExp: [
        matches(
          '/endpoint/user',
          ['/endpoint/user', 'endpoint', 'user'],
          extracts: {'remote': 'endpoint', 'user': 'user'},
        ),
        matches(
          '/endpoint/user-name',
          ['/endpoint/user-name', 'endpoint', 'user-name'],
          extracts: {'remote': 'endpoint', 'user': 'user-name'},
        ),
        matches(
          '/foo.bar/user-name',
          ['/foo.bar/user-name', 'foo.bar', 'user-name'],
          extracts: {'remote': 'foo.bar', 'user': 'user-name'},
        ),
      ],
      toPath: [
        returns('/foo/bar', given: {'remote': 'foo', 'user': 'bar'}),
        returns('/foo.bar/baz', given: {'remote': 'foo.bar', 'user': 'baz'}),
      ],
    );
    tests(
      r'/:type(video|audio|text):plus(\+.+)',
      tokens: [
        path('/'),
        parameter('type', pattern: '(video|audio|text)'),
        parameter('plus', pattern: r'(\+.+)'),
      ],
      regExp: [
        matches(
          '/video+test',
          ['/video+test', 'video', '+test'],
          extracts: {'type': 'video', 'plus': '+test'},
        ),
        mismatches('/video'),
        mismatches('/video+'),
      ],
      toPath: [
        returns('/audio+test', given: {'type': 'audio', 'plus': '+test'}),
        throws(given: {'type': 'video'}),
        throws(given: {'type': 'random'}),
      ],
    );
    // Case insensitive path matching.
    tests(r'/insensitive-token/:foo', caseSensitive: false, tokens: [
      path('/insensitive-token/'),
      parameter('foo')
    ], regExp: [
      matches(
        '/insensitive-token/1',
        ['/insensitive-token/1', '1'],
        extracts: {'foo': '1'},
      ),
      matches(
        '/INSENSITIVE-TOKEN/1',
        ['/INSENSITIVE-TOKEN/1', '1'],
        extracts: {'foo': '1'},
      )
    ], toPath: [
      returns(
        '/insensitive-token/1',
        given: {'foo': '1'},
      ),
    ]);
  });
}

void tests(
  String path, {
  bool prefix = false,
  bool caseSensitive = true,
  List<Matcher> tokens = const [],
  List<RegExpCase> regExp = const [],
  List<ToPathCase> toPath = const [],
}) {
  group('"$path"', () {
    final parameters = <String>[];
    final parsedTokens = parse(path, parameters: parameters);
    test('should parse', () {
      expect(parsedTokens, tokens);
    });

    final parsedRegExp = tokensToRegExp(
      parsedTokens,
      prefix: prefix,
      caseSensitive: caseSensitive,
    );
    for (final matchCase in regExp) {
      final path = matchCase.path;
      final match = parsedRegExp.matchAsPrefix(path);
      if (matchCase.matches) {
        test('should match "$path"', () {
          expect(_groupsOf(match), matchCase.groups);
        });
        test('should extract arguments', () {
          expect(extract(parameters, match), matchCase.args);
        });
      } else {
        test('should not match "$path"', () {
          expect(match, isNull);
        });
      }
    }

    final parsedFunction = tokensToFunction(parsedTokens);
    for (final toPathCase in toPath) {
      if (toPathCase.path != null) {
        test('should return "${toPathCase.path}" given ${toPathCase.args}', () {
          expect(parsedFunction(toPathCase.args), toPathCase.path);
        });
      } else {
        test('should throw given ${toPathCase.args}', () {
          expect(() => parsedFunction(toPathCase.args), throwsArgumentError);
        });
      }
    }
  });
}

List<String> _groupsOf(Match match) {
  return List<String>.generate(
    match.groupCount + 1,
    (i) => match.group(i),
    growable: false,
  );
}

RegExpCase matches(
  String path,
  List<String> groups, {
  Map<String, String> extracts = const {},
}) =>
    RegExpCase(path, groups, extracts);

RegExpCase mismatches(String path) => RegExpCase(path, null, null);

Matcher parameter(String name, {String pattern = '([^/]+?)'}) =>
    const TypeMatcher<ParameterToken>()
        .having((t) => t.name, 'name', name)
        .having((t) => t.pattern, 'pattern', pattern);

Matcher path(String value) =>
    const TypeMatcher<PathToken>().having((t) => t.value, 'value', value);

ToPathCase returns(String path, {Map<String, String> given = const {}}) =>
    ToPathCase(given, path);

ToPathCase throws({Map<String, String> given = const {}}) =>
    ToPathCase(given, null);

class RegExpCase {
  RegExpCase(this.path, this.groups, this.args);

  final Map<String, String> args;
  final List<String> groups;
  final String path;

  bool get matches => groups != null;
}

class ToPathCase {
  ToPathCase(this.args, this.path);

  final Map<String, String> args;
  final String path;
}
