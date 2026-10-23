// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_brex/otel_brex.dart';

/// Traces Brex calls with OpenTelemetry.
///
/// `otel_brex` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Brex call in
/// [tracedBrex]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'brex-example');

  // Traces a Brex call.
  final brexId = await tracedBrex<String>(
    operation: 'create',
    invoke: () async {
      // Make the Brex call here, then report what it returned.
      const id = 'brex_8f3a2c';
      return const BrexCallResult(
          value: id,
          result: BrexResult(
              companyId: 'company_8f3a2c',
              userId: 'user_8f3a2c',
              cardId: 'card_8f3a2c',
              accountId: 'account_8f3a2c',
              transactionId: 'transaction_8f3a2c',
              amount: 0.5,
              currency: 'usd',
              merchantCategory: 'example',
              status: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedBrex create returned $brexId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutBrexInstrumentationAsync.
  await runWithoutBrexInstrumentationAsync(
    () => tracedBrex<String>(
      operation: 'create',
      invoke: () async {
        const id = 'brex_8f3a2c';
        return const BrexCallResult(
            value: id,
            result: BrexResult(
                companyId: 'company_8f3a2c',
                userId: 'user_8f3a2c',
                cardId: 'card_8f3a2c',
                accountId: 'account_8f3a2c',
                transactionId: 'transaction_8f3a2c',
                amount: 0.5,
                currency: 'usd',
                merchantCategory: 'example',
                status: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
