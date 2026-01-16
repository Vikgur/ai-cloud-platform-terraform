data-flows.md
Потоки данных: ingress → training → model-registry → inference → serving
Кто имеет доступ на каждом шаге (концептуально)
Где enforced, чем enforced (ссылки на Terraform / OPA / policies)
Диаграммы flow + trust boundaries
Не копировать policies из security-model, только ссылки

Потоки данных AI и доверенные границы
Ссылки на:
security-model.md (контролы enforcement, политики)
workflows.md (когда данные перемещаются между training → model-registry → inference)

-
ingress paths
training flows
model promotion
inference serving
где enforced, чем enforced

1. Promotion boundary

схема: training → model-registry → inference
кто имеет право на какой шаг
какие политики enforced (OPA/TfSec/Checkov)
-