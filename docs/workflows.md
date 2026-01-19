# Оглавление

- [Назначение документа и scope](#назначение-документа-и-scope)
- [Базовые принципы управления изменениями](#базовые-принципы-управления-изменениями)
  - [Immutability как архитектурное требование](#immutability-как-архитектурное-требование)
  - [Non-human first access](#non-human-first-access)
  - [Запрет ручных изменений](#запрет-ручных-изменений)
- [Жизненный цикл инфраструктуры](#жизненный-цикл-инфраструктуры)
  - [Инициация изменений](#инициация-изменений)
  - [Планирование и валидация](#планирование-и-валидация)
  - [Применение изменений](#применение-изменений)
  - [Post-apply контроль](#post-apply-контроль)
- [CI/CD как единственная точка применения](#cicd-как-единственная-точка-применения)
  - [Terraform workflow](#terraform-workflow)
  - [Policy-as-code gates](#policy-as-code-gates)
  - [Separation plan / apply](#separation-plan--apply)
  - [Environment promotion](#environment-promotion)
- [Жизненный цикл AI-инфраструктуры](#жизненный-цикл-ai-инфраструктуры)
  - [Training контур](#training-контур)
  - [Model registry контур](#model-registry-контур)
  - [Inference контур](#inference-контур)
  - [Promotion как security decision](#promotion-как-security-decision)
- [Promotion boundaries и gates](#promotion-boundaries-и-gates)
  - [Infra promotion](#infra-promotion)
  - [AI promotion](#ai-promotion)
  - [Что считается нарушением workflow](#что-считается-нарушением-workflow)
- [Human vs Non-human действия](#human-vs-non-human-действия)
  - [Допустимые human-действия](#допустимые-human-действия)
  - [Недопустимые human-действия](#недопустимые-human-действия)
  - [Роль service accounts и OIDC](#роль-service-accounts-и-oidc)
- [Break-glass как исключение из workflow](#break-glass-как-исключение-из-workflow)
  - [Когда допустим break-glass](#когда-допустим-break-glass)
  - [Как он интегрирован в lifecycle](#как-он-интегрирован-в-lifecycle)
- [Аудит и трассируемость изменений](#аудит-и-трассируемость-изменений)
  - [Что логируется](#что-логируется)
  - [Где хранится audit trail](#где-хранится-audit-trail)
- [Explicit non-goals и ограничения](#explicit-non-goals-и-ограничения)
- [Связь с другими документами](#связь-с-другими-документами)

---

# Назначение документа и scope

`workflows.md` – управление изменениями и workflow платформы.

Документ описывает **как изменения допускаются, проверяются, применяются и продвигаются** в платформе.  
Фокус — не на инструментах, а на **архитектурной модели управления изменениями**.

Документ намеренно:  
– не дублирует security-model.md  
– не описывает конкретные YAML / HCL реализации  
– фиксирует invariants и decision points  

---

# Базовые принципы управления изменениями

## Immutability как архитектурное требование

– Инфраструктура не «лечится», а пересоздаётся.  
– Compute, Kubernetes nodes, AI workloads считаются disposable.  
– Любое изменение = новая версия инфраструктуры.  

Следствие:  
– нет snowflake-нод  
– rollback = возврат к предыдущему состоянию через state  
– drift рассматривается как инцидент  

## Non-human first access

– Все изменения выполняются **service accounts**.  
– Human-доступ не является частью нормального workflow.  
– OIDC + short-lived credentials вместо static keys.  

Human:  
– проектирует  
– утверждает  
– анализирует  
но **не применяет напрямую**.

## Запрет ручных изменений

– Прямой `terraform apply` вне CI запрещён архитектурно.  
– Изменения через cloud console считаются нарушением модели.  
– Единственное исключение — break-glass (см. ниже).  

---

# Жизненный цикл инфраструктуры

## Инициация изменений

– Изменения начинаются с commit в Git.  
– Git — единственный source of truth.  
– Любое изменение должно быть воспроизводимо.  

## Планирование и валидация

– Terraform plan выполняется автоматически.  
– До apply проходят:  
  - OPA policies  
  - tfsec  
  - Checkov  

Невалидное изменение:  
– не доходит до apply  
– не требует ручного вмешательства  

## Применение изменений

– Apply выполняется только в CI.  
– Разделение plan / apply жёсткое.  
– Apply возможен только после review.  

## Post-apply контроль

– Проверка drift  
– Проверка соответствия policy  
– Аудит applied changes  

---

# CI/CD как единственная точка применения

## Terraform workflow

– CI поднимает изолированное окружение.  
– Используется remote backend + locking.  
– State изолирован по environment.  

## Policy-as-Code gates

– Политики не advisory, а blocking.  
– Policy failure = pipeline failure.  
– Нет возможности override без break-glass.  

## Separation plan / apply

– Plan доступен для review.  
– Apply — отдельный шаг с повышенными правами.  
– Apply не триггерится автоматически без условий.  

## Environment promotion

– Dev → Stage → Prod.  
– Нет прямых прыжков.  
– Promotion = повторное применение проверенного изменения.  

---

# Жизненный цикл AI-инфраструктуры

## Training контур

– Часто меняющийся.  
– Высокий риск.  
– Изолирован от inference.  

Изменения допустимы часто, но строго ограничены по blast radius.

## Model registry контур

– Стабильный.  
– Trusted artifacts only.  
– Promotion строго контролируется.  

## Inference контур

– Production-grade.  
– Минимальные изменения.  
– Максимальный контроль.  

## Promotion как security decision

– Модель не «переезжает», а **утверждается**.  
– Promotion = изменение уровня доверия.  
– Любой bypass считается инцидентом.  

---

# Promotion boundaries и gates

## Infra promotion

– Promotion environment-based.  
– State и backend разные.  
– Нет shared ресурсов между env.  

## AI promotion

– Training → registry → inference.  
– Каждая граница enforced policy-as-code.  

## Что считается нарушением workflow

– Ручное применение.  
– Прямой доступ к prod.  
– Изменение state вне CI.  

---

# Human vs Non-human действия

## Допустимые human-действия

– Проектирование архитектуры.  
– Review plan.  
– Approval изменений.  
– Анализ инцидентов.  

## Недопустимые human-действия

– Прямой доступ к infrastructure APIs.  
– Ручное исправление прод-ресурсов.  
– Прямой доступ к AI runtime.  

## Роль service accounts и OIDC

– Все apply выполняются от имени сервисов.  
– Креденшелы short-lived.  
– Привязка к identity, а не к человеку.  

---

# Break-glass как исключение из workflow

## Когда допустим break-glass

– Инцидент.  
– Потеря управления.  
– Security emergency.  

## Как он интегрирован в lifecycle

– Ограниченный scope.  
– TTL.  
– Обязательный audit.  
– Обязательный post-mortem.  

Break-glass **не альтернативный workflow**, а controlled failure mode.

---

# Аудит и трассируемость изменений

## Что логируется

– Кто инициировал change.  
– Какой commit применён.  
– Какие policies прошли.  
– Какие ресурсы изменены.  

## Где хранится audit trail

– CI logs.  
– Cloud audit logs.  
– Governance decision logs.  

---

# Explicit non-goals и ограничения

– Документ не описывает конкретные CI реализации.  
– Не описывает UX разработчиков.  
– Не заменяет security-model.md.  

---

# Связь с другими документами

– security-model.md — почему эти ограничения существуют.  
– data-flows.md — какие workflow затрагивают данные и модели.  
– break-glass.md — как выглядит допустимое исключение.  
– architecture.md — где эти workflow закреплены архитектурно.
