#!/bin/bash
# Valida que todos los archivos ACE estén presentes
set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "🔍 FieldOps Pro – ACE Framework Validation"

REQUIRED_FILES=(
    ".aceconfig" "CLAUDE.md" ".cursorrules"
    ".ace/roles/roles.md"
    ".ace/knowledge/entities.md"
    ".ace/knowledge/business-rules.md"
    ".ace/skills/data-quality/SKILL.md"
    ".ace/skills/migration-qa/SKILL.md"
    ".ace/skills/dbt-models/SKILL.md"
    ".ace/skills/databricks-patterns/SKILL.md"
    ".ace/standards/coding.md"
    ".ace/standards/data-quality.md"
    ".ace/standards/migration-qa.md"
    "docs/context/ACTIVE_CONTEXT.md"
    "docs/context/PROJECT_CONTEXT.md"
    "docs/rca/regression-guards.yaml"
    "docs/rca/RCA-001-non-idempotent-append.md"
    "docs/rca/RCA-002-ansi-cast-error.md"
    "docs/adr/ADR-001-medallion-architecture.md"
    "docs/adr/ADR-002-workspace-catalog-fallback.md"
)

ALL_GOOD=true
for f in "${REQUIRED_FILES[@]}"; do
    if [ -f "$REPO_ROOT/$f" ]; then echo "  ✅ $f"
    else echo "  ❌ MISSING: $f"; ALL_GOOD=false; fi
done

if [ "$ALL_GOOD" = true ]; then
    echo ""; echo "✅ ACE Framework completo y listo."
    echo "📋 Próximo paso: Phase 5 – notebook 06_migration_reconciliation.ipynb"
    echo "   Ver docs/context/ACTIVE_CONTEXT.md para estado completo"
else
    echo ""; echo "⚠️  Faltan archivos. Revisar la lista."; exit 1
fi
