/// Perfil do paciente, que define qual conjunto de faixas serao usadas.
enum Profile { adultDiabetes, gestational, screening }

/// Nivel de gravidade da classificacao.
enum Severity { low, medium, high, critical, veryLow }

/// Direcao da tendencia.
enum Direction { low, inRange, high }

/// Resultado da classificacao de uma leitura de glicemia.
class Classification {
  final String id;
  final String label;
  final Severity severity;
  final Direction direction;
  final Color color;
  final String message;
  final String advice;
  final bool needsMedicalAttention;
  final double minRange; // inclusivo
  final double maxRange; // exclusivo

  const Classification({
    required this.id,
    required this.label,
    required this.severity,
    required this.direction,
    required this.color,
    required this.message,
    required this.advice,
    required this.needsMedicalAttention,
    this.minRange = 0,
    this.maxRange = double.infinity,
  });

  /// Cria a partir de um mapa vindo do JSON (que tem min, max, severity, direction, color, etc.)
  factory Classification.fromMap(Map<String, dynamic> map) {
    final colorVal = map['color'] ?? '0xFFFFFFFF';
    Color parsedColor;
    try {
      parsedColor = Color(int.parse(
          colorVal.toString().replaceAll('0x', ''), radix: 16));
    } catch (_) {
      parsedColor = Colors.black;
    }

    final sevStr = map['severity']?.toString().toLowerCase() ?? 'low';
    final dirStr = map['direction']?.toString().toLowerCase() ?? 'in_range';

    Severity severity;
    switch (sevStr) {
      case 'low':
        severity = Severity.low;
      case 'medium':
        severity = Severity.medium;
      case 'high':
        severity = Severity.high;
      case 'critical':
        severity = Severity.critical;
      case 'very_low':
      case 'very low':
        severity = Severity.veryLow;
      default:
        severity = Severity.low;
    }

    Direction direction;
    switch (dirStr) {
      case 'low':
        direction = Direction.low;
      case 'in_range':
      case 'in_range':
        direction = Direction.inRange;
      case 'high':
        direction = Direction.high;
      default:
        direction = Direction.inRange;
    }

    return Classification(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      severity: severity,
      direction: direction,
      color: parsedColor,
      message: map['message'] ?? '',
      advice: map['advice'] ?? '',
      needsMedicalAttention: map['needsMedicalAttention'] ?? false,
      minRange: (map['min'] ?? 0).toDouble(),
      maxRange: (map['max'] ?? double.infinity).toDouble(),
  );
}

extension SeverityExtension on Severity {
  String get portugueseLabel {
    switch (this) {
      case Severity.low:
        return 'Baixa';
      case Severity.medium:
        return 'Media';
      case Severity.high:
        return 'Alta';
      case Severity.critical:
        return 'Critica';
      case Severity.veryLow:
        return 'Baixa grave';
    }
  }
}

extension DirectionExtension on Direction {
  String get portugueseLabel {
    switch (this) {
      case Direction.low:
        return 'Baixando';
      case Direction.inRange:
        return 'Em meta';
      case Direction.high:
        return 'Subindo';
    }
  }
}

/// Conjunto de faixas (bands) para um momento determinado (jejum, pos-refeicao, etc.).
class BandSet {
  final String profileKey;
  final Map<String, List<Classification>> bandsByMoment; // momento -> lista de bands

  BandSet({
    required this.profileKey,
    required this.bandsByMoment,
  });

  /// Retorna a lista de bands para o momento informado, resolvendo aliases (@xxx).
  List<Classification> bandsForMoment(String moment, {Map<String, dynamic>? customTargets}) {
    var bands = bandsByMoment[moment];
    if (bands == null) {
      // Tenta resolver alias: se momento comecar com @, remove o @ e busca o alias
      if (moment.startsWith('@')) {
        final alias = moment.substring(1);
        bands = bandsByMoment[alias];
      }
    }
    if (bands == null) return [];

    // Aplica customTargets: substitui apenas a faixa "na meta", preservando hipoglicemia e critico
    final result = <Classification>[];
    for (final band in bands) {
      final lowerLabel = band.label.toLowerCase();
      if (customTargets != null &&
          lowerLabel.contains('meta') &&
          customTargets.containsKey('replaceMetaOnly')) {
        // Se a label contiver "meta", tenta substituir
        final replacement = customTargets['metaReplacement'];
        if (replacement != null && replacement is Map<String, dynamic>) {
          result.add(Classification.fromMap(replacement));
          continue;
        }
      }
      result.add(band);
    }
    return result;
  }
}