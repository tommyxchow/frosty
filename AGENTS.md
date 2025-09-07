# Repository Guidelines

## Project Structure & Module Organization
- Source lives in `src/` with feature‑oriented folders (e.g., `src/auth/`, `src/api/`).
- Tests live in `tests/` or next to code as `__tests__/` or `*.test.*`.
- Tooling and scripts reside in `scripts/`; static assets in `assets/`.
- Keep modules small and cohesive; colocate fixtures/mocks with their tests.

## Build, Test, and Development Commands
- Node: `npm i` (install), `npm run dev` (local dev), `npm test` (unit tests), `npm run build` (production build).
- Python: `python -m venv .venv && . .venv/bin/activate`, `pip install -r requirements.txt`, `pytest -q` (tests), `ruff check .` (lint), `black .` (format).
- Rust: `cargo build`, `cargo test`, `cargo fmt`, `cargo clippy`.
- Docker (optional): `docker compose up --build` to run the stack locally.

## Coding Style & Naming Conventions
- Indentation: 2 spaces (JS/TS), 4 spaces (Python); rustfmt defaults (Rust).
- Names: camelCase for variables/functions; PascalCase for classes/types; snake_case for Python files; kebab-case for CLI scripts.
- Formatting/Linting: Prettier + ESLint (JS/TS), Black + Ruff (Python), `cargo fmt` + Clippy (Rust). Run linters before pushing.

## Testing Guidelines
- Frameworks: Jest/Vitest (JS/TS), Pytest (Python), Cargo test (Rust).
- Naming: `*.test.ts` or `*.spec.ts`; `test_*.py`; `*_test.rs`.
- Coverage: target ≥80% for changed code. Add tests for new behavior and fixed bugs.
- Prefer fast unit tests; keep integration tests deterministic. Use fixtures/test doubles to isolate units.

## Commit & Pull Request Guidelines
- Commits: follow Conventional Commits (e.g., `feat:`, `fix:`, `docs:`, `chore:`). Keep them small, focused, and imperative; include rationale when non‑obvious.
- Pull Requests: include a clear description, link issues (e.g., `Closes #123`), add screenshots for UI changes, list steps to validate, and note breaking changes/migrations.

## Security & Configuration Tips
- Never commit secrets. Use environment files like `.env.local`; provide `.env.example` with safe defaults.
- Validate inputs at boundaries; log minimally; prefer least‑privilege tokens/keys.
- Document required env vars in README or `.env.example` with brief descriptions.

