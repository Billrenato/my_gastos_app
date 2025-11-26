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
        border: Border.all(
            color: Color(categoria.colorValue), width: 2), // Borda colorida
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(categoria.colorValue),
            radius: 12, // Um pouco maior para destaque
            child: Text(
              categoria.nome[0].toUpperCase(), // Primeira letra da categoria
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            categoria.nome,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          // Aqui você pode colocar ícones de edição ou exclusão se quiser
        ],
      ),
    );
  }
}
