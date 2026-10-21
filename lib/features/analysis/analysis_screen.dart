import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glicoare/core/theme/app_theme.dart';
import 'package:glicoare/core/rules/rules_repository.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  // Dados simulados - em produção vieram do banco/ViewModel
  final List<DiaDado> _ultimoDia = [
    DiaDado(
      hora: '07:00',
      valor: 95,
      periodo: 'manha',
      classificacao: Classificacao.naMeta,
    ),
    DiaDado(
      hora: '13:00',
      valor: 160,
      periodo: 'depois_da_refeicao',
      classificacao: Classificacao.acimaMeta,
    ),
    DiaDado(
      hora: '21:00',
      valor: 88,
      periodo: 'depois_da_refeicao',
      classificacao: Classificacao.abaixoMeta,
    ),
  ];

  final List<SemanaDado> _ultimaSemana = List.generate(7, (i) {
    final semanaAnterior = DateTime.now().day - i - 1;
    return SemanaDado(
      dia: semanaAnterior > 0 ? semanaAnterior : 1,
      manha: 80 + (i * 5),
      tarde: 140 - (i * 3),
      noite: 90 + (i * 2),
    );
  });

  final List<MesDado> _ultimoMes = List.generate(30, (i) {
    final dia = i + 1;
    return MesDado(
      dia: dia,
      valorMedio: 100 + (i * 0.5),
      status: i % 5 == 0 ? Classificacao.acimaMeta : Classificacao.naMeta,
    );
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const texto('Analise'),
        bottom: _buildTabsBottom(context),
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 250.flexible,
              floating: true,
              pinned: true,
              title: const texto('Analise Glicemica'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: TabBar(
                  indicatorColor: colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Dia'),
                    Tab(text: '7 Dias'),
                    Tab(text: '30 Dias'),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _filtrarPeriodo(),
                ),
              ],
            ),
          ],
          body: TabBarView(
            children: [
              // Aba Dia
              _buildDiaTab(context, colorScheme),
              // Aba 7 Dias
              _buildSemanaTab(context, colorScheme),
              // Aba 30 Dias
              _buildMesTab(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // --- Aba DIA: grafico de linha com 3 pontos (manha, tarde, noite) ---
  Widget _buildDiaTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grafico do Dia Atual', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          // Grafico fl_chart com 3 pontos
          AspectRatio(
            aspectRatio: 2.5,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  // Linha dos 3 registros do dia
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 95),
                      FlSpot(1, 160),
                      FlSpot(2, 88),
                    ],
                    isCurved: true,
                    color: Color(0xFF0FA3A3),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Color(0xFF0FA3A3).withOpacity(0.1),
                    ),
                    dotData: FlDotData(show: true),
                    barWidth: 3,
                  ),
                ],
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      getTitlesWidget: (value, meta) {
                        final v = value.toInt();
                        if (v == 0) return const Text('07:00');
                        if (v == 1) return const Text('13:00');
                        if (v == 2) return const Text('21:00');
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final v = value.toInt();
                        if (v == 0) return const Text('Manhã');
                        if (v == 1) return Text('Tarde');
                        if (v == 2) return Text('Noite');
                        return const Text('');
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Indicadores do dia
          const Text('Indicadores do Dia', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          _IndicadorCartao(
            titulo: 'Media',
            valor: '98 mg/dL',
            icone: Icons.trending_up,
            cor: Color(0xFF0FA3A3),
          ),
          const SizedBox(height: 8),
          _IndicadorCartao(
            titulo: 'Maximo',
            valor: '160 mg/dL',
            icone: Icons.arrow_upward,
            cor: Color(0xFFF9A825),
          ),
          const SizedBox(height: 8),
          _IndicadorCartao(
            titulo: 'Minimo',
            valor: '88 mg/dL',
            icone: Icons.arrow_downward,
            cor: Color(0xFF1E88E5),
          ),
        ],
      ),
    );
  }

  // --- Aba 7 DIAS: grafico de barras agrupadas ---
  Widget _buildSemanaTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ultima Semana (7 Dias)', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 200,
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      getTitlesWidget: (value, meta) {
                        final v = value.toInt();
                        if (v == 0) return const Text('Dia 1');
                        if (v == 1) return const Text('Dia 2');
                        if (v == 2) return const Text('Dia 3');
                        if (v == 3) return const Text('Dia 4');
                        if (v == 4) return const Text('Dia 5');
                        if (v == 5) return const Text('Dia 6');
                        if (v == 6) return const Text('Dia 7');
                        return const Text('');
                      ),
                      reservedSize: 30,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final v = value.toInt();
                        if (v == 0) return const Text('Manhã');
                        if (v == 1) return Text('Tarde');
                        if (v == 2) return Text('Noite');
                        return const Text('');
                      ),
                      reservedSize: 32,
                    ),
                  ),
                ),
                barGroups: _ultimaSemana.asMap().entries.map((entry) {
                  final i = entry.key;
                  final dado = entry.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dado.manha,
                        color: Classificacao.naMeta.cor,
                        width: 16,
                      ),
                      BarChartRodData(
                        toY: dado.tarde,
                        color: Classificacao.acimaMeta.cor,
                        width: 16,
                      ),
                      BarChartRodData(
                        toY: dado.noite,
                        color: Classificacao.abaixoMeta.cor,
                        width: 16,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Cartoes de indicadores 7 dias
          const Text('Indicadores da Semana', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          _IndicadorCartao(titulo: 'Dias na meta', valor: '4 de 7', icone: Icons.check_circle,
              cor: Color(0xFF2E9E5B)),
          const SizedBox(height: 4),
          _IndicadorCartao(titulo: 'Maior valor', valor: '180 mg/dL', icone: Icons.arrow_upward,
              cor: Color(0xFFF9A825)),
          const SizedBox(height: 4),
          _IndicadorCartao(titulo: 'Menor valor', valor: '70 mg/dL', icone: Icons.arrow_downward,
              cor: Color(0xFF1E88E5)),
        ],
      ),
    );
  }

  // --- Aba 30 DIAS: linha de tendencia diaria ---
  Widget _buildMesTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ultimo Mes (30 Dias)', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 2,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  // Linha de tendencia media dia a dia
                  LineChartBarData(
                    spots: List.generate(_ultimoMes.length, (i) {
                      final d = _ultimoMes[i];
                      return FlSpot(d.dia.toDouble(), d.valorMedio);
                    }),
                    isCurved: true,
                    color: Color(0xFF6D28D9),
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(
                      show: true,
                      getDotColor: (i) => Color(0xFF6D28D9),
                    ),
                    barWidth: 3,
                  ),
                ],
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      getTitlesWidget: (value, meta) {
                        final v = value.toInt();
                        if (v >= 0 && v < 30) {
                          final d = _ultimoMes[v];
                          return Text('${d.dia}');
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      getTitlesWidget: (value, meta) {
                        final v = value.toInt();
                        if (v == 0) return const Text('70');
                        if (v == 10) return Text('80');
                        if (v == 20) return Text('90');
                        if (v == 30) return Text('100');
                        return const Text('');
                      ),
                      reservedSize: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Insights fixos por regra
          const Text('Insights por Regra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _InsightItem(
            icone: Icons.warning_amber_rounded,
            titulo: 'Em 5 dos ultimos 7 dias, sua glicemia da manha ficou acima da meta.',
            cor: Color(0xFFF9A825),
          ),
          _InsightItem(
            icone: Icons.trending_up,
            titulo: 'Sua media geral nos ultimos 30 dias foi de 105 mg/dL.',
            cor: Color(0xFF0FA3A3),
          ),
        ],
      ),
    );
  }

  // --- Widgets auxiliares ---

  Widget? _buildTabsBottom(BuildContext context) => PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: TabBar(
      indicatorColor: Theme.of(context).colorScheme.primary,
      tabs: const [
        Tab(text: 'Dia'),
        Tab(text: '7 Dias'),
        Tab(text: '30 Dias'),
      ],
    ),
  );

  void _filtrarPeriodo() {
    // TODO: implementar filtro de periodo
  }
}

