// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WarehouseOrderDTOImpl _$$WarehouseOrderDTOImplFromJson(
        Map<String, dynamic> json) =>
    _$WarehouseOrderDTOImpl(
      id: json['id'] as int,
      status: json['status'] as int?,
      number: json['number'] as String?,
      counteragentId: json['counteragent_id'] as int?,
      userId: json['user_id'] as int?,
      container: json['container'] as int?,
      createdAt: json['created_at'] as String?,
      provider: json['provider'] as String?,
      counteragent: json['counteragent'] == null
          ? null
          : CounteragentDTO.fromJson(
              json['counteragent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WarehouseOrderDTOImplToJson(
        _$WarehouseOrderDTOImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'number': instance.number,
      'counteragent_id': instance.counteragentId,
      'user_id': instance.userId,
      'container': instance.container,
      'created_at': instance.createdAt,
      'provider': instance.provider,
      'counteragent': instance.counteragent,
    };
