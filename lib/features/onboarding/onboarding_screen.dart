import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glicoare/core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  // Cada tela do onboarding
  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      titulo: 'Registre sua glicemia 3 vezes ao dia',
      subtitulo:
          'Controle sua glicemia no manha, tarde e noite e veja na hora se esta na meta.',
      icone: 'assets/illustrations/glicometro_grande.svg',
    ),
    OnboardingPage(
      titulo: 'Veja na hora se esta na meta',
      subtitulo:
          'Ao salvar uma medicao, o app classifica se esta BAIXA, NA META ou ALTA, com cor/selo e orientacao curta.',
      icone: 'assets/illustrations/check.svg',
    ),
    OnboardingPage(
      titulo: 'Acompanhe sua evolucao em graficos',
      subtitulo:
          'Graficos diarios e comparativos para voce acompanhar sua tendencia e entender padroes.',
      icone: 'assets/illustrations/grafico.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Indicador de pagina
          const SizedBox(height: 40),
          _PageIndicator(current: 0, total: _pages.length),
          const SizedBox(height: 20),
          // Conteudo da pagina atual
          Expanded(child: _PageContent(page: _pages.first)),
          // Botoes de navegacao
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_pages.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => context.go('/cadastro'),
                    icon: const Icon(Icons.arrow_forward),
                    label: const texto('Continuar'),
                  ),
                const Texto('Pular'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String titulo;
  final String subtitulo;
  final String icone;

  OnboardingPage({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
  });
}

class _PageContent extends StatelessWidget {
  final OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.aboveMeta;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ilustracao SVG
        SVGIcon(icone: page.icone, size: 128),
        const SizedBox(height: 24),
        // Titulo
        Text(
          page.titulo,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Subtitulo
        Text(
          page.subtitulo,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Nunito',
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _PageIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= current ? Color(0xFF0FA3A3) : Colors.grey[300],
          ),
        );
      }),
    );
  }
}

/// Widget SVG simples (usa flutter_svg)
class SVGIcon extends StatelessWidget {
  final String icone;
  final double size;
  const SVGIcon({required this.icone, required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        icone,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

/// Texto auxiliar para evitar repiticao de Theme.of(context).textTheme
class Texto extends StatelessWidget {
  final String texto;
  const Texto(this.texto, {super.key});
  @override
  Widget build(BuildContext context) => Text(texto);