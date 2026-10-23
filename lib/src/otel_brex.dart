// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_brex_suppression.dart';

class BrexResult {
  /// Creates a result.
  const BrexResult({
    this.companyId,
    this.userId,
    this.cardId,
    this.accountId,
    this.transactionId,
    this.amount,
    this.currency,
    this.merchantCategory,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? companyId;
  final String? userId;
  final String? cardId;
  final String? accountId;
  final String? transactionId;
  final double? amount;
  final String? currency;
  final String? merchantCategory;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class BrexCallResult<T> {
  /// Creates a call result.
  const BrexCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final BrexResult? result;
}

Future<T> tracedBrex<T>({
  required String operation,
  required Future<BrexCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (brexInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_brex');
  final span = t.startSpan('brex $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'brex')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.companyId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('brex.company.id', res.companyId!)]));
      }
      if (res.userId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('user.id', res.userId!)]));
      }
      if (res.cardId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('brex.card.id', res.cardId!)]));
      }
      if (res.accountId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('brex.account.id', res.accountId!)]));
      }
      if (res.transactionId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('brex.transaction.id', res.transactionId!)
        ]));
      }
      if (res.amount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('brex.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('brex.currency', res.currency!)]));
      }
      if (res.merchantCategory != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'brex.merchant.category',
            res.merchantCategory!,
          )
        ]));
      }
      if (res.status != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('brex.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('brex.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'brex.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
