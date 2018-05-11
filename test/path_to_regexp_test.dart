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

  group('optional parameter', () {
    tests(
      '/:key?',
      tokens: [
        parameter('key', optional: true),
      ],
      regExp: [
        matches('/foo', ['/foo', 'foo'], extracts: {'key': 'foo'}),
        matches('', ['', null]),
        mismatches('/foo/bar'),
        mismatches('/'),
      ],
      toPath: [
        returns(''),
        returns('/foo', given: {'key': 'foo'}),
      ],
    );
    tests(
      '/:key?/bar',
      tokens: [
        parameter('key', optional: true),
        path('/bar'),
      ],
      regExp: [
        matches('/bar', ['/bar', null]),
        matches('/foo/bar', ['/foo/bar', 'foo'], extracts: {'key': 'foo'}),
      ],
      toPath: [
        returns('/bar'),
        returns('/foo/bar', given: {'key': 'foo'}),
      ],
    );
    tests(
      '/:key?-bar',
      tokens: [
        parameter('key', optional: true, partial: true),
        path('-bar'),
      ],
      regExp: [
        matches('/-bar', ['/-bar', null]),
        matches('/foo-bar', ['/foo-bar', 'foo'], extracts: {'key': 'foo'}),
      ],
      toPath: [
        returns('/-bar'),
        returns('/foo-bar', given: {'key': 'foo'}),
      ],
    );
  });

  group('custom parameter', () {
    tests(
      r'/:key(\d+)',
      tokens: [
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
        parameter('key', partial: true, prefixed: false),
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
        parameter('key', partial: true, prefixed: false),
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
    tests(
      ':key?',
      tokens: [
        parameter('key', partial: true, prefixed: false, optional: true)
      ],
      regExp: [
        matches('foo', ['foo', 'foo'], extracts: {'key': 'foo'}),
        matches('', ['', null]),
        mismatches('/foo'),
        mismatches('foo/bar'),
      ],
      toPath: [
        returns(''),
        returns('foo', given: {'key': 'foo'}),
        throws(given: {'key': ''}),
      ],
    );
  });

  group('complex path', () {
    tests(
      '/:foo/:bar',
      tokens: [
        parameter('foo'),
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
        parameter('remote', pattern: r'([\w-.]+)'),
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
      '/:foo?bar',
      tokens: [
        parameter('foo', partial: true, optional: true),
        path('bar'),
      ],
      regExp: [
        matches('/foobar', ['/foobar', 'foo'], extracts: {'foo': 'foo'}),
        matches('/bar', ['/bar', null]),
      ],
      toPath: [
        returns('/bar'),
        returns('/foobar', given: {'foo': 'foo'}),
      ],
    );
    tests(
      r'/:type(video|audio|text):plus(\+.+)?',
      tokens: [
        parameter('type', partial: true, pattern: '(video|audio|text)'),
        parameter(
          'plus',
          partial: true,
          pattern: r'(\+.+)',
          prefixed: false,
          optional: true,
        ),
      ],
      regExp: [
        matches(
          '/video',
          ['/video', 'video', null],
          extracts: {'type': 'video'},
        ),
        matches(
          '/video+test',
          ['/video+test', 'video', '+test'],
          extracts: {'type': 'video', 'plus': '+test'},
        ),
        mismatches('/video+'),
      ],
      toPath: [
        returns('/video', given: {'type': 'video'}),
        throws(given: {'type': 'random'}),
      ],
    );
  });
}

void tests(
  String path, {
  bool prefix = false,
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

    final parsedRegExp = tokensToRegExp(parsedTokens, prefix: prefix);
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
  return new List<String>.generate(
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
    new RegExpCase(path, groups, extracts);

RegExpCase mismatches(String path) => new RegExpCase(path, null, null);

Matcher parameter(
  String name, {
  bool optional: false,
  bool partial: false,
  String pattern: '([^/]+?)',
  bool prefixed: true,
}) =>
    const TypeMatcher<ParameterToken>()
        .having((t) => t.name, 'name', name)
        .having((t) => t.optional, 'optional', optional)
        .having((t) => t.partial, 'partial', partial)
        .having((t) => t.pattern, 'pattern', pattern)
        .having((t) => t.prefixed, 'prefixed', prefixed);

Matcher path(String value) =>
    const TypeMatcher<PathToken>().having((t) => t.value, 'value', value);

ToPathCase returns(String path, {Map<String, String> given = const {}}) =>
    new ToPathCase(given, path);

ToPathCase throws({Map<String, String> given = const {}}) =>
    new ToPathCase(given, null);

class RegExpCase {
  final Map<String, String> args;
  final List<String> groups;
  final String path;

  RegExpCase(this.path, this.groups, this.args);

  bool get matches => groups != null;
}

class ToPathCase {
  final Map<String, String> args;
  final String path;

  ToPathCase(this.args, this.path);
}
