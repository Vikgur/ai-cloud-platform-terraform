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
