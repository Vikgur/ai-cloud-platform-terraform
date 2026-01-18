# Оглавление

- [Назначение документа и scope](#назначение-документа-и-scope)
- [Security mindset и threat-driven подход](#security-mindset-и-threat-driven-подход)
- [Активы (Assets)](#активы-assets)
  - [Инфраструктурные активы](#инфраструктурные-активы)
  - [Kubernetes и runtime активы](#kubernetes-и-runtime-активы)
  - [AI и данные](#ai-и-данные)
  - [Управляющие и governance активы](#управляющие-и-governance-активы)
- [Акторы (Actors)](#акторы-actors)
  - [Human actors](#human-actors)
  - [Non-human actors](#non-human-actors)
  - [Внешние системы](#внешние-системы)
- [Границы доверия и зоны ответственности](#границы-доверия-и-зоны-ответственности)
- [Ландшафт угроз (Threat Model)](#ландшафт-угроз-threat-model)
  - [Угрозы на уровне cloud и сети](#угрозы-на-уровне-cloud-и-сети)
  - [Угрозы на уровне Terraform и CI](#угрозы-на-уровне-terraform-и-ci)
  - [Угрозы на уровне Kubernetes runtime](#угрозы-на-уровне-kubernetes-runtime)
  - [Угрозы на уровне AI и данных](#угрозы-на-уровне-ai-и-данных)
  - [Угрозы governance и процессов](#угрозы-governance-и-процессов)
- [Контроли безопасности (Controls)](#контроли-безопасности-controls)
  - [Preventive controls](#preventive-controls)
  - [Detective controls](#detective-controls)
  - [Corrective controls](#corrective-controls)
- [Связь угроз и контролов (Threat → Control Mapping)](#связь-угроз-и-контролов-threat--control-mapping)
- [Уровни enforcement](#уровни-enforcement)
  - [Terraform-level enforcement](#terraform-level-enforcement)
  - [CI-level enforcement](#ci-level-enforcement)
  - [Kubernetes-level enforcement](#kubernetes-level-enforcement)
  - [AI runtime enforcement](#ai-runtime-enforcement)
  - [Governance enforcement](#governance-enforcement)
- [Роли, доступ и привилегии](#роли-доступ-и-привилегии)
  - [IAM роли](#iam-роли)
  - [Kubernetes RBAC](#kubernetes-rbac)
  - [OIDC и federated доступ](#oidc-и-federated-доступ)
- [Break-glass и экстренные сценарии](#break-glass-и-экстренные-сценарии)
- [Explicit non-goals и ограничения модели](#explicit-non-goals-и-ограничения-модели)
- [Связь с другими документами](#связь-с-другими-документами)

---

# Назначение документа и scope

`security-model.md` — модель безопасности платформы.

Документ описывает **системную модель безопасности** Sovereign AI Cloud Platform.  
Он фиксирует, какие активы защищаются, от каких угроз, какими контролами и на каком уровне enforcement.

Документ:
- не дублирует код и политики
- не является чеклистом инструментов
- не описывает application-level security

Цель — показать **как мыслит Senior DevSecOps**, проектируя безопасность как архитектуру.

---

# Security mindset и threat-driven подход

Безопасность платформы строится **от угроз**, а не от инструментов.

Последовательность мышления:
1. Определить активы  
2. Определить акторов  
3. Зафиксировать границы доверия  
4. Смоделировать угрозы  
5. Привязать угрозы к контролам  
6. Реализовать enforcement на нужном уровне  

Security рассматривается как **система ограничений**, а не как набор best practices.

---

# Активы (Assets)

## Инфраструктурные активы

- Cloud-аккаунты и подписки  
- Сетевые сегменты и routing  
- Compute-ресурсы (CPU, GPU)  
- Storage и state backend  

Компрометация этих активов приводит к системному риску.

## Kubernetes и runtime активы

- Control plane  
- Worker-ноды  
- Runtime конфигурация  
- Service accounts и secrets  

Это активы с высоким blast radius.

## AI и данные

- Training datasets  
- Модели и артефакты  
- Registry и inference endpoints  

Данные и модели — ключевые суверенные активы.

## Управляющие и governance активы

- Terraform state  
- CI pipelines  
- Policy-as-Code  
- Audit logs и decision logs  

Компрометация governance активов эквивалентна потере контроля.

---

# Акторы (Actors)

## Human actors

- Platform инженеры  
- Security инженеры  
- Incident responders  

Human-доступ рассматривается как **наименее надёжный**.

## Non-human actors

- CI/CD системы  
- Terraform automation  
- Kubernetes workloads  
- AI сервисы  

Non-human доступ — предпочтительный.

## Внешние системы

- Identity providers  
- Audit и monitoring системы  
- External integrations  

Любое внешнее взаимодействие рассматривается как недоверенное.

---

# Границы доверия и зоны ответственности

Платформа явно моделирует trust boundaries:

- Между окружениями  
- Между control plane и runtime  
- Между Terraform и Kubernetes  
- Между AI training и inference  
- Между human и non-human доступом  

Каждая граница:
- задокументирована
- защищена политиками
- проверяема аудитом

---

# Ландшафт угроз (Threat Model)

## Угрозы на уровне cloud и сети

- Lateral movement  
- Misconfiguration сети  
- Overprivileged IAM  

## Угрозы на уровне Terraform и CI

- Неавторизованный apply  
- Подмена state  
- Обход policy checks  

## Угрозы на уровне Kubernetes runtime

- Privilege escalation  
- Escape из pod  
- Неконтролируемый доступ к secrets  

## Угрозы на уровне AI и данных

- Несанкционированный доступ к данным  
- Подмена моделей  
- Использование GPU вне разрешённого контекста  

## Угрозы governance и процессов

- Bypass процессов  
- Неаудируемые изменения  
- Злоупотребление экстренным доступом  

---

# Контроли безопасности (Controls)

## Preventive controls

- IAM least privilege  
- Policy-as-Code  
- Network isolation  
- Runtime constraints  

## Detective controls

- Audit logs  
- Monitoring и alerts  
- Policy violations tracking  

## Corrective controls

- Автоматический rollback  
- Revocation доступа  
- Incident workflows  

Контроли распределены по слоям.

---

# Связь угроз и контролов (Threat → Control Mapping)

Каждая критическая угроза:
- сопоставлена с одним или несколькими контролами  
- реализована минимум на одном enforcement-уровне  
- имеет audit trail  

Отсутствие маппинга считается архитектурным дефектом.

---

# Уровни enforcement

## Terraform-level enforcement

- Ограничения ресурсов  
- Security defaults  
- Запрет небезопасных конфигураций  

## CI-level enforcement

- OPA  
- Checkov  
- tfsec  
- Mandatory reviews  

CI — первая линия защиты.

## Kubernetes-level enforcement

- RBAC  
- Admission controls  
- Runtime policies  

## AI runtime enforcement

- GPU isolation  
- Namespace separation  
- Data access policies  

## Governance enforcement

- Запрет обхода процессов  
- Exception workflows  
- Decision logging  

Governance — последняя линия защиты.

---

# Роли, доступ и привилегии

## IAM роли

- Минимальные привилегии  
- Разделение по функциям  
- Отсутствие shared credentials  

## Kubernetes RBAC

- Service-account-first подход  
- Ограничение namespace scope  

## OIDC и federated доступ

- Отсутствие long-lived ключей  
- Централизованная идентификация  

---

# Break-glass и экстренные сценарии

Экстренный доступ:
- строго ограничен по времени  
- полностью аудируем  
- требует post-incident нормализации  

Break-glass — **исключение, а не инструмент управления**.

Подробно см. `break-glass.md`.

---

# Explicit non-goals и ограничения модели

Модель безопасности намеренно **не покрывает**:

- Application-level security  
- ML model robustness  
- Data science пайплайны  
- User-facing API security  

Это архитектурное решение, а не упущение.

---

# Связь с другими документами

- `architecture.md` — архитектурные границы и слои  
- `workflows.md` — lifecycle изменений  
- `data-flows.md` — движение данных и enforcement  
- `break-glass.md` — экстренные сценарии  

Модель безопасности является связующим слоем между архитектурой и процессами.
