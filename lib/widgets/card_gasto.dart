import 'package:flutter/material.dart';
import 'package:my_gastos_app/models/gasto.dart';
import 'package:my_gastos_app/models/categoria.dart';
import 'package:intl/intl.dart';

class CardGasto extends StatelessWidget {
  final Gasto gasto;
  final Categoria categoria; // Adicionado categoria correspondente

  const CardGasto({super.key, required this.gasto, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(categoria.colorValue),
            radius: 12,
          ),
          title: Text(gasto.titulo),
          subtitle: Text(
              '${df.format(gasto.data)} • ${categoria.nome}'), // mostra nome da categoria
          trailing: Text('R\$ ${gasto.valor.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}
