// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_thread_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteThreadAdapter extends TypeAdapter<FavoriteThread> {
  @override
  final int typeId = 2;

  @override
  FavoriteThread read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteThread(
      threadId: fields[0] as String,
      rating: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteThread obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.threadId)
      ..writeByte(1)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteThreadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
