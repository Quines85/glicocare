import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:glicoare/core/rules/rules_models.dart';

/// Resolve aliases: se o momento comeca com @xxx, busca a chave 'xxx' no mesmo perfil.
String? _resolveAlias(String moment, Map<String, dynamic> profileData) {
  if (moment.startsWith('@')) {
    final alias = moment.substring(1);
    return profileData[alias] != null ? alias : null;
  }
  return null;
}

/// Carrega e processa o JSON de regras.
class RulesRepository {
  final String rootAssetPath;
  late final Map<String, dynamic> _json;
  late final Map<String, Map<String, List<Map<String, dynamic>>>> _bandsByProfileAndMoment;
  // Structure: _bandsByProfileAndMoment[profileKey][moment] = list of band maps (with min, max, etc.)

  RulesRepository(this.rootAssetPath) {
    _loadRules();
  }

  Future<void> _loadRules() async {
    final defaultAsset = '$rootAssetPath/rules/glicemia_rules_v1.json';
    final String assetString = await rootBundle.loadString(defaultAsset);
    _json = jsonDecode(assetString);

    _bandsByProfileAndMoment = {};
    final profiles = _json['profiles'] as Map<String, dynamic>;
    profiles.forEach((profileKey, profileData) {
      final profileBands = {};
      // Process each moment type: fasting, pre_meal, post_meal_2h, bedtime
      final momentKeys = ['fasting', 'pre_meal', 'post_meal_2h', 'bedtime'];
      for (final key in momentKeys) {
        final dynamicList = profileData[key] as List<dynamic>? ?? [];
        // Resolve aliases: if key starts with @, replace with actual key
        final effectiveKey = _resolveAlias(key, profileData) ?? key;
        final bands = dynamicList.map((item) {
          final m = item as Map<String, dynamic>;
          // Ensure required fields exist
          return {
            'id': m['id'] ?? '',
            'label': m['label'] ?? '',
            'min': (m['min'] ?? 0).toDouble(),
            'max': (m['max'] ?? 0).toDouble(),
            'severity': m['severity'] ?? 'low',
            'direction': m['direction'] ?? 'in_range',
            'color': m['color'] ?? '0xFFFFFFFF',
            'advice': m['advice'] ?? '',
            'needsMedicalAttention': m['needsMedicalAttention'] ?? false,
          };
        }).toList();
        profileBands[effectiveKey] = bands;
      }
      _bandsByProfileAndMoment[profileKey] = profileBands;
    });
  }

  /// Retorna a lista de bands (com min/max) para o perfil e momento.
  List<Map<String, dynamic>>? getBands(String profileKey, String moment) {
    final profileBands = _bandsByProfileAndMoment[profileKey];
    if (profileBands == null) return null;
    // Check for alias resolution
    final resolvedMoment = _resolveAlias(moment, _json['profiles'][profileKey] as Map<String, dynamic>) ?? moment;
    return profileBands[resolvedMoment];
  }

  /// Classifica uma leitura de glicemia.
  /// Regras: min inclusivo, max exclusivo. Valores fora de 20..600 rejeitados.
  Classification classify({
    required int valueMgDl,
    required String profileKey,
    required String moment,
    Map<String, dynamic>? customTargets,
  }) {
    // Validacao: valores fora de 20..600 sao invalidos
    if (valueMgDl < 20 || valueMgDl > 600) {
      throw ArgumentError(
          'Confira o valor digitado. Glicemia deve estar entre 20 e 600 mg/dL.');
    }

    final bands = getBands(profileKey, moment);
    if (bands == null) {
      // Fallback
      return Classification(
        id: 'undefined',
        label: 'Sem faixa de referencia',
        severity: Severity.low,
        direction: Direction.inRange,
        color: Colors.grey,
        message: 'Nao ha faixas de referencia para este perfil/momento.',
        advice: 'Consulte seu medico.',
        needsMedicalAttention: false,
      );
    }

    // Procura a primeira band que corresponde: min <= value < max
    for (final bandMap in bands) {
      final min = bandMap['min'] as double;
      final max = bandMap['max'] as double;
      if (valueMgDl >= min && valueMgDl < max) {
        return Classification.fromMap(bandMap);
      }
    }

    // Se nao encontrou nenhuma band (valor maior que todas as ranges), retorna a ultima
    final lastBand = bands.last;
    return Classification.fromMap(lastBand);
  }
}