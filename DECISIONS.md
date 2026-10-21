# DECISIONS.md - GlicoCare

## Questoes de projeto e decisões tomadas

### 1. Linguagem e Stack
- **Flutter (stable) + Dart 3**: Escolhido para multi-plataforma, mas foco apenas em Android (minSdk 23).
- **Riverpod**: Para estado, em vez de Provider antigo, por ser mais forte tipado e testável.
- **go_router**: Para navegação, mais declarativo e type-safe que o Routing do Flutter tradicional.
- **Drift + sqlite3_flutter_libs**: Banco offline-first. O SQLite nativo via `sqlite3_flutter_libs` garante performance e controle total sobre o esquema, sem depender de ORMs mais pesados.
- **fl_chart** para graficos: escolhido por ser leve e nativo em Flutter, sem dependencias externas pesadas.
- **pdf + printing** para relatorios: a biblioteca `pdf` e `printing` sao as mais maduras para gerar e imprimir PDFs no Flutter.
- **lottie** para animacoes: JSONs leves offline. Se nao houver JSONs locais, usaremos animacoes implicitas do Flutter (`AnimatedContainer`, etc.) para evitar dependencias extras.
- **google_fonts (Nunito/Poppins)**: Baixadas para `assets/fonts` para garantir offline. Caso nao sejam encontradas, o Flutter usa as fontes padrao do sistema.

### 2. Motor de Regras (Rules Engine)
- As faixas de referencia ficam em `assets/rules/glicemia_rules_v1.json`, versionado (v1.0.0).
- O `RulesRepository` carrega o JSON e resolve aliases (`@xxx` -> chave correspondente).
- `customTargets` substitui apenas a faixa "na meta", preservando hipoglicemia e alerta critico.
- Validacao de valores: 20..600 mg/dL. Fora deste range, lancar excecao com mensagem "Confira o valor digitado".
- `needsMedicalAttention` e `true` automaticamente para severity 0 e 4, mesmo que nao esteja no JSON.
- O campo `needsMedicalValidation=true` no JSON dispara o aviso em Configuracoes > Sobre.

### 3. Perfis e Momentos
- `conditionType` no paciente mapeia para `profileKey`:
  - diabetes_tipo_1, diabetes_tipo_2, hipoglicemia, outra -> adult_diabetes
  - diabetes_gestacional -> gestational
  - pre_diabetes -> screening
- Momentos padrao sugeridos por periodo (editaveis):
  - morning -> fasting
  - afternoon -> pre_meal (ou post_meal_2h)
  - night -> bedtime (ou pre_meal)
- O JSON tem faixas para: fasting, pre_meal, post_meal_2h, bedtime, post_meal_1h.

### 4. Tela e Design
- **Material 3**, `ColorScheme.fromSeed(seedColor: #0FA3A3)` (turquesa).
- Tokens de status (sempre com icone + texto):
  - critica/baixa grave: #D32F2F (vermelho, icone warning)
  - baixa: #1E88E5 (azul, icone arrow_downward)
  - na meta: #2E9E5B (verde, icone check_circle)
  - acima da meta: #F9A825 (amarelo, icone arrow_upward)
  - alta/critica alta: #EF6C00 / #D32F2F
- Fonte base 16sp, acessivel para idosos.
- Ilustracoes SVG em `assets/illustrations/` (gota, glicosimetro, sol, lua, coracao, grafico, estado vazio, onboarding x3).
- Uso de `flutter_svg` para SVGss.
- Tema claro/escuro/sistema completos, contraste AA minimo.
- Suporte a textScaleFactor ate 1.4.

### 5. Lembretes
- Notificacao local diaria por periodo (manha/tarde/noite).
- Pedir permisao de notificacao (Android 13+) e de alarmes exatos quando aplicavel.
- Reagendar apos reboot.
- Se a leitura do periodo ja foi registrada no dia, nao notificar.

### 6. Seguranca, Privacidade e Avisos
- Dados somente locais; sem analytics, sem rede.
- Nao pedir permissao de internet alem do necessario (manter INTERNET apenas se algum pacote exigir; preferir remover).
- Aviso fixo na tela de resultado: "O GlicoCare e uma ferramenta de acompanhamento e nao substitui avaliacao medica. Nao use para ajustar doses de insulina sem orientacao do seu medico."
- O app NAO calcula nem sugere dose de insulina ou medicamento.
- Medicao isolada nunca "diagnostica": usar sempre texto como "compativel com... requer confirmacao medica".

### 7. Testes
- `test/rules_engine_test.dart`: cobrir fronteiras exatas para cada perfil e momento, alias resolvido, customTargets, valores fora de 20..600.
- `test/reading_repo_test.dart`: 1 leitura por (dia, periodo), substituicao, consultas por intervalo, calculo de media e % na meta.
- Todos os testes devem passar antes de cada push.

### 8. Build e CI/CD
- Workflow: `.github/workflows/build-apk.yml`
- Build em `ubuntu-latest` com `temurin 17`, `flutter stable`, `dart`.
- Steps: `flutter pub get`, `dart run build_runner build`, `flutter analyze`, `flutter test`, `flutter build apk --release`.
- Upload de artifact `glicocare-apk`.
- Release automática na branch main via `softprops/action-gh-release`.
- Assinatura de release: debug quando nao houver keystore de release env; cair para debug para o build nunca quebrar.
- Documentar no README como gerar keystore e cadasrar nos GitHub Secrets.

### 9. Onboarding e Cadastro
- Onboarding em 3 telas com ilustracao + botao "Pular".
- Aceite de Termos/LGPD (checkbox obrigatorio) e aviso de que o app nao substitui orientacao medica.
- Cadastro em 3 passos (dados basicos -> tipo de enfermidade -> medico/contato/metas).
- Validacao de campos obrigatorios: nome, data de nascimento, tipo de enfermidade.

### 10. Observacoes Importantes para Validacao Medica
Todas as faixas do JSON de regras precisam de validacao medica:
- **Adulto Diabetes - jejum**: hipograve (<54), hipoglicemia (54-69), abaixo da meta (70-79), na meta (80-131), acima da meta (131-181), hiperglicemia (181-251), critica (>251).
- **Adulto Diabetes - pos-refeicao 2h**: hipograve (<54), hipoglicemia (54-70), na meta (70-180), acima da meta (180-251), critica (>251).
- **Adulto Diabetes - deitar**: hipograve (<54), hipoglicemia (54-70), abaixo da meta (70-90), na meta (90-151), acima da meta (151-201), hiperglicemia (201-251), critica (>251).
- **Screening - jejum**: hipoglicemia (0-70), normal (70-100), pre-diabetes (100-126), sugere diabetes (>126).
- **Screening - pos-refeicao 2h**: hipoglicemia (0-70), normal (70-140), pre-diabetes (140-200), sugere diabetes (>200).
- **Gestacional - jejum**: hipoglicemia (0-70), na meta (70-95), acima da meta (95-126), critica (>126).
- **Gestacional - pos 1h**: hipoglicemia (0-70), na meta (70-140), acima da meta (140-200), critica (>200).
- **Gestacional - pos 2h**: hipoglicemia (0-70), na meta (70-120), acima da meta (120-200), critica (>200).
Todas estas faixas devem exibir o disclaimer: "Valores de referencia para acompanhamento. Nao substitui avaliacao medica. Metas devem ser definidas pelo medico responsavel."