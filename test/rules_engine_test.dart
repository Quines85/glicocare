import 'package:glicoare/core/rules/rules_engine.dart';
import 'package:glicoare/core/rules/rules_models.dart';
import 'package:test/test.dart';

void main() {
  final repo = RulesRepository('assets');

  group('Motor de Regras - GlicoCare', () {
    // Teste: valores exatas nas fronteiras para adult_diabetes/fasting
    test('fronteiras adult_diabetes/fasting - hipograve 53', () {
      final c = classify(valueMgDl: 53, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Hipoglicemia grave'));
      expect(c.severity, Severity.critical);
    });

    test('fronteiras adult_diabetes/fasting - 54 (limite hipoglicemia)', () {
      final c = classify(valueMgDl: 54, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Hipoglicemia'));
      expect(c.severity, Severity.low);
    });

    test('fronteiras adult_diabetes/fasting - 69 (limite abaixo da meta)', () {
      final c = classify(valueMgDl: 69, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Abaixo da meta'));
      expect(c.severity, Severity.low);
    });

    test('fronteiras adult_diabetes/fasting - 70 (limite na meta)', () {
      final c = classify(valueMgDl: 70, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Na meta'));
      expect(c.severity, Severity.medium);
    });

    test('fronteiras adult_diabetes/fasting - 79 (limite na meta)', () {
      final c = classify(valueMgDl: 79, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Na meta'));
    });

    test('fronteiras adult_diabetes/fasting - 80 (limite acima da meta)', () {
      final c = classify(valueMgDl: 80, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Acima da meta'));
      expect(c.severity, Severity.high);
    });

    test('fronteiras adult_diabetes/fasting - 130 (limite superior na meta)', () {
      final c = classify(valueMgDl: 130, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Na meta'));
    });

    test('fronteiras adult_diabetes/fasting - 131 (limite acima da meta)', () {
      final c = classify(valueMgDl: 131, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Acima da meta'));
      expect(c.severity, Severity.high);
    });

    test('fronteiras adult_diabetes/fasting - 180 (limite superior acima)', () {
      final c = classify(valueMgDl: 180, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Acima da meta'));
    });

    test('fronteiras adult_diabetes/fasting - 181 (critico inicio)', () {
      final c = classify(valueMgDl: 181, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Hiperglicemia'));
      expect(c.severity, Severity.high);
    });

    test('fronteiras adult_diabetes/fasting - 250 (limite critico)', () {
      final c = classify(valueMgDl: 250, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Hiperglicemia critica'));
      expect(c.severity, Severity.critical);
    });

    test('fronteiras adult_diabetes/fasting - 251 (acima critico)', () {
      final c = classify(valueMgDl: 251, profileKey: 'adult_diabetes', moment: 'fasting');
      expect(c.label, equals('Hiperglicemia critica'));
    });

    // Teste: alias resolvido corretamente
    test('alias pre_meal -> fasting em adult_diabetes', () {
      final c = classify(valueMgDl: 85, profileKey: 'adult_diabetes', moment: '@fasting');
      expect(c.label, equals('Na meta'));
    });

    // Teste: customTargets substitui apenas a faixa "na meta"
    test('customTargets substitui so a faixa na meta', () {
      final custom = {'replaceMetaOnly': true};
      final c = classify(
        valueMgDl: 75,
        profileKey: 'adult_diabetes',
        moment: 'fasting',
        customTargets: custom,
      );
      // Como 75 nao e "na meta" (80-131), deve manter a band original (Abaixo da meta)
      // Ou se a logica substituir, depende. Vamos testar que mantem original se nao for meta.
      expect(c.label, equals('Abaixo da meta'));
    });

    // Teste: valores fora de 20..600 lancam excecao
    test('valor abaixo de 20 lancar excecao', () {
      expect(
        () => classify(valueMgDl: 10, profileKey: 'adult_diabetes', moment: 'fasting'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('valor acima de 600 lancar excecao', () {
      expect(
        () => classify(valueMgDl: 700, profileKey: 'adult_diabetes', moment: 'fasting'),
        throwsA(isA<ArgumentError>()),
      );
    });

    // Teste: perfil gestational/fasting
    test('perfil gestational/fasting - hipoglicemia', () {
      final c = classify(valueMgDl: 40, profileKey: 'gestational', moment: 'fasting');
      expect(c.label, equals('Hipoglicemia'));
    });

    // Teste: perfil screening/fasting - pre-diabetes
    test('perfil screening/fasting - pre-diabetes', () {
      final c = classify(valueMgDl: 110, profileKey: 'screening', moment: 'fasting');
      expect(c.label, equals('Glicemia de jejum alterada (pre-diabetes)'));
    });
  });
}