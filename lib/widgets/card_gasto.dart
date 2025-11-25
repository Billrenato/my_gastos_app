import 'package:flutter/material.dart';
import 'package:my_gastos_app/models/gasto.dart';
import 'package:intl/intl.dart';

class CardGasto extends StatelessWidget {
  final Gasto gasto;
  const CardGasto({super.key, required this.gasto});

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
          title: Text(gasto.titulo),
          subtitle: Text(df.format(gasto.data)),
          trailing: Text('R\$ ${gasto.valor.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}