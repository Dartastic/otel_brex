// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_brex/otel_brex.dart';
import 'package:test/test.dart';

void main() {
  group('otel_brex', () {
    test('suppression toggles in zone', () async {
      expect(brexInstrumentationSuppressed(), isFalse);
      await runWithoutBrexInstrumentationAsync(() async {
        expect(brexInstrumentationSuppressed(), isTrue);
      });
      expect(brexInstrumentationSuppressed(), isFalse);
    });

    test('BrexResult fields default null', () {
      const r = BrexResult();
      expect(r.statusCode, isNull);
    });
  });
}
