import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Chave UUID para pacientes (sempre apenas 1 registro ativo).
class PatientId extends IntColumn const {}

/// tabela do paciente (apenas 1 registro ativo)
class Patients extends Table {
  // Campos obrigatórios
  TextColumn get name => name('name');
  TextColumn get birthDate => name('birthDate');
  TextColumn get sex => name('sex');
  TextColumn get weightKg => name('weightKg');
  TextColumn get heightCm => name('heightCm');

  // Campos de condicao e tratamento
  TextColumn get conditionType => name('conditionType');
  BoolColumn get usesInsulin => name('usesInsulin');
  TextColumn get medications => name('medications');
  TextColumn get doctorName => name('doctorName');
  TextColumn get doctorContact => name('doctorContact');

  // Contato de emergencia
  TextColumn get emergencyContactName => name('emergencyContactName');
  TextColumn get emergencyContactPhone => name('emergencyContactPhone');

  // Metas personalizadas (JSON opcional)
  TextColumn get customTargets => name('customTargets');

  // Profile key: adult_diabetes, gestational, screening
  TextColumn get profileKey => name('profileKey');

  // Timestamps
  IntColumn get createdAt => name('createdAt');
  IntColumn get updatedAt => name('updatedAt');

  // Primary key: id autoincremental
  IntColumn get id => autoIncrement();
}

/// Leitura de glicemia
class Readings extends Table {
  IntColumn get id => autoIncrement();
  IntColumn get patientId => referencePatients(id);
  IntColumn get valueMgDl => value('valueMgDl');
  TextColumn get period => name('period'); // morning, afternoon, night
  TextColumn get moment => name('moment'); // fasting, pre_meal, post_meal_2h, bedtime, etc.
  IntColumn get momentIndex => name('momentIndex'); // index para ordenacao padrao
  RealColumn get measuredAt => real('measuredAt');
  TextColumn get note => name('note');
  ListColumn get symptoms => list('symptoms'); // opcional
  IntColumn get classificationId => reference(Classifications.id);
  IntColumn get severity => name('severity'); // 0..4
  RealColumn get createdAt => real('createdAt');

  // Restricao: no maximo 1 leitura por (data, period)
  // Isso sera aplicado na aplicacao, nao no schema drift puro
}

/// Classificacoes (resultado do motor de regras)
class Classifications extends Table {
  IntColumn get id => autoIncrement();
  IntColumn get readingId => reference(Readings.id);
  IntColumn get classificationValue => value('classificationValue'); // valor int do Classification.id string mapping
  TextColumn get label => name('label');
  IntColumn get severity => name('severity'); // 0..4
  TextColumn get direction => name('direction'); // low, in_range, high
  TextColumn get advice => name('advice');
  BoolColumn get needsMedicalAttention => name('needsMedicalAttention');
  RealColumn get createdAt => real('createdAt');
}

/// Configuracao de lembrete
class ReminderSettings extends Table {
  IntColumn get id => autoIncrement();
  IntColumn get patientId => referencePatients(id);
  TextColumn get period => name('period'); // morning, afternoon, night
  TextColumn get time => name('time'); // HH:mm
  BoolColumn get enabled => name('enabled');
  RealColumn get createdAt => real('createdAt');
  RealColumn get updatedAt => real('updatedAt');
}