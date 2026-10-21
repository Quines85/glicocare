import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glicoare/core/theme/app_theme.dart';
import 'package:glicoare/core/rules/rules_repository.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  // Simulacao de estado - em produção viria do banco/ViewModel
  // Cada cartao representa um periodo: MANHA, TARDE, NOITE
  final List<PeriodoStatus> _periodos = const [
    PeriodoStatus(
      periodo: 'MANHA',
      horario: '07:00',
      status: StatusCartao.registrado,
      valor: 95,
      classificacao: Classificacao.naMeta,
    ),
    PeriodoStatus(
      periodo: 'TARDE',
      horario: '13:00',
      status: StatusCartao.pendente,
      classificacao: Classificacao.naMeta,
    ),
    PeriodoStatus(
      periodo: 'NOITE',
      horario: '21:00',
      status: StatusCartao.registrado,
      valor: 88,
      classificacao: Classificacao.abaixoMeta,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const texto('Hoje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _verLembretes(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudacao e data
            _buildSaudacao(context),
            const SizedBox(height: 32),

            // Texto resumo do dia
            const Text(
              'Resumo do dia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Media: 91 mg/dL | Leituras na meta: 2 de 3',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // 3 cartoes grandes: MANHA, TARDE, NOITE
            _buildCartaoManha(context, colorScheme),
            const SizedBox(height: 16),
            _buildCartaoTarde(context, colorScheme),
            const SizedBox(height: 16),
            _buildCartaoNoite(context, colorScheme),
            const SizedBox(height: 32),

            // Faixa de aviso quando houver hipoglicemia ou valor critico
            _buildAvisoSaude(context),

            // Botao central de registro
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Registrar Glicemia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- Componentes ---

  Widget _buildSaudacao(BuildContext context) {
    final nome = 'Maria'; // viesse do banco
    final data = '21/10/2026';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bem-vinda, $nome!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          data,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCartaoManha(BuildContext context, ColorScheme colorScheme) {
    final status = _periodos[0];
    return _CartaoPeriodo(
      contexto: 'MANHA',
      horario: status.horario,
      valor: status.valor,
      classificacao: status.classificacao,
      corSelo: _corClassificacao(status.classificacao),
      icone: _iconePeriodo('manha'),
      onTap: () => _abrirRegistro(context, 'manha'),
    );
  }

  Widget _buildCartaoTarde(BuildContext context, ColorScheme colorScheme) {
    final status = _periodos[1];
    return _CartaoPeriodo(
      contexto: 'TARDE',
      horario: status.horario,
      valor: status.valor ?? 0,
      classificacao: status.classificacao,
      corSelo: _corClassificacao(status.classificacao),
      icone: _iconePeriodo('tarde'),
      onTap: () => _abrirRegistro(context, 'tarde'),
    );
  }

  Widget _buildCartaoNoite(BuildContext context, ColorScheme colorScheme) {
    final status = _periodos[2];
    return _CartaoPeriodo(
      contexto: 'NOITE',
      horario: status.horario,
      valor: status.valor ?? 0,
      classificacao: status.classificacao,
      corSelo: _corClassificacao(status.classificacao),
      icone: _iconePeriodo('noite'),
      onTap: () => _abrirRegistro(context, 'noite'),
    );
  }

  Widget _buildAvisoSaude(BuildContext context) {
    // Se houver classificacao baixa/critica, mostrar faixa de aviso
    final temAviso = _periodos.any((p) =>
        p.classificacao == Classificacao.baixa || p.classificacao == Classificacao.criticaBaixaGrave);
    if (!temAviso) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          Expanded(
            child: Text(
              'Atenao: Hidrate-se e siga a orientacao do seu medico. Se os valores repetirem, procure atendimento.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) => BottomNavigationBar(
    currentIndex: 0,
    onTap: (index) => {},
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Hoje',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics),
        label: 'Analise',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history),
        label: 'Historico',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ],
  );

  // --- Funcoes auxiliares ---

  void _verLembretes(BuildContext context) =>
      context.go('/settings'); // Abrir configuracoes de lembrete

  void _abrirRegistro(BuildContext context, String periodo) {
    context.go('/registro');
  }

  Color _corClassificacao(Classificacao clazz) {
    switch (clazz) {
      case Classificacao.criticaBaixaGrave:
        return Color(0xFFD32F2F);
      case Classificacao.baixa:
        return Color(0xFF1E88E5);
      case Classificacao.naMeta:
        return Color(0xFF2E9E5B);
      case Classificacao.acimaMeta:
        return Color(0xFFF9A825);
      case Classificacao.alta:
        return Color(0xFFEF6C00);
      default:
        return Colors.grey;
    }
  }

  IconData _iconePeriodo(String periodo) {
    switch (periodo) {
      case 'manha':
        return Icons.wb_sunny;
      case 'tarde':
        return Icons.wb_sunny; // mesmo ou diferente
      case 'noite':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }
}

// --- Modelos de apoio ---

class PeriodoStatus {
  final String periodo;
  final String horario;
  final StatusCartao status;
  final int? valor;
  final Classificacao classificacao;

  PeriodoStatus({
    required this.periodo,
    required this.horario,
    required this.status,
    this.valor,
    required this.classificacao,
  });
}

enum StatusCartao { pendente, registrado, atrasado }

enum Classificacao { criticaBaixaGrave, baixa, naMeta, acimaMeta, alta }