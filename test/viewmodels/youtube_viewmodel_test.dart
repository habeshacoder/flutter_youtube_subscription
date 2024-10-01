import 'package:flutter_test/flutter_test.dart';
import 'package:myappstaked/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('YoutubeViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
