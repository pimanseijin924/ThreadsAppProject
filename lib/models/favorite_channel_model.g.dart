// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:hive/hive.dart';
import 'package:my_app/models/favorite_channel_model.dart';
//part of 'favorite_channel.dart';

class FavoriteChannelAdapter extends TypeAdapter<FavoriteChannel> {
  @override
  final int typeId = 0;

  @override
  FavoriteChannel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteChannel(
      channelId: fields[0] as String,
      rating: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteChannel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.channelId)
      ..writeByte(1)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
