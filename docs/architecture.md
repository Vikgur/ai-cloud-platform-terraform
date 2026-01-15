# global/

Назначение: общие ресурсы организации. Создаются один раз.

## global/backend

Инфраструктура для хранения terraform state. Cчитается секретом уровня infra-root.

Состав:
s3.tf — бакет для state
dynamodb.tf — locking
kms.tf — шифрование state

Terraform state =
– полная карта инфраструктуры
– IAM, IP, DNS, topology
– чувствительные данные

Решает 4 задачи:
Централизованное хранение state
Блокировка параллельных apply
Шифрование
Аудит доступа

Создаётся один раз.
Используется всеми environment.

– state зашифрован
– race condition исключены
– аудит доступа
– blast radius минимален

Вывод
global/backend — корень доверия всей инфраструктуры.

Архитектура backend в AWS

– S3 → хранение state
– DynamoDB → locking
– KMS → шифрование
– IAM → контроль доступа

### global/backend/s3.tf

"aws_s3_bucket" "terraform_state"
Назначение:
– физическое хранилище state
– отдельный бакет только под Terraform

Почему:
– нельзя мешать с app-бакетами
– проще аудит и политики

"aws_s3_bucket_versioning" "this"
Зачем:
– история изменений state
– возможность отката
– защита от случайного удаления

Enterprise-требование.

"aws_s3_bucket_server_side_encryption_configuration" "this"
Зачем:
– state содержит секреты
– шифрование обязательно

Почему KMS, а не AES256:
– контроль ключей
– аудит
– ротация

"aws_s3_bucket_public_access_block" "this"
Зачем:
– защита от ошибок инженеров
– даже при ошибочной policy бакет не станет public

Это guardrail.

### global/backend/dynamodb.tf

"aws_dynamodb_table" "terraform_lock"
Назначение:
– locking Terraform state

Что решает:
– два apply одновременно = запрещено
– защита от race condition

Почему DynamoDB:
– managed
– HA
– cheap

### global/backend/kms.tf

"aws_kms_key" "terraform"
Зачем:
– собственный ключ под Terraform
– изоляция от других сервисов

Почему rotation = true:
– compliance
– long-living state

"aws_kms_alias" "terraform" 
Зачем alias:
– читаемость
– удобство ротации
– не хардкодить key_id

---

## global/iam

Роли и политики для Terraform и аварийного доступа.

Состав:

- `terraform-role.tf` — IAM роль, под которой запускается Terraform (CI/CD или человек).  
- `policies/` — отдельные policy-документы для разных целей:
  - `permission-boundary.tf` — жёсткий потолок прав для всех Terraform-ролей, ограничивает эскалацию.  
  - `terraform-base.tf` — базовый набор разрешений для Terraform (инфраструктура, минимальные IAM-операции).  
- `attach.tf` — связывает роли и политики декларативно, позволяет менять политики без редактирования роли.  
- `break-glass.tf` — аварийная роль с AdministratorAccess для security-team, MFA обязателен, каждый Assume логируется.

Отвечает на вопросы:
– кто имеет право создавать инфраструктуру
– с какими правами
– как это аудируется
– как это отзывается

Best practices:
– Terraform никогда не работает под user credentials
– только через IAM Role + AssumeRole
– с жёстким least privilege

Что решает global/iam
Убирает long-lived access keys
Даёт централизованный контроль прав
Позволяет enforce security через IAM, а не договорённости
Упрощает аудит (CloudTrail)

Архитектура IAM для Terraform (AWS)

– IAM Role: terraform-exec-role
– Trust policy: кто может её assume
– Inline / managed policies: что Terraform может делать
– Разделение:
– platform-infra
– app-infra
– read-only

Далее: Platform-infra.

### global/iam/terraform-role.tf

IAM Role
"aws_iam_role" "terraform"
Пояснение:
– terraform-exec-role — роль, под которой работает Terraform
– AssumeRole — обязательный механизм, без прямых ключей
– Principal — кто имеет право запускать Terraform
– CI/CD аккаунт
– bastion
– security account

В enterprise это не root, а отдельный account.

Почему AssumeRole — критично

– ключи не утекут
– сессии короткоживущие
– можно мгновенно отозвать доступ
– CloudTrail пишет, кто и когда

### global/iam/policies/terraform-base.tf

Базовая policy Terraform
"aws_iam_policy" "terraform_base"
Пояснение по блокам:

– ec2 / elb / asg
Управление compute и network-ресурсами

– iam:*Role
Terraform должен уметь создавать роли
Без этого невозможно EKS / IRSA / node roles

– iam:PassRole
Самый опасный permission
Нужен, чтобы EC2/EKS могли использовать роли

– kms / s3 / dynamodb
backend, encryption, state, locking

– logs / cloudwatch
observability infra-уровня

