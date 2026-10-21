import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glicoare/core/theme/app_theme.dart';
import 'package:glicoare/core/rules/rules_repository.dart';

class PatientFormScreen extends ConsumerWidget {
  const PatientFormScreen({super.key});

  // Passo 1: dados basicos
  final _formKey1 = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _sexoOpcoes = ['Masculino', 'Feminino', 'Outro'];
  final _sexoValue = ValueNotifier('Masculino');
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();

  // Passo 2: tipo de enfermidade, insulina, medicamentos
  final _formKey2 = GlobalKey<FormState>();
  final _doencaValue = ValueNotifier('diabetes_tipo_2');
  final _usoInsulinaValue = ValueNotifier(false);
  final _medicamentosController = TextEditingController();

  // Passo 3: medico, contato emergencia, metas personalizadas
  final _formKey3 = GlobalKey<FormState>();
  final _medicoController = TextEditingController();
  final _contatoEmergenciaController = TextEditingController();
  final _metasPersonalizadasController = TextEditingController();

  // Stepper
  final _stepController = StepperController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const texto('Cadastro do Paciente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        controller: _stepController,
        physics: const ClampingScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () => _nextStep(),
        onStepCancel: () => _previousStep(),
        steps: [
          // Passo 1
          Step(
            title: const texto('Dados Basicos'),
            content: _buildStep1(),
            isActive: _currentStep >= 0,
            state: _currentStep >= 0 ? StepState.active : StepState.complete,
          ),
          // Passo 2
          Step(
            title: texto('Tipo de Enfermidade'),
            content: _buildStep2(),
            isActive: _currentStep >= 1,
            state: _currentStep >= 1 ? StepState.active : StepState.complete,
          ),
          // Passo 3
          Step(
            title: texto('Medico e Contato'),
            content: _buildStep3(),
            isActive: _currentStep >= 2,
            state: _currentStep >= 2 ? StepState.active : StepState.complete,
          ),
        ],
        actions: [
          TextButton(
            onPressed: _previousStep,
            child: const texto('Voltar'),
          ),
          ElevatedButton(
            onPressed: _finalizarCadastro,
            child: const texto('Concluir Cadastro'),
          ),
        ],
      ),
    );
  }

  int _currentStep = 0;

  void _nextStep() {
    setState(() {
      if (_currentStep < 2) _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  void _finalizarCadastro() {
    // Aqui salvaria no banco via AppDatabase
    if (_formKey3.currentState!.validate()) {
      context.go('/');
    }
  }

  // --- Passo 1: Dados Basicos ---
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Obrigatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dataNascimentoController,
              decoration:
                  const InputDecoration(labelText: 'Data de nascimento (dd/mm/aaaa)'),
              keyboardType: TextInputType.datetime,
              validator: (v) => v!.isEmpty ? 'Obrigatorio' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _sexoValue.value,
              decoration:
                  const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()),
              items: _sexoOpcoes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) =>
                  _sexoValue.value = v ?? 'Masculino',
              validator: (v) => v == null ? 'Selecione o sexo' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pesoController,
              decoration:
                  const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              validator: (v) => v!.isEmpty ? 'Obrigatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _alturaController,
              decoration:
                  const InputDecoration(labelText: 'Altura (cm)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              validator: (v) => v!.isEmpty ? 'Obrigatorio' : null,
            ),
          ],
        ),
      ),
    );
  }

  // --- Passo 2: Tipo de enfermidade ---
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tipo de enfermidade', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            // Cards para cada opcao
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _DoencaCard(
                  label: 'Diabetes Tipo 1',
                  icon: 'assets/illustrations/syringe.svg',
                  isSelected: _doencaValue.value == 'diabetes_tipo_1',
                  onSelect: () => _doencaValue.value = 'diabetes_tipo_1',
                ),
                _DoencaCard(
                  label: 'Diabetes Tipo 2',
                  icon: 'assets/illustrations/pill.svg',
                  isSelected: _doencaValue.value == 'diabetes_tipo_2',
                  onSelect: () => _doencaValue.value = 'diabetes_tipo_2',
                ),
                _DoencaCard(
                  label: 'Pre-diabetes',
                  icon: 'assets/illustrations/stethoscope.svg',
                  isSelected: _doencaValue.value == 'pre_diabetes',
                  onSelect: () => _doencaValue.value = 'pre_diabetes',
                ),
                _DoencaCard(
                  label: 'Diabetes Gestacional',
                  icon: 'assets/illustrations/gestacional.svg',
                  isSelected: _doencaValue.value == 'diabetes_gestacional',
                  onSelect: () =>
                      _doencaValue.value = 'diabetes_gestacional',
                ),
                _DoencaCard(
                  label: 'Hipoglicemia',
                  icon: 'assets/illustrations/alert.svg',
                  isSelected: _doencaValue.value == 'hipoglicemia',
                  onSelect: () => _doencaValue.value = 'hipoglicemia',
                ),
                _DoencaCard(
                  label: 'Outra',
                  icon: 'assets/illustrations/outra.svg',
                  isSelected: _doencaValue.value == 'outra',
                  onSelect: () => _doencaValue.value = 'outra',
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Usa insulina?'),
              trailing: Switch(
                value: _usoInsulinaValue.value,
                onChanged: (v) => _usoInsulinaValue.value = v,
              ),
              titleTextStyle: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicamentosController,
              decoration:
                  const InputDecoration(labelText: 'Medicamentos (livre)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // --- Passo 3: Medico, contato emergencia, metas personalizadas ---
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _medicoController,
              decoration:
                  const InputDecoration(labelText: 'Medico responsavel', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Obrigatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contatoEmergenciaController,
              decoration:
                  const InputDecoration(labelText: 'Contato de emergencia', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _metasPersonalizadasController,
              decoration: const InputDecoration(
                labelText: 'Metas personalizadas (somente se seu medico informou)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            // Checkbox de Termos/LGPD
            Row(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    uncheckedWidgetColor: Colors.grey,
                    checkedWidgetColor: Color(0xFF0FA3A3),
                  ),
                  child: Checkbox(
                    value: true, // Opcional: guardar estado
                    onChanged: (_) {},
                    // O checkbox sera sempre marcado (obrigatorio) e o botao so habilita se marcado
                  ),
                ),
                const Expanded(child: Container()),
                const Text(
                  'Li e concordo com os Termos de Uso e a Politica de LGPD.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Aviso fixo
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.amber[50],
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  Expanded(
                    child: Text(
                      'O GlicoCare e uma ferramenta de acompanhamento e nao substitui avaliacao medica. '
                      'Nao use para ajustar doses de insulina sem orientacao do seu medico.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de selecao de enfermidade
class _DoencaCard extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onSelect;

  const _DoencaCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Color(0xFF0FA3A3) : Colors.grey[300];
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: 20, height: 20),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: color,
      onSelected: onSelect,
    );
  }
}