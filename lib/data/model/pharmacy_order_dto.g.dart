// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmacy_order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PharmacyOrderDTOImpl _$$PharmacyOrderDTOImplFromJson(
        Map<String, dynamic> json) =>
    _$PharmacyOrderDTOImpl(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      driverId: json['driver_id'] as int?,
      senderId: json['sender_id'] as int?,
      recipientId: json['recipient_id'] as int?,
      status: json['status'] as int?,
      number: json['number'] as String?,
      container: json['container'] as int?,
      departureTime: json['departure_time'] as String?,
      fromAddress: json['from_address'] as String?,
      fromCityName: json['from_city_name'] as String?,
      toAddress: json['to_address'] as String?,
      toCityName: json['to_city_name'] as String?,
      amount: json['amount'] as String?,
      incomingNumber: json['incoming_number'] as String?,
      incomingDate: json['incoming_date'] as String?,
      bin: json['bin'] as String?,
      invoiceDate: json['invoice_date'] as String?,
      createdAt: json['created_at'] as String?,
      driver: json['driver'] == null
          ? null
          : User.fromJson(json['driver'] as Map<String, dynamic>),
      sender: json['sender'] == null
          ? null
          : CounteragentDTO.fromJson(json['sender'] as Map<String, dynamic>),
      recipient: json['recipient'] == null
          ? null
          : CounteragentDTO.fromJson(json['recipient'] as Map<String, dynamic>),
      totalStatus: json['total_status'] as int?,
      yandexTime: json['yandex_time'] as String?,
      refundStatus: json['refund_status'] as int?,
      provider: json['provider'] as String?,
    );

Map<String, dynamic> _$$PharmacyOrderDTOImplToJson(
        _$PharmacyOrderDTOImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'driver_id': instance.driverId,
      'sender_id': instance.senderId,
      'recipient_id': instance.recipientId,
      'status': instance.status,
      'number': instance.number,
      'container': instance.container,
      'departure_time': instance.departureTime,
      'from_address': instance.fromAddress,
      'from_city_name': instance.fromCityName,
      'to_address': instance.toAddress,
      'to_city_name': instance.toCityName,
      'amount': instance.amount,
      'incoming_number': instance.incomingNumber,
      'incoming_date': instance.incomingDate,
      'bin': instance.bin,
      'invoice_date': instance.invoiceDate,
      'created_at': instance.createdAt,
      'driver': instance.driver,
      'sender': instance.sender,
      'recipient': instance.recipient,
      'total_status': instance.totalStatus,
      'yandex_time': instance.yandexTime,
      'refund_status': instance.refundStatus,
      'provider': instance.provider,
    };
