# Оглавление

- [Назначение документа и scope](#назначение-документа-и-scope)
- [Terraform state как security-asset](#terraform-state-как-security-asset)
  - [Почему state — критичный актив](#почему-state--критичный-актив)
  - [Blast radius при компрометации state](#blast-radius-при-компрометации-state)
- [Модель угроз для state](#модель-угроз-для-state)
  - [Угрозы конфиденциальности](#угрозы-конфиденциальности)
  - [Угрозы целостности](#угрозы-целостности)
  - [Угрозы доступности](#угрозы-доступности)
- [Архитектура backend хранения state](#архитектура-backend-хранения-state)
  - [Тип backend и формат state](#тип-backend-и-формат-state)
  - [Изоляция по окружениям](#изоляция-по-окружениям)
  - [Шифрование state](#шифрование-state)
- [Модель доступа к state](#модель-доступа-к-state)
  - [IAM и роли доступа](#iam-и-роли-доступа)
  - [KMS и управление ключами](#kms-и-управление-ключами)
  - [Non-human доступ к backend](#non-human-доступ-к-backend)
- [Locking и защита от race conditions](#locking-и-защита-от-race-conditions)
  - [Зачем нужен locking](#зачем-нужен-locking)
  - [Последствия отсутствия locking](#последствия-отсутствия-locking)
- [Versioning и неизменяемость](#versioning-и-неизменяемость)
  - [История изменений state](#история-изменений-state)
  - [Защита от rollback атак](#защита-от-rollback-атак)
- [Backup и восстановление](#backup-и-восстановление)
  - [Политика резервного копирования](#политика-резервного-копирования)
  - [Disaster recovery сценарии](#disaster-recovery-сценарии)
  - [Границы ответственности recovery](#границы-ответственности-recovery)
- [Роль state в workflow изменений](#роль-state-в-workflow-изменений)
  - [Связь с CI/CD](#связь-с-cicd)
  - [Связь с promotion](#связь-с-promotion)
  - [Drift detection](#drift-detection)
- [Break-glass доступ к state](#break-glass-доступ-к-state)
  - [Условия применения](#условия-применения)
  - [Ограничения и TTL](#ограничения-и-ttl)
  - [Аудит и post-incident действия](#аудит-и-post-incident-действия)
- [Explicit non-goals и ограничения](#explicit-non-goals-и-ограничения)
- [Связь с другими документами](#связь-с-другими-документами)

---

# Назначение документа и scope

`state-backend.md` – terraform state backend и модель безопасности.

Документ описывает **архитектурную модель хранения, защиты и использования Terraform state**.  
State рассматривается не как техническая деталь Terraform, а как **критический security-asset**, компрометация которого равна компрометации всей платформы.

Документ:  
– не дублирует Terraform-документацию  
– не описывает конкретные HCL-файлы backend  
– фиксирует security-инварианты и blast-radius мышление  

---

# Terraform state как security-asset

## Почему state — критичный актив

Terraform state содержит:  
– полную карту инфраструктуры  
– реальные идентификаторы ресурсов  
– связи между security-доменами  
– чувствительные значения (even if encrypted at rest)  

Компрометация state:  
– раскрывает архитектуру  
– упрощает lateral movement  
– позволяет подготовить targeted атаки  

State = **control plane инфраструктуры**.

## Blast radius при компрометации state

Без архитектурных мер:  
– один state = вся платформа  
– один доступ = полный контроль  

В данной архитектуре blast radius снижается за счёт:  
– изоляции state по environment  
– строгой IAM-модели  
– отсутствия human-доступа  
– обязательного locking  

---

# Модель угроз для state

## Угрозы конфиденциальности

– утечка sensitive outputs  
– раскрытие network / IAM структуры  
– анализ security posture  

## Угрозы целостности

– подмена state  
– rollback на уязвимое состояние  
– race-condition corruption  

## Угрозы доступности

– потеря state  
– потеря locking  
– блокировка apply  

---

# Архитектура backend хранения state

## Тип backend и формат state

– Используется remote backend.  
– State не хранится локально.  
– Формат — стандартный Terraform state с включённым encryption-at-rest.  

## Изоляция по окружениям

– Dev / Stage / Prod имеют разные backend.  
– Нет shared bucket / storage.  
– Нет shared locking.  

Изоляция environment = изоляция blast radius.

## Шифрование state

– Шифрование at rest обязательно.  
– Используется KMS с ограниченным доступом.  
– Ключи не переиспользуются между окружениями.  

---

# Модель доступа к state

## IAM и роли доступа

– Минимальный набор ролей:  
  - CI apply role  
  - CI plan role  

– Нет wildcard-доступов.  
– Нет shared credentials.  

## KMS и управление ключами

– KMS ключи принадлежат security-домену.  
– Terraform не управляет жизненным циклом ключей.  
– Rotation включена.  

## Non-human доступ к backend

– Доступ к backend есть только у CI service accounts.  
– Human-доступ отсутствует по умолчанию.  
– OIDC + short-lived credentials.  

---

# Locking и защита от race conditions

## Зачем нужен locking

– Исключение параллельных apply.  
– Защита целостности state.  
– Предсказуемость изменений.  

## Последствия отсутствия locking

– Corrupted state.  
– Необратимые расхождения.  
– Инциденты уровня platform outage.  

Locking рассматривается как **обязательный security-control**.

---

# Versioning и неизменяемость

## История изменений state

– Versioning backend включён.  
– Каждое изменение state трассируемо.  
– Возможен forensic анализ.  

## Защита от rollback атак

– Rollback невозможен без явного вмешательства.  
– Откат требует break-glass.  
– Откат фиксируется как security event.  

---

# Backup и восстановление

## Политика резервного копирования

– Backup state — автоматический.  
– Хранение с ограниченным доступом.  
– Backup не доступен CI напрямую.  

## Disaster recovery сценарии

– Потеря CI  
– Потеря backend endpoint  
– Частичная потеря state  

Для каждого сценария:  
– восстановление state  
– повторная инициализация CI  

## Границы ответственности recovery

– Recovery state ≠ recovery данных AI.  
– Recovery state ≠ восстановление workloads.  

---

# Роль state в workflow изменений

## Связь с CI/CD

– CI инициализирует backend.  
– CI управляет locking.  
– CI фиксирует state transitions.  

## Связь с promotion

– Promotion = использование другого backend.  
– State не переносится между env.  
– Promotion не копирует state.  

## Drift detection

– Drift = security incident.  
– Drift обнаруживается сравнением state и reality.  
– Ручное исправление drift запрещено.  

---

# Break-glass доступ к state

## Условия применения

– Потеря управления CI.  
– Повреждён state.  
– Инцидент уровня platform outage.  

## Ограничения и TTL

– Временный доступ.  
– Минимальный scope.  
– Автоматическое истечение прав.  

## Аудит и post-incident действия

– Все действия логируются.  
– Обязательный post-mortem.  
– Возврат к CI-only доступу.  

---

# Explicit non-goals и ограничения

– Документ не описывает конкретный backend-провайдер.  
– Не описывает команды Terraform.  
– Не заменяет workflows.md.  

---

# Связь с другими документами

– workflows.md — как state участвует в lifecycle изменений.  
– security-model.md — угрозы и контролы для state.  
– break-glass.md — экстренный доступ.  
– architecture.md — где state закреплён архитектурно.
