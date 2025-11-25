import 'package:flutter/material.dart';
import 'package:my_gastos_app/screens/home_screen.dart';
import 'package:my_gastos_app/screens/add_gasto_screen.dart';
import 'package:my_gastos_app/screens/calendario_screen.dart';
import 'package:my_gastos_app/screens/relatorios_screen.dart';
import 'package:my_gastos_app/screens/categorias_screen.dart';

class Routes {
  static const home = '/';
  static const add = '/add';
  static const calendar = '/calendar';
  static const reports = '/reports';
  static const categories = '/categories';

  static final routes = <String, WidgetBuilder>{
    home: (ctx) => const HomeScreen(),
    add: (ctx) => const AddGastoScreen(),
    calendar: (ctx) => const CalendarioScreen(),
    reports: (ctx) => const RelatoriosScreen(),
    categories: (ctx) => const CategoriasScreen(),
  };
}