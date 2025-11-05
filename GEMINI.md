## Project Overview

This repository contains a Node.js Express authentication microservice (`auth-service`) and its corresponding Helm chart (`auth-chart`) for deployment to Kubernetes. The project follows a GitOps workflow using GitHub Actions and ArgoCD to automate the build, containerization, and deployment process.

The `auth-service` is a simple Express application that serves as a placeholder for a real authentication service. The `auth-chart` contains the Kubernetes manifests required to deploy the service. The `docs` directory contains documentation about the GitOps pipeline.

## Building and Running

### Auth Service

-   **Install dependencies:** `npm install` (run in `auth-service/`)
-   **Run locally:** `npm start` (starts the service on port 3000)
-   **Build Docker image:** `docker build -t auth-service:local -f auth-service/Dockerfile auth-service`

### Helm Chart

-   **Render templates locally:** `helm template auth-chart --values auth-chart/values.yaml`

## Development Conventions

-   **Indentation:** 2 spaces
-   **Quotes:** Double quotes
-   **Functions:** Arrow functions
-   **Variables:** Prefer `const` over `let`
-   **Naming:** `camelCase` for variables/functions, lowercase with hyphens for filenames
-   **Formatting:** Run `npx prettier --write` on changed files before committing.

## Testing

The project currently lacks a formal testing setup. The `package.json` file contains a placeholder test script. The `AGENTS.md` file suggests adding tests using Jest and storing them in `auth-service/__tests__/`.

## Commit and Pull Request Guidelines

-   **Commit Messages:** Use imperative, lowercase subject lines with a scope prefix (e.g., `chore:`, `feat:`, `fix:`).
-   **Pull Requests:** PRs should clarify the changes made, the impact on the Helm chart, and the expected deployment outcome.

## Deployment

The project uses a GitOps pipeline with GitHub Actions and ArgoCD.

1.  A push to the `main` branch on the `auth-service/**` path triggers a GitHub Actions workflow.
2.  The workflow builds a new Docker image, pushes it to a registry, and updates the image tag in `auth-chart/values.yaml`.
3.  The change to `values.yaml` is committed and pushed to the `main` branch.
4.  ArgoCD detects the change in the Git repository and syncs the application, deploying the new version to the Kubernetes cluster.

For a detailed breakdown of the pipeline, see `docs/GITOPS_PIPELINE.md`.