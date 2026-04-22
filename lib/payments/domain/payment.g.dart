// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  userId: json['userId'] as String,
  orderId: json['orderId'] as String,
  paymentId: json['paymentId'] as String,
  runId: json['runId'] as String,
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String? ?? 'INR',
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  signUpFailed: json['signUpFailed'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'userId': instance.userId,
  'orderId': instance.orderId,
  'paymentId': instance.paymentId,
  'runId': instance.runId,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'signUpFailed': instance.signUpFailed,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};
