import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/renda_provider.dart';

class RendaScreen extends ConsumerStatefulWidget {
  const RendaScreen({super.key});

  @override
  ConsumerState<RendaScreen> createState() => _RendaScreenState();
}

class _RendaScreenState extends ConsumerState<RendaScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final renda = ref.watch(rendaProvider);

    controller.text = renda.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Definir Renda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Renda mensal',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final valor =
                    double.tryParse(controller.text) ?? 0;

                ref.read(rendaProvider.notifier).setRenda(valor);

                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            )
          ],
        ),
      ),
    );
  }
}