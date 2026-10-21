import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'tables.dart';

/// AppDatabase drift - offline-first, todos os dados ficam no aparelho.
class AppDatabase extends Database {
  @override
  final List<Table> tables = [
    Patients(),
    Readings(),
    Classifications(),
    ReminderSettings(),
  ];

  /// Insere ou substitui o paciente (sempre apenas 1 registro ativo).
  Future<int> upsertPatient({
    required String name,
    required String birthDate,
    required String sex, // M/F/O
    double? weightKg,
    double? heightCm,
    required String conditionType, // diabetes_tipo_1, diabetes_tipo_2, pre_diabetes, diabetes_gestacional, hipoglicemia, outra
    String? medications,
    String? doctorName,
    String? doctorContact,
    String? emergencyContactName,
    String? emergencyContactPhone,
    Map<String, dynamic>? customTargets,
    required Profile profileKey, // adult_diabetes, gestational, screening
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await (select(patients)..limit(1).get());
    if (existing.isNotEmpty) {
      // Substitui o existente
      return await (update(patients)..set:
        Patients(
          name: name,
          birthDate: birthDate,
          sex: sex,
          weightKg: weightKg,
          heightCm: heightCm,
          conditionType: conditionType,
          medications: medications,
          doctorName: doctorName,
          doctorContact: doctorContact,
          emergencyContactName: emergencyContactName,
          emergencyContactPhone: emergencyContactPhone,
          customTargets: customTargets != null ? jsonEncode(customTargets) : const Null(),
          profileKey: profileKey.toString(),
          createdAt: existing.first.createdAt,
          updatedAt: now,
        ).run());
    } else {
      // Insere novo
      return await (insert(patients)..set:
        Patients(
          name: name,
          birthDate: birthDate,
          sex: sex,
          weightKg: weightKg,
          heightCm: heightCm,
          conditionType: conditionType,
          medications: medications,
          doctorName: doctorName,
          doctorContact: doctorContact,
          emergencyContactName: emergencyContactName,
          emergencyContactPhone: emergencyContactPhone,
          customTargets: customTargets != null ? jsonEncode(customTargets) : const Null(),
          profileKey: profileKey.toString(),
          createdAt: now,
          updatedAt: now,
        ).run());
    }
  }

  /// Insere uma nova leitura (com validacao de nao ter mais de 1 por (data, period) na aplicacao)
  Future<int> insertReading({
    required int patientId,
    required int valueMgDl,
    required String period,
    required String moment,
    required DateTime measuredAt,
    String? note,
    List<String>? symptoms,
    required Classification classification,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return await (insert(readings)..set:
      Readings(
        patientId: patientId,
        valueMgDl: valueMgDl,
        period: period,
        moment: moment,
        momentIndex: _momentToIndex(moment),
        measuredAt: measuredAt.toUtc().millisecondsSinceEpoch.toDouble(),
        note: note,
        symptoms: symptoms,
        classificationId: classification.id,
        severity: classification.severity.index,
        createdAt: now,
      ).run());
  }

  int _momentToIndex(String moment) {
    final map = {'morning': 1, 'afternoon': 2, 'night': 3, 'fasting': 1, 'pre_meal': 1, 'post_meal_2h': 2, 'bedtime': 3};
    return map[moment] ?? 0;
  }

  /// Insere ou atualiza configuracao de lembrete
  Future<int> upsertReminder({
    required int patientId,
    required String period,
    required String time, // HH:mm
    required bool enabled,
  }) async {
    final existing = await (select(reminderSettings)..limit(1).get());
    final now = DateTime.now().millisecondsSinceEpoch;
    if (existing.isNotEmpty) {
      return await (update(reminderSettings)..set:
        ReminderSettings(
          id: existing.first.id,
          patientId: patientId,
          period: period,
          time: time,
          enabled: enabled,
          createdAt: existing.first.createdAt,
          updatedAt: now,
        ).run());
    } else {
      return await (insert(reminderSettings)..set:
        ReminderSettings(
          patientId: patientId,
          period: period,
          time: time,
          enabled: enabled,
          createdAt: now,
          updatedAt: now,
        ).run());
    }
  }

  /// Remove todos os dados (para o botao "apagar todos" nas configuracoes)
  Future<void> deleteAllData() async {
    await (delete(patients).go());
    await (delete(readings).go());
    await (delete(classifications).go());
    await (delete(reminderSettings).go());
  }
}

/// Convenience builders para insercao facil
final AppDatabase appDatabase = AppDatabase.open(':memory:');
  // Note: Em producao, sera aberto um banco SQLite real via drift gen.
// Para testes e desenvolvimento inicial usamos :memory:.

/// Perfil mapeamento extension
extension ProfileExtension on Profile {
  String toKey() => switch (this) {
    Profile.adultDiabetes => 'adult_diabetes',
    Profile.gestational => 'gestational',
    Profile.screening => 'screening',
  };
}