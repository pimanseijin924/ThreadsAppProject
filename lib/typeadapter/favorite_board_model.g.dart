// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_board_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteBoardAdapter extends TypeAdapter<FavoriteBoard> {
  @override
  final int typeId = 1;

  @override
  FavoriteBoard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteBoard(
      boardId: fields[0] as String,
      rating: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteBoard obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.boardId)
      ..writeByte(1)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteBoardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
