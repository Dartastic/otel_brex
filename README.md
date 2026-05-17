# otel_brex

Dartastic OpenTelemetry bridge for Brex (corporate cards + spend mgmt).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_brex/otel_brex.dart';

await tracedBrex<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return BrexCallResult(value: r, result: BrexResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutBrexInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
