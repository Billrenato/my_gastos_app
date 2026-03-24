// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renda.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RendaAdapter extends TypeAdapter<Renda> {
  @override
  final int typeId = 2;

  @override
  Renda read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Renda(
      valor: fields[0] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Renda obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.valor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RendaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
