# Repository Guidelines

## Project Structure & Module Organization
- `auth-service/` hosts the Node.js Express auth microservice. `server.js` is the entry point; add future route handlers under a dedicated subdirectory and keep configuration (ports, secrets) in environment variables.
- `auth-chart/` contains the Helm chart used by GitOps; manifest templates live in `templates/` and defaults in `values.yaml`. Update the image tag here whenever you publish a new container.
- `docs/` stores operational references such as `GITOPS_PIPELINE.md`; revise these notes whenever delivery steps change.

## Build, Test, and Development Commands
- `npm install` (run in `auth-service/`) installs dependencies; rerun after editing `package.json`.
- `npm start` launches the service locally on port 3000; use `curl http://localhost:3000/` to verify responses.
- `docker build -t auth-service:local -f auth-service/Dockerfile auth-service` packages the service image for deployment testing.
- `helm template auth-chart --values auth-chart/values.yaml` renders the release locally to catch chart regressions before pushing to GitOps.

## Coding Style & Naming Conventions
- Follow the existing two-space indentation, double quotes, and arrow-function style shown in `auth-service/server.js`.
- Prefer `const` for immutable bindings, reserve `let` for stateful values, and use `camelCase` for variables/functions. Keep filenames lowercase with hyphens (e.g., `auth-controller.js`).
- Run `npx prettier --write` on touched files before opening a PR to keep diffs minimal.

## Testing Guidelines
- Replace the placeholder `npm test` script with a real runner (Jest or similar). Store specs under `auth-service/__tests__/` with filenames ending in `.test.js`.
- Target coverage on routing logic and middleware. Ensure `npm test` passes locally and in CI before merging.

## Commit & Pull Request Guidelines
- Match the existing imperative, lowercase subject lines (`chore: update auth-service message`). Scope prefixes like `chore`, `feat`, and `fix` communicate intent to GitOps jobs.
- Each PR should clarify service changes, Helm value updates, and expected deployment impact. Link related issues and include screenshots or logs when behavior shifts.
- Double-check the chart image tag against the container version in your PR to prevent drift between runtime and manifests.

## Deployment & Ops Tips
- Update `auth-chart/values.yaml` in the same change as any new container push, and document the version in the PR body.
- Keep secrets external; rely on Kubernetes secrets or pipeline-provided environment variables instead of committing sensitive files.
