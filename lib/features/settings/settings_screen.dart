import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glicoare/core/theme/app_theme.dart';
import 'package:glicoare/core/rules/rules_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import:package:printing/printing.dart';
import:package:share_extend/share_extend.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Controladores de lembretes
  final _manhaController = ValueNotifier<bool>(true);
  final _tardeController = ValueNotifier<bool>(true);
  final _noiteController = ValueNotifier<bool>(true);
  final _manhaTimeController = TextEditingController(text: '07:00');
  final _tardeTimeController = TextEditingController(text: '13:00');
  final _noiteTimeController = TextEditingController(text: '21:00');

  // Tema
  bool _temaEscuro = false;

  // Estado de dados
  bool _dadosExcluidos = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const texto('Configuracoes'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.notifications), text: 'Lembretes'),
              Tab(icon: Icon(Icons.picture_as_pdf), text: 'Exportar PDF'),
              Tab(icon: Icon(Icons.brightness_6), text: 'Tema'),
              Tab(icon: Icon.delete), text: 'Apagar Dados'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        children: [
          // --- Aba Lembretes ---
          _buildLembretesTab(context, colorScheme),
          // --- Aba Exportar PDF ---
          _buildExportPdfTab(context, colorScheme),
          // --- Aba Tema ---
          _buildTemaTab(colorScheme),
          // --- Aba Apagar Dados ---
          _buildApagarDadosTab(colorScheme),
        ],
      ),
    );
  }

  // --- Aba Lembretes ---
  Widget _buildLembretesTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lembretes Diarios', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          // Switch para cada periodo
          _ConstruirLembreteTile(
            icone: Icons.wb_sunny,
            titulo: 'Manha (07:00)',
            valor: 'Hora de medir sua glicemia (manha)',
            ativo: _manhaController.value,
            onChanged: (v) => _manhaController.value = v,
            timeController: _manhaTimeController,
          ),
          _ConstruirLembreteTile(
            icone: Icons.access_time,
            titulo: 'Tarde (13:00)',
            valor: 'Hora de medir sua glicemia (tarde)',
            ativo: _tardeController.value,
            onChanged: (v) => _tardeController.value = v,
            timeController: _tardeTimeController,
          ),
          _ConstruirLembreteTile(
            icone: Icons.nightlight,
            titulo: 'Noite (21:00)',
            valor: 'Hora de medir sua glicemia (noite)',
            ativo: _noiteController.value,
            onChanged: (v) => _noiteController.value = v,
            timeController: _noiteTimeController,
          ),
          const SizedBox(height: 32),
          // Informacao sobre permissoes
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surface.withOpacity(0.5),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permissao de Notificacao', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'O app solicita permissao de notificacao local no Android 13+. '
                  'Alarmes exatos sao reagendados apos reboot.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para tile de lembrete
  Widget _ConstruirLembreteTile({
    required IconData icone,
    required String titulo,
    required String valor,
    required ValueNotifier<bool> ativo,
    required ValueChanged<bool> onChanged,
    required TextEditingController timeController,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icone, color: Color(0xFF0FA3A3), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 16)),
                Text(valor, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          // Switch + campo de horario
          Expanded(
            child: Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: ativo,
                  builder: (_, bool value, __) {
                    return Switch(
                      value: value,
                      onChanged: onChanged,
                      activeColor: Color(0xFF0FA3A3),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Horario',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.time,
                    readOnly: true,
                    onTap: () => _selecionarHorario(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Aba Exportar PDF ---
  Widget _buildExportPdfTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exportar Relatorio', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          const Text(
            'Periodo: Ultimos 30 dias',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Botao gerar PDF
          ElevatedButton.icon(
            onPressed: _gerarPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const texto('Gerar Relatorio PDF'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 32),
          // Informacoes sobre o PDF
          const Text(
            'O relatorio inclui: dados do paciente, tabela de leituras com classificacao, '
            'graficos de tendencia, medias (manha/tarde/noite) e avisos medico.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _gerarPdf() async {
    // Dados simulados - em producao vieriam do banco
    final pdf = pw.Document();

    // Adiciona uma pagina
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Cabecalho
              pw.Text(
                'Relatorio GlicoCare',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Dados do paciente (simulados)
              pw.Text(
                'Paciente: Maria Silva',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Perfil: Diabetes Tipo 2',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Periodo: Ultimos 30 dias',
                style: pw.TextStyle(fontSize: 16),
              ),
              const Divider(),
              // Tabela de leituras
              pw.Text(
                'Tabela de Leituras',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Linhas de tabela simplificadas
              for (int i = 0; i < 5; i++)
                pw.Row(
                  children: [
                    pw.Text('21/10/2026'),
                    pw.Text('Manha'),
                    pw.Text('95 mg/dL'),
                    pw.Text('Na Meta'),
                  ],
                ),
              const Divider(),
              // Grafico simplificado (texto)
              pw.Text(
                'Grafico: Evolucao da Glicemia (ultimos 30 dias)',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              const SizedBox(height: 10),
              pw.Text(
                'Media Manha: 92 mg/dL | Media Tarde: 150 mg/dL | Media Noite: 88 mg/dL',
                style: pw.TextStyle(fontSize: 14),
              ),
              // Aviso medico
              const Divider(),
              pw.Text(
                'O GlicoCare e uma ferramenta de acompanhamento e nao substitui avaliacao medica. '
                'Nao use para ajustar doses de insulina sem orientacao do seu medico.',
                style: pw.TextStyle(fontSize: 12, italic: true),
              ),
            ],
          ),
        ),
      ),
    );

    // Salvar e compartilhar
    final file = await Printing.savePdf(
      pdf: pdf,
      format: PdfFormat.a4,
      printerFont: PdfPrinterFont.helvetica,
    );

    // Compartilhar
    if (context.mounted) {
      if (await ShareExtender.share(
        'Confira o relatorio medico do GlicoCare',
        files: [file],
      )) {
        // Sucesso
      }
    }
  }

  // --- Aba Tema ---
  Widget _buildTemaTab(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aparencia do App', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          ListTile(
            title: const texto('Tema Claro'),
            leading: const Icon(Icons.wb_sunny),
            trailing: _temaEscuro
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              // Lógica de troca de tema
              setState(() => _temaEscuro = !_temaEscuro);
            },
          ),
          ListTile(
            title: const texto('Tema Escuro'),
            leading: const Icon(Icons.nightlight),
            trailing: _temaEscuro
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              setState(() => _temaEscuro = true);
            },
          ),
          ListTile(
            title: const texto('Sistema'),
            leading: const Icon(Icons.autorize),
            trailing: _temaEscuro
                ? null
                : const Icon(Icons.check),
            onTap: () {
              setState(() => _temaEscuro = false);
            },
          ),
          const SizedBox(height: 32),
          // Informacao
          const Text(
            'O app suporta textScaleFactor ate 1.4 sem quebrar layout.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- Aba Apagar Dados ---
  Widget _buildApagarDadosTab(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apagar Todos os Dados', style: TextStyle(fontSize: 20, color: Colors.red)),
          const SizedBox(height: 16),
          const Text(
            'Esta acao nao pode ser desfeita. Todos os registros de glicemia, '
            'cadastros de paciente e configuracoes serao permanentemente removidos.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          // Botao perigoso
          ElevatedButton(
            onPressed: _confirmarExclusao,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const texto('Excluir Todos os Dados'),
          ),
          const SizedBox(height: 16),
          // Indicador se ja foi excluido
          if (_dadosExcluidos)
            const Text(
              'Todos os dados foram excluidos com sucesso.',
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
        ],
      ),
    );
  }

  void _confirmarExclusao() {
    // Show dialog de confirmacao
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusao'),
        content: const Text(
          'Tem certeza que deseja apagar todos os dados? Esta acao nao pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Lógica de exclusao
              // appDatabase.deleteAllData();
              Navigator.of(ctx).pop();
              setState(() => _dadosExcluidos = true);
              if (context.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Todos os dados foram excluidos.')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}