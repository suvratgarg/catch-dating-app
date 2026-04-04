// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  text: json['text'] as String,
  sentAt: const TimestampConverter().fromJson(json['sentAt'] as Timestamp),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'text': instance.text,
      'sentAt': const TimestampConverter().toJson(instance.sentAt),
    };
