import 'package:flutter/material.dart';
import 'package:my_gastos_app/models/categoria.dart';

class CategoriaItem extends StatelessWidget {
  final Categoria categoria;

  const CategoriaItem({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(categoria.colorValue),
            radius: 10,
          ),
          const SizedBox(width: 12),
          Text(
            categoria.nome,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          // Implementar edição/exclusão aqui se desejar
        ],
      ),
    );
  }
}