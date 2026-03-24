import 'package:hive/hive.dart';
import 'package:flutter/material.dart'; // Importante para o Icons.category

part 'categoria.g.dart'; 

@HiveType(typeId: 1)
class Categoria extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  int colorValue;

  @HiveField(3) // Novo campo para o ícone
  int iconCode;

  Categoria({
    required this.id, 
    required this.nome, 
    required this.colorValue,
    this.iconCode = 0xe141, // 0xe141 é o código padrão do Icons.category
  });
}