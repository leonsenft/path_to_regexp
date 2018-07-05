# path\_to\_regexp

[![Pub](https://img.shields.io/pub/v/path_to_regexp.svg)](https://pub.dartlang.org/packages/path_to_regexp)

Converts a path such as `/user/:id` into a regular expression.

## Matching

`pathToRegExp()` converts a path specification into a regular expression that
matches conforming paths.

```dart
final regExp = pathToRegExp('/user/:id');
regExp.hasMatch('/user/12'); // => true
regExp.hasMatch('/user/alice'); // => true
```

### Custom Parameters

By default, parameters match anything until the next delimiter. This behavior
can be customized by specifying a regular expression in parentheses following
a parameter name.

```dart
final regExp = pathToRegExp(r'/user/:id(\d+)');
regExp.hasMatch('/user/12'); // => true
regExp.hasMatch('/user/alice'); // => false
```

### Optional Parameters

A parameter can be made optional by appending a `?`.

```dart
final regExp = pathToRegExp(r'/user/:id(\d+)?');
regExp.hasMatch('/user/12'); // => true
regExp.hasMatch('/user'); // => true
```

### Extracting Parameters

Parameters can be extracted from a path specification during conversion into a
regular expression.

```dart
final parameters = <String>[];
final regExp = pathToRegExp('/user/:id', parameters: parameters);
parameters; // => ['id']
```

### Extracting Arguments

`extract()` maps the parameters of a path specification to their corresponding
arguments in a match.

```dart
final parameters = <String>[];
final regExp = pathToRegExp('/user/:id', parameters: parameters);
final match = regExp.matchAsPrefix('/user/12');
extract(parameters, match); // => {'id': '12'}
```

Missing optional arguments are omitted from the results.

```dart
final parameters = <String>[];
final regExp = pathToRegExp('/user/:id?', parameters: parameters);
final match = regExp.matchAsPrefix('/user');
extract(parameters, match); // => {}
```

## Generating

`pathToFunction()` converts a path specification into a function that generates
matching paths.

```dart
final toPath = pathToFunction('/user/:id');
toPath({'id': '12'}); // => '/user/12'
```

Optional parameters may be omitted from the map of arguments.

```dart
final toPath = pathToFunction('/user/:id?');
toPath({}); // => '/user'
```

## Tokens

`parse()` converts a path specification into a list of tokens, which can be
used to create a regular expression or path generating function.

```dart
final tokens = parse('/users/:id');
final regExp = tokensToRegExp(tokens);
final toPath = tokensToFunction(tokens);
```

Similar to `pathToRegExp()`, parameters can also be extracted during parsing.

```dart
final parameters = <String>[];
final tokens = parse('/users/:id', parameters: parameters);
```

If you intend to match and generate paths from the same path specification,
`parse()` and the token-based functions should be preferred to their path-based
counterparts. This is because the token-based functions can reuse the same
tokens, whereas each path-based function must parse the path specification anew.

## Options

### Prefix Matching

By default, a regular expression created by `pathToRegExp` or `tokensToRegExp`
matches the entire input. However, if the optional `prefix` argument is true, it
may also match as a prefix until a delimiter.

```dart
final regExp = pathToRegExp('/user/:id', prefix: true);
regExp.hasMatch('/user/12/details'); // => true
```

## Demo

Try the [path\_to\_regexp\_demo][path-to-regexp-demo] to experiment with this
library.

## Credit

This package is heavily inspired by its JavaScript namesake
[path-to-regexp][path-to-regexp-js].

[path-to-regexp-demo]: https://path-to-regexp.firebaseapp.com
[path-to-regexp-js]: https://github.com/pillarjs/path-to-regexp
