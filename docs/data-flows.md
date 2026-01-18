# Оглавление

- [Назначение документа и scope](#назначение-документа-и-scope)
  - [Цель документа](#цель-документа)
  - [Что считается данными в контексте платформы](#что-считается-данными-в-контексте-платформы)
  - [Что намеренно не является предметом этого документа](#что-намеренно-не-является-предметом-этого-документа)
- [Security-first взгляд на data flows](#security-first-взгляд-на-data-flows)
  - [Data flows как security invariants](#data-flows-как-security-invariants)
  - [Почему это не data pipeline tutorial](#почему-это-не-data-pipeline-tutorial)
  - [Связь data flows и trust boundaries](#связь-data-flows-и-trust-boundaries)
- [High-level end-to-end AI data flows](#high-level-end-to-end-ai-data-flows)
  - [Общая цепочка](#общая-цепочка)
  - [Классы данных на этапах](#классы-данных-на-этапах)
  - [Критичность этапов и blast radius](#критичность-этапов-и-blast-radius)
- [Trust boundaries в потоках данных](#trust-boundaries-в-потоках-данных)
  - [External ingress boundary](#external-ingress-boundary)
  - [Training boundary](#training-boundary)
  - [Promotion boundary](#promotion-boundary)
  - [Inference boundary](#inference-boundary)
  - [Serving / exposure boundary](#serving--exposure-boundary)
- [Ownership и ответственность на этапах](#ownership-и-ответственность-на-этапах)
  - [Ownership данных при ingress](#ownership-данных-при-ingress)
  - [Ownership во время training](#ownership-во-время-training)
  - [Ownership моделей в registry](#ownership-моделей-в-registry)
  - [Ownership при inference и serving](#ownership-при-inference-и-serving)
  - [Передача ответственности как архитектурное событие](#передача-ответственности-как-архитектурное-событие)
- [Promotion boundaries и gating-механизмы](#promotion-boundaries-и-gating-механизмы)
  - [Training → model registry](#training--model-registry)
  - [Model registry → inference](#model-registry--inference)
  - [Promotion как security decision](#promotion-как-security-decision)
  - [Что считается недопустимым bypass](#что-считается-недопустимым-bypass)
- [Enforcement точки и механизмы](#enforcement-точки-и-механизмы)
  - [Terraform-level enforcement](#terraform-level-enforcement)
  - [CI / pipeline enforcement](#ci--pipeline-enforcement)
  - [Policy-as-Code enforcement](#policy-as-code-enforcement)
  - [Kubernetes / runtime enforcement](#kubernetes--runtime-enforcement)
  - [AI-specific enforcement](#ai-specific-enforcement)
- [Маппинг потоков на контролы безопасности](#маппинг-потоков-на-контролы-безопасности)
  - [Связь с security-model.md](#связь-с-security-modelmd)
  - [Какие угрозы закрываются](#какие-угрозы-закрываются)
  - [Обязательные точки enforcement](#обязательные-точки-enforcement)
- [Аудит и трассируемость потоков](#аудит-и-трассируемость-потоков)
  - [Что логируется](#что-логируется)
  - [Где хранится audit trail](#где-хранится-audit-trail)
  - [Связь audit данных с governance](#связь-audit-данных-с-governance)
- [Диаграммы и визуальная модель](#диаграммы-и-визуальная-модель)
  - [High-level data flow diagram](#high-level-data-flow-diagram)
  - [Trust boundaries overlay](#trust-boundaries-overlay)
  - [Promotion boundary schematic](#promotion-boundary-schematic)
- [Связь data flows с policy-as-code реализацией](#связь-data-flows-с-policy-as-code-реализацией)
  - [Ingress → Training](#ingress--training)
  - [Training (внутренний AI-контур)](#training-внутренний-ai-контур)
  - [Training → Model Registry (Promotion Boundary)](#training--model-registry-promotion-boundary)
  - [Model Registry (trusted AI artifacts)](#model-registry-trusted-ai-artifacts)
  - [Model Registry → Inference](#model-registry--inference)
  - [Inference (runtime execution)](#inference-runtime-execution)
  - [Inference → Serving](#inference--serving)
  - [Архитектурная инварианта](#архитектурная-инварианта)
- [Explicit non-goals и ограничения модели](#explicit-non-goals-и-ограничения-модели)
  - [Что платформа сознательно не решает](#что-платформа-сознательно-не-решает)
  - [Границы ответственности платформы](#границы-ответственности-платформы)
- [Связь с другими документами](#связь-с-другими-документами)
  - [security-model.md](#security-modelmd)
  - [workflows.md](#workflowsmd)
  - [architecture.md](#architecturemd)

---

# Назначение документа и scope

`data-flows.md` – потоки данных и AI-контуры платформы

## Цель документа
Зафиксировать **архитектурную модель потоков данных и моделей** в AI-платформе, где данные и артефакты ИИ рассматриваются как критические активы.  
Документ описывает **границы доверия, точки передачи ответственности и enforcement**, а не реализацию data pipeline.

## Что считается данными в контексте платформы
– исходные датасеты (raw / curated / sensitive)  
– производные данные обучения  
– модели (artifacts, weights, metadata)  
– inference outputs  
– telemetry и audit-данные, связанные с AI-процессами  

Все перечисленное рассматривается как **security-relevant assets**.

## Что намеренно не является предметом этого документа
– ML-алгоритмы и качество моделей  
– выбор фреймворков обучения  
– оптимизация inference  
– реализация ETL и feature engineering  
– бизнес-логика использования моделей  

---

# Security-first взгляд на data flows

## Data flows как security invariants
Каждый поток данных:
– пересекает trust boundary  
– изменяет ownership  
– требует явного policy decision  

Если поток не описан — он **запрещён по умолчанию**.

## Почему это не data pipeline tutorial
Цель — не показать «как обучать модель»,  
а зафиксировать:
– **кто имеет право перемещать данные**  
– **где происходит promotion**  
– **какие контуры изолированы намеренно**  

## Связь data flows и trust boundaries
Data flow = допустимый переход между границами доверия.  
Любой несанкционированный переход считается инцидентом.

---

# High-level end-to-end AI data flows

## Общая цепочка
ingress → training → model registry → inference → serving

## Классы данных на этапах
**Ingress**
– внешние данные  
– потенциально недоверенные источники  

**Training**
– чувствительные датасеты  
– временные производные данные  

**Model registry**
– модели как управляемые артефакты  
– metadata и provenance  

**Inference**
– модели в runtime-контуре  
– входные запросы  

**Serving**
– inference outputs  
– публичные или полу-публичные интерфейсы  

## Критичность этапов и blast radius
– ingress: риск загрязнения  
– training: риск утечки данных  
– registry: риск компрометации supply chain  
– inference: риск несанкционированного доступа  
– serving: риск внешнего воздействия  

---

# Trust boundaries в потоках данных

## External ingress boundary
Граница между внешним миром и платформой.  
Недоверенная зона.

Контекст:
– нет implicit trust  
– все данные считаются потенциально вредоносными  

## Training boundary
Изолированный вычислительный контур.  
Доступ строго ограничен.

Контекст:
– минимальный human-доступ  
– отсутствие прямого egress без разрешения  

## Promotion boundary
Ключевая граница доверия.  
Между обучением и эксплуатацией.

Контекст:
– только контролируемые переходы  
– обязательная проверка и аудит  

## Inference boundary
Runtime-контур исполнения моделей.

Контекст:
– модели считаются trusted artifacts  
– входные данные снова считаются недоверенными  

## Serving / exposure boundary
Граница экспонирования результатов.

Контекст:
– защита от data leakage  
– контроль объёма и характера ответов  

---

# Ownership и ответственность на этапах

## Ownership данных при ingress
Владелец: внешний источник / data provider.  
Платформа **не доверяет** данным.

Ответственность:
– валидация  
– классификация  
– принятие или отклонение  

## Ownership во время training
Ownership переходит платформе.

Ответственность:
– защита данных  
– изоляция вычислений  
– предотвращение утечек  

## Ownership моделей в registry
Модель становится **управляемым артефактом**.

Ответственность:
– контроль версий  
– provenance  
– запрет несанкционированных изменений  

## Ownership при inference и serving
Ownership модели остаётся у платформы.  
Ответственность за outputs — совместная:
– платформа  
– потребляющая система  

## Передача ответственности как архитектурное событие
Любая смена ownership:
– фиксируется  
– требует policy decision  
– оставляет audit trail  

---

# Promotion boundaries и gating-механизмы

## Training – model registry
Критическая точка.

Разрешено только если:
– модель прошла валидацию  
– provenance подтверждён  
– policy checks успешны  

## Model registry – inference
Promotion в runtime-контур.

Разрешено только если:
– модель подписана  
– версия зафиксирована  
– environment соответствует policy  

## Promotion как security decision
Promotion ≠ копирование файла.  
Это **security event**.

## Что считается недопустимым bypass
– прямой доступ training → inference  
– ручная подмена модели  
– обход registry  

---

# Enforcement точки и механизмы

## Terraform-level enforcement
– изоляция сетей  
– разделение аккаунтов / проектов  
– запрет несанкционированных связей  

## CI / pipeline enforcement
– проверки перед promotion  
– запрет деплоя без review  
– policy-as-code  

## Policy-as-Code enforcement
– OPA  
– Checkov  
– tfsec  

Используются как gate, а не advisory.

## Kubernetes / runtime enforcement
– namespace isolation  
– RBAC  
– network policies  

## AI-specific enforcement
– GPU isolation  
– data zones  
– запрет shared runtime  

---

# Маппинг потоков на контролы безопасности

## Связь с security-model.md
Все threats и controls определены там.  
Здесь — **применение по этапам**.

## Какие угрозы закрываются
– data poisoning  
– model tampering  
– privilege escalation  
– data exfiltration  

## Обязательные точки enforcement
– ingress  
– promotion boundaries  
– runtime access  

---

# Аудит и трассируемость потоков

## Что логируется
– факт перехода  
– субъект  
– объект  
– policy decision  

## Где хранится audit trail
– централизованно  
– неизменяемо  

## Связь audit данных с governance
Audit — часть governance, а не логирование «для галочки».

---

# Диаграммы и визуальная модель

## High-level data flow diagram
Показывает допустимые направления движения.

## Trust boundaries overlay
Накладывает границы доверия на flow.

## Promotion boundary schematic
Фиксирует точки принятия решений.

---

# Связь data flows с policy-as-code реализацией

Ниже каждый **AI data flow** связан с **реально существующими policy-файлами**.  
Формат намеренно плоский: flow → угрозы → enforcement.  
Это не каталог файлов, а **decision graph**, привязанный к репозиторию.

## Ingress → Training

– Смысл: приём внешних данных в обучающий контур (недоверенная зона → изолированный контур).
– Ключевые угрозы:
  – data poisoning  
  – публичный доступ к AI-контурам  
  – утечка чувствительных данных  

– Enforcement:
  – OPA Terraform:
    – `policies/opa/terraform/encryption.rego` — обязательное шифрование data-at-rest  
    – `policies/opa/terraform/regions.rego` — запрет недопустимых регионов хранения  
    – `policies/opa/terraform/tagging.rego` — классификация и ownership данных  
  – OPA AI:
    – `policies/opa/ai/no-public-ai.rego` — запрет публичных AI endpoint  
    – `policies/opa/ai/ai-data-isolation.rego` — изоляция AI data-зон  
  – tfsec:
    – `policies/tfsec/ai/ai-storage.toml` — небезопасные storage-конфигурации  
  – Checkov:
    – `policies/checkov/ai/ai_network.yaml` — публичные ingress / network paths  

## Training (внутренний AI-контур)

– Смысл: обработка чувствительных данных и обучение моделей.
– Ключевые угрозы:
  – lateral movement  
  – несанкционированный egress  
  – совместное использование GPU  

– Enforcement:
  – OPA AI:
    – `policies/opa/ai/ai-data-isolation.rego` — строгая изоляция training data  
    – `policies/opa/ai/ai-gpu-restrictions.rego` — запрет shared GPU между контурами  
  – OPA Terraform:
    – `policies/opa/terraform/tagging.rego` — разделение training / inference ресурсов  
  – tfsec:
    – `policies/tfsec/ai/ai-storage.toml` — контроль временных data volumes  

## Training → Model Registry (Promotion Boundary)

– Смысл: передача модели из недоверенного training-контура в управляемый registry.
– Архитектурный факт: promotion = security decision.
– Ключевые угрозы:
  – подмена модели  
  – неаудируемая загрузка  
  – обход registry  

– Enforcement:
  – OPA Terraform:
    – `policies/opa/terraform/encryption.rego` — защита model artifacts  
    – `policies/opa/terraform/tagging.rego` — фиксация provenance  
  – Checkov:
    – `policies/checkov/ai/ai_encryption.yaml` — обязательное шифрование моделей  
  – OPA AI:
    – `policies/opa/ai/ai-data-isolation.rego` — запрет прямого доступа training → inference  

## Model Registry (trusted AI artifacts)

– Смысл: централизованное хранилище доверенных моделей.
– Ключевые угрозы:
  – tampering  
  – rollback атак  
  – ручные изменения  

– Enforcement:
  – OPA Terraform:
    – `policies/opa/terraform/encryption.rego` — защита artifacts  
    – `policies/opa/terraform/tagging.rego` — версия, owner, lifecycle  
  – Checkov:
    – `policies/checkov/ai/ai_encryption.yaml` — immutable storage assumptions  

## Model Registry → Inference

– Смысл: допуск модели в runtime-контур.
– Ключевые угрозы:
  – запуск неподписанной модели  
  – смешение training и inference ресурсов  

– Enforcement:
  – OPA AI:
    – `policies/opa/ai/ai-gpu-restrictions.rego` — выделенные inference GPU  
    – `policies/opa/ai/ai-data-isolation.rego` — изоляция inference data  
  – OPA Terraform:
    – `policies/opa/terraform/tagging.rego` — environment-aware promotion  

## Inference (runtime execution)

– Смысл: выполнение trusted моделей над недоверенными входными данными.
– Ключевые угрозы:
  – privilege escalation  
  – data leakage  
  – shared runtime  

– Enforcement:
  – OPA AI:
    – `policies/opa/ai/ai-gpu-restrictions.rego` — запрет shared GPU  
    – `policies/opa/ai/ai-data-isolation.rego` — runtime data boundaries  
  – OPA Terraform:
    – `policies/opa/terraform/naming.rego` — недвусмысленное разделение контуров  

## Inference → Serving

– Смысл: экспонирование inference outputs за пределы платформы.
– Ключевые угрозы:
  – утечка чувствительных данных  
  – публичный AI доступ  

– Enforcement:
  – OPA AI:
    – `policies/opa/ai/no-public-ai.rego` — запрет публичного serving без explicit allow  
  – Checkov:
    – `policies/checkov/ai/ai_network.yaml` — контроль exposure paths  
  – OPA Terraform:
    – `policies/opa/terraform/regions.rego` — географические ограничения serving  

## Архитектурная инварианта

– Нет допустимого data flow без policy.
– Promotion всегда проходит через AI-specific enforcement.
– AI, данные и модели рассматриваются как **единый security-контур**.
– Policies фиксируют **допустимую архитектуру**, а не проверяют стиль.

---

# Explicit non-goals и ограничения модели

## Что платформа сознательно не решает
– корректность ML  
– bias моделей  
– интерпретируемость  

## Границы ответственности платформы
Платформа гарантирует **контроль и изоляцию**,  
но не бизнес-результат моделей.

---

# Связь с другими документами

## security-model.md
Threats → controls → enforcement.

## workflows.md
Когда и при каких условиях происходят переходы.

## architecture.md
Общий контур и слои платформы.
