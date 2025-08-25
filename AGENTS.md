# Repository Guidelines

## Project Structure & Module Organization
- Source lives in `src/` with feature‑oriented subfolders (e.g., `src/auth/`, `src/api/`).
- Tests live in `tests/` (or near code as `__tests__/`, `*.test.*`).
- Scripts and tooling in `scripts/`; static assets in `assets/`.
- Keep modules small and cohesive; colocate fixtures/mocks next to tests.

## Build, Test, and Development Commands
- Node (if present): `npm i` to install, `npm run dev` to start local dev, `npm test` to run tests, `npm run build` to produce a production build.
- Python (if present): `python -m venv .venv && . .venv/bin/activate`, `pip install -r requirements.txt`, `pytest -q`, `ruff check .`, `black .`.
- Rust (if present): `cargo build`, `cargo test`, `cargo fmt`, `cargo clippy`.
- Docker (optional): `docker compose up --build` to run the full stack locally.

## Coding Style & Naming Conventions
- Indentation: 2 spaces (JS/TS), 4 spaces (Python), rustfmt defaults (Rust).
- Names: camelCase for variables/functions, PascalCase for classes/types, snake_case for Python files, kebab-case for CLI scripts.
- Formatting/Linting: Prettier + ESLint (JS/TS), Black + Ruff (Python), `cargo fmt` + Clippy (Rust). Run linters before pushing.

## Testing Guidelines
- Frameworks: Jest/Vitest (JS/TS), Pytest (Python), Cargo test (Rust).
- Naming: `*.test.ts` or `*.spec.ts`; `test_*.py`; `*_test.rs`.
- Coverage: target ≥80% for changed code. Add tests for bugs and new behaviors. Use fixtures and test doubles to isolate units.
- Run: `npm test` / `pytest` / `cargo test`. Prefer fast unit tests; keep integration tests deterministic.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat: ...`, `fix: ...`, `docs: ...`, `chore: ...`, `refactor: ...`.
- Commits: small, focused, imperative mood; include rationale when non‑obvious.
- PRs: clear description, linked issues (`Closes #123`), screenshots for UI, steps to validate, and notes on breaking changes/migrations.

## Security & Configuration Tips
- Never commit secrets. Use environment files (`.env.local`); provide `.env.example` with safe defaults.
- Validate inputs at boundaries; log minimally; prefer least‑privilege for tokens/keys.

