import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

enum PaymentStatus implements Labelled {
  pending('Pending'),
  completed('Completed'),
  failed('Failed'),
  refunded('Refunded');

  const PaymentStatus(this.label);
  @override
  final String label;
}

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    @JsonKey(includeToJson: false) required String id,
    required String userId,
    required String orderId,
    required String paymentId,
    required String activityId,
    required int amount, // in paise
    @Default('INR') String currency,
    required PaymentStatus status,
    @Default(false) bool signUpFailed,
    @TimestampConverter() required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
