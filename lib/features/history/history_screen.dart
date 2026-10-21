import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glicoare/core/theme/app_theme.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  // Dados simulados - em produção vieram do banco
  final List<RegistroHist> _registros = [
    RegistroHist(
      data: '21/10/2026',
      periodo: 'MANHA',
      valor: 95,
      classificacao: 'Na Meta',
      sintomas: '',
    ),
    RegistroHist(
      data: '20/10/2026',
      periodo: 'TARDE',
      valor: 160,
      classificacao: 'Acima da Meta',
      sintomas: 'Sede',
    ),
    RegistroHist(
      data: '19/10/2026',
      periodo: 'NOITE',
      valor: 88,
      classificacao: 'Abaixo da Meta',
      sintomas: '',
    ),
    RegistroHist(
      data: '18/10/2026',
      periodo: 'MANHA',
      valor: 80,
      classificacao: 'Na Meta',
      sintomas: 'Fome',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const texto('Historico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltro(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _registros.length,
        itemBuilder: (context, index) {
          final reg = _registros[index];
          final isNaMeta = reg.classificacao == 'Na Meta';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                '${reg.data} - ${reg.periodo}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Glicemia: ${reg.valor} mg/dL',
                    style: TextStyle(
                      color: _corClassificacao(reg.classificacao),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (reg.sintomas.isNotEmpty)
                    Text(
                      'Sintomas: ${reg.sintomas}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _corClassificacao(reg.classificacao).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reg.classificacao,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _corClassificacao(reg.classificacao),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _novoRegistro(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  void _mostrarFiltro(BuildContext context) {
    // TODO: implementar filtro por periodo/classificacao
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtro ainda nao implementado')),
    );
  }

  void _novoRegistro(BuildContext context) {
    context.go('/registro');
  }

  Color _corClassificacao(String classe) {
    switch (classe) {
      case 'Na Meta':
        return Color(0xFF2E9E5B);
      case 'Acima da Meta':
        return Color(0xFFF9A825);
      case 'Abaixo da Meta':
        return Color(0xFF1E88E5);
      case 'Crítica':
        return Color(0xFFD32F2F);
      case 'Baixa':
        return Color(0xFF1E88E5);
      default:
        return Colors.grey;
    }
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) => BottomNavigationBar(
    currentIndex: 2,
    onTap: (index) {},
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Hoje'),
      BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analise'),
      BottomNavigationBarItem(
          icon: Icon(Icons.history), label: 'Historico'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    ],
  );
}

class RegistroHist {
  final String data;
  final String periodo;
  final int valor;
  final String classificacao;
  final String sintomas;
  RegistroHist({
    required this.data,
    required this.periodo,
    required this.valor,
    required this.classificacao,
    required this.sintomas,
  });
}