// --- Widgets auxiliares reutilizaveis ---

class _IndicadorCartao extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;

  const _IndicadorCartao({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 20, color: cor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final Color cor;

  const _InsightItem({
    required this.icone,
    required this.titulo,
    required this.cor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      Row(
        children: [
          Icon(icone, size: 20, color: cor),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo)),
        ],
      ),
    );
  }
}

// --- Modelos de dados para as telas ---

class DiaDado {
  final String hora;
  final int valor;
  final String periodo;
  final Classificacao classificacao;

  DiaDado({
    required this.hora,
    required this.valor,
    required this.periodo,
    required this.classificacao,
  });
}

class SemanaDado {
  final int dia;
  final int manha;
  final int tarde;
  final int noite;

  SemanaDado({
    required this.dia,
    required this.manha,
    required this.tarde,
    required this.noite,
  });
}

class MesDado {
  final int dia;
  final double valorMedio;
  final Classificacao status;

  MesDado({
    required this.dia,
    required this.valorMedio,
    required this.status,
  });
}

// --- Components simples ---

class _CartaoPeriodo extends StatelessWidget {
  final String contexto;
  final String horario;
  final int valor;
  final Classificacao classificacao;
  final Color corSelo;
  final IconData icone;
  final VoidCallback onTap;

  const _CartaoPeriodo({
    required this.contexto,
    required this.horario,
    required this.valor,
    required this.classificacao,
    required this.corSelo,
    required this.icone,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  contexto,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  horario,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SvgPicture.asset(
                  _iconeSvg(icone),
                  width: 32,
                  height: 32,
                  color: corSelo,
                ),
                const SizedBox(width: 12),
                Text(
                  '$valor mg/dL',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Selo de classificacao
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: corSelo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _labelClassificacao(classificacao),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: corSelo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelClassificacao(Classificacao c) {
    switch (c) {
      case Classificacao.naMeta:
        return 'Na Meta';
      case Classificacao.acimaMeta:
        return 'Acima';
      case Classificacao.abaixoMeta:
        return 'Abaixo';
      case Classificacao.criticaBaixaGrave:
        return 'Crítica';
      case Classificacao.baixa:
        return 'Baixa';
      case Classificacao.alta:
        return 'Alta';
      default:
        return 'Indefinido';
    }
  }

  String _iconeSvg(String periodo) {
    switch (periodo) {
      case 'manha':
        return 'assets/illustrations/sol.svg';
      case 'tarde':
        return 'assets/illustrations/sol_meio_dia.svg';
      case 'noite':
        return 'assets/illustrations/lua.svg';
      default:
        return 'assets/illustrations/relogio.svg';
    }
  }
}

// --- Rotas auxiliares ---

// Extensao para texto com tema
extension TextoX on Widget {
  Widget get texto => Text(
        runtimeType == Text ? (this as Text).data ?? '' : '',
        style: Theme.of(context).textTheme.titleLarge,
      );
}

// Classes de classificacao simplificadas para o widget
class Classificacao {
  static const naMeta = Classificacao('na_meta');
  static const acimaMeta = Classificacao('acima_meta');
  static const abaixoMeta = Classificacao('abaixo_meta');
  static const criticaBaixaGrave = Classificacao('critica_baixa_grave');
  static const baixa = Classificacao('baixa');
  static const alta = Classificacao('alta');

  final String label;
  const Classificacao(this.label);
}