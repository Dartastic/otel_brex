// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_brex_suppression.dart';

class BrexResult {
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

class BrexCallResult<T> {
  const BrexCallResult({required this.value, this.result});
  final T value;
  final BrexResult? result;
}

Future<T> tracedBrex<T>({
  required String operation,
  required Future<BrexCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (brexInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_brex');
  final span = t.startSpan('brex $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'brex')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.companyId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('brex.company.id', res.companyId!)]));
      }
      if (res.userId != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('user.id', res.userId!)]));
      }
      if (res.cardId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('brex.card.id', res.cardId!)]));
      }
      if (res.accountId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('brex.account.id', res.accountId!)]));
      }
      if (res.transactionId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('brex.transaction.id', res.transactionId!)]));
      }
      if (res.amount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('brex.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('brex.currency', res.currency!)]));
      }
      if (res.merchantCategory != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            'brex.merchant.category',
            res.merchantCategory!,
          )
        ]));
      }
      if (res.status != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('brex.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('brex.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