Почему Resource = "*":
– на старте обучения
– потом режется SCP и OPA

### global/iam/policies/permission-boundary.tf

`aws_iam_policy "terraform_boundary"`
Жёсткий потолок прав для всех Terraform-ролей. Boundary **не даёт прав**, а **ограничивает эскалацию**.

**Назначение:** задаёт максимальный безопасный набор разрешений для Terraform.  

**Разрешает:**
- Управление инфраструктурой: EC2, VPC, S3, ELB, AutoScaling, EKS, CloudWatch, Logs  
- Минимальные IAM-операции для инфраструктуры: создание/удаление ролей, attach/detach policy, pass role  

**Запрещает:**
- Создание или удаление пользователей и политик (IAM escalation)  
- Изменение организаций и аккаунтов (Organizations, Account)  

**Ключевой момент:** policy сама по себе **не выдаёт права**, она **ограничивает максимум** того, что может делать роль.  

**Применение:** обязательно указывать в каждой Terraform-роли через  
`permission_boundary = aws_iam_policy.terraform_boundary.arn`.

### global/iam/attach.tf

`aws_iam_role_policy_attachment "terraform_attach"`  
- Связывает роль и policy  
- Декларативно и безопасно  
- Позволяет менять политики без изменения роли  

---

### global/iam/break-glass.tf

`aws_iam_role "break_glass"`  
- Assume только root / security-team  
- MFA обязательно  
- Terraform **не имеет trust**  
- Каждое использование полностью логируется  

`aws_iam_role_policy_attachment "break_glass_admin"`  
- Роль не используется в обычной работе  
- Любое Assume → инцидент и аудит  

---

## global/org-policies

Организационные политики безопасности и лимиты. Последний защитный слой платформы: даже при ошибках в IAM или Terraform опасные действия будут заблокированы на уровне организации.

IAM управляет доступом. SCP управляют безопасностью. SCP не выдают прав — они жёстко ограничивают допустимые действия.

Реализовано через AWS Organizations и Service Control Policies. Политики применяются к OU и аккаунтам.

Состав:

- `guardrails.tf` — базовые SCP-запреты  
  - public exposure  
  - отсутствие шифрования  
  - запрещённые регионы

- `scp.tf` — системные SCP  
  - защита audit/logging  
  - запрет критичных отключений безопасности

- `quotas.tf` — сервисные и ресурсные лимиты

### global/org-policies/guardrails.tf

Запрет public S3
"aws_organizations_policy" "deny_public_s3"
Пояснение:
– Даже если IAM разрешает
– Даже если Terraform настроен неправильно
– Public S3 не появится

Это защита от человеческой ошибки.

Запрет EC2 без шифрования дисков
"aws_organizations_policy" "deny_unencrypted_ebs"
Пояснение:
– Любой диск без encryption = запрещён
– Даже для Terraform role

Compliance-уровень контроль.

Запрет опасных регионов
"aws_organizations_policy" "deny_unsupported_regions"
Пояснение:
– Infrastructure только в разрешённых регионах
– Упрощает compliance
– Убирает shadow-infra

### global/org-policies/quotas.tf

Ограничение количества EC2
"aws_organizations_policy" "limit_ec2"
Пояснение:
– Защита от runaway scaling
– Контроль затрат
– Особенно важно при autoscaling

Привязка SCP к OU / account
"aws_organizations_policy_attachment" "attach_guardrails"
Пояснение:
– Политика применяется ко всем account в OU
– Централизованное управление
– Terraform сам себя ограничивает

### global/org-policies/scp.tf

"aws_organizations_policy" "security_guardrails"
Пояснение
Effect = Deny — абсолютный запрет
Resource = "*" — на всё
Condition — защита от ошибок Terraform
IAM не может обойти SCP

Что делает:
запрещает удаление audit-логов
запрещает отключение шифрования
запрещает создание публичных ресурсов

---

# modules/

Назначение: переиспользуемая бизнес-логика. Основа всего.

## modules/shared

Вспомогательные абстракции.

labels/ — стандартные labels
naming/ — единые имена ресурсов
tags/ — cost/allocation
locals.tf — общие locals

modules/shared — это инфраструктурный язык компании.

Он решает:
– единые имена ресурсов
– единые теги
– единые labels
– единые locals

В top-companies:
– shared не создаёт ресурсов
– shared навязывает стандарты

Без него:
– хаос
– невозможный аудит
– плохой DevSecOps

### modules/shared/naming





---

### Итоговая картина

global/backend
– где хранится state

global/iam
– кто имеет право его менять

Без global/iam:
– Terraform = опасный скрипт

С global/iam:
– Terraform = управляемая платформа

global/backend — где state
global/iam — кто может менять infra
global/org-policies — что никогда нельзя делать