# Documentation Consolidation Log

Date: 2025-10-17

Summary: All Markdown documentation has been consolidated under the single canonical root `docs/`. The former `documentation/` folder was cleaned up, with its content migrated, deduplicated, or removed when obsolete/duplicated. README.md files in source subfolders were excluded from moves per request.

## Actions performed

- Chosen canonical root: `docs/`

- Moved: `documentation/issues/*.md` → `docs/project-management/issues/`

- Moved: `documentation/workflow/*.md` → `docs/project-management/workflows/`

- Moved: `documentation/fixes/PROJECT_CREATION_FIX.md`, `RENDERBOX_FLEX_FIX.md`, `WORKSPACE_SWITCHER_UX_IMPROVEMENT.md` → `docs/archive/fixes/`

  - Kept existing: `docs/archive/fixes/COMMON_FIXES.md` (deleted duplicate from `documentation/fixes/`)

- Moved: phase-related files

  - `documentation/FASE_1_PROJECTS_BACKEND_FRONTEND_ALIGNMENT_COMPLETADA.md`
  - `documentation/FASE_2_PROJECT_MEMBERS_PROGRESS.md`
  - `documentation/FASE_2_SUMMARY.md`
  - `documentation/PROYECTOS_PHASE_1_SUMMARY.md`
    → `docs/project-management/phases/`

- Moved: `documentation/FIXES_PROJECT_UPDATE_CACHE.md` → `docs/archive/fixes/`

- Moved: `documentation/SETUP_AUTOMATION_SUMMARY.md` → `docs/deployment/`

- Moved: `documentation/DOCUMENTATION_MIGRATION_GUIDE.md` → `docs/development/`

- Deleted (duplicates already in `docs/archive/`):

  - `documentation/analisys-2025-10-11.md`
  - `documentation/REORGANIZATION_SUMMARY.md`
  - `documentation/TASK_API_INTEGRATION_SESSION.md`
  - `documentation/TASK_API_MAPPING.md`
  - `documentation/TASK_USECASES_PROJECTID_FIX.md`
  - `documentation/UX_EXECUTIVE_SUMMARY.md`
  - `documentation/UX_IMPROVEMENT_PLAN.md`
  - `documentation/UX_IMPROVEMENT_ROADMAP.md`
  - `documentation/UX_TECHNICAL_SPECS.md`
  - `documentation/UX_VISUAL_GUIDE.md`

- Removed duplicate folders from `documentation/`:
  - `history/` (already under `docs/archive/history/`)
  - `setup/` (already under `docs/getting-started/`)
  - Cleaned `fixes/` (moved files; removed leftover duplicate `COMMON_FIXES.md` and the folder)
  - Cleaned `workflow/` (moved files; folder empty)
  - `mcps/` contained only `README.md` and was left as-is to avoid removing user README content (can be removed if desired)

## New structure overview (key areas)

- docs/
  - api-reference/
  - architecture/
  - archive/
    - fixes/ (historical fixes, aggregated)
    - history/ (completed fixes and logs)
    - mcps/
  - backend/
  - creapolis_app/
  - deployment/
  - development/
  - features/
  - getting-started/
  - project-management/
    - issues/ (project planning/issues docs)
    - phases/ (phase summaries and progress)
    - workflows/ (workflow visual docs)
  - user-guides/

## Notes

- The `documentation/` folder now only contains: `README.md` and empty or near-empty subfolders (issues empty, workflow empty). It can be removed after manual confirmation if no longer needed.
- No code was modified; only Markdown files moved/deleted. Build, lint, and tests should be unaffected.
