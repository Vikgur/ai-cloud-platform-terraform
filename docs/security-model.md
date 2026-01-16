security-model.md
Threat model: actors, assets, trust boundaries, threats
Контролы: какие политики защищают какие границы (ссылки на Terraform, OPA, Checkov, TfSec)
Основные mitigations (концептуально, без копирования кода)
Роли и привилегии (IAM, RBAC, OIDC)
Ссылки на break-glass и data-flows для полного контекста

Основная концепция угроз и контролей
Ссылки на:
break-glass.md (экстренные права и audit trail)
data-flows.md (для конкретных потоков данных, где enforcement применяется)
modules/ и policies/ (реализация контролей, без копирования кода)
_

threat model + controls
actors
assets
trust boundaries
threats
mitigations → конкретные Terraform / policies

Sovereign AI Security Model


DevSecOps-уровни защиты:

- Terraform code
- IAM policies
- CI scanning
- SCP (global/org-policies)

Как это всё работает вместе

Иерархия защиты:
SCP — абсолютный запрет
Permission Boundary — потолок ролей
IAM policies — детализация
CI — единственный apply
Break-glass — аварийный доступ

Это реальный enterprise-стек.

Итоговая картина

Закрываются:
ошибки Terraform
ошибки инженеров
компрометацию CI
человеческий фактор

_
