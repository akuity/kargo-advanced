# Kargo Microservices Example: Continuous Delivery

Kargo is a continuous delivery tool for Kubernetes that helps you manage the promotion of application changes across different environments (Stages). It integrates with GitOps tools like Argo CD and monitors artifact repositories (Git, container images) to create a streamlined and auditable promotion pipeline.

This repository provides an example of using Kargo to manage a simple microservices application through `dev`, `staging`, and `prod` environments.

## Core Kargo Concepts

Understanding these terms is key to using Kargo effectively:

*   **Warehouse:** A Kargo resource defining artifact sources (Git repositories, container image registries). It detects new artifact versions (commits, image tags) and creates "Freight."
*   **Freight:** A collection of specific artifact versions (e.g., Git commit + image versions) representing a deployable application version. Freight is unique and immutable.
*   **Stage:** Represents an environment in your deployment pipeline (e.g., `dev`, `staging`, `prod`). Stages subscribe to a Warehouse for new Freight or to other Stages for verified Freight.
*   **Promotion:** The act of selecting Freight and deploying it to a Stage. Kargo manages this, supporting manual or automatic promotions.
*   **Verification:** Post-promotion checks (tests, monitoring queries) to ensure deployed Freight is healthy, qualifying it for downstream Stages.
*   **Kargo Render:** (Used in this example) Dynamically renders Kubernetes manifests (Kustomize/Helm) using artifact versions from the promoted Freight.

## Example Microservices Application

This example deploys a two-tier application:

*   **`frontend-service`**: A simple Nginx web server serving static HTML.
*   **`api-service`**: A Python Flask backend API.

The pipeline is structured as: `dev` -> `staging` -> `prod`.

*   **`dev` Environment:**
    *   Receives the latest SemVer tagged images for `frontend-service` and `api-service`, plus the latest Git manifest changes.
    *   **Automatic Promotion:** New Freight from the Warehouse is automatically promoted and deployed to `dev`.
    *   Includes a placeholder for basic health check verification.
*   **`staging` Environment:**
    *   Receives Freight that has been successfully deployed and verified in the `dev` Stage.
    *   **Automatic Promotion:** Verified Freight from `dev` is automatically promoted and deployed to `staging`.
    *   Includes a placeholder for more comprehensive verification.
*   **`prod` Environment:**
    *   Receives Freight that has been successfully deployed and verified in the `staging` Stage.
    *   **Manual Promotion:** Requires explicit user approval in the Kargo UI to promote Freight to `prod`.
    *   Includes a placeholder for production smoke tests.

**Tools Used:**
*   Kargo for promotion management.
*   Argo CD for GitOps-based deployment.
*   Kustomize for manifest templating (via Kargo Render).
*   GitHub for Git hosting.
*   GHCR.io for container image hosting.

## Step-by-Step Usage

### 1. Prerequisites

Ensure you have:
*   Kargo (v1.2.x or later): [Official Kargo installation guide](https://kargo.akuity.io/getting-started/).
*   Argo CD: An operational instance. [Argo CD documentation](https://argo-cd.readthedocs.io/en/stable/getting_started/).
*   GitHub Account: For forking and GHCR.io.
*   Docker: For building/pushing images.
*   Git CLI.
*   Kargo CLI & Argo CD CLI (download script provided).

### 2. Fork and Personalize the Repository

1.  **Fork this Repository.**
2.  **Clone Your Fork:**
    ```shell
    git clone https://github.com/<your-github-username>/kargo-advanced.git # Or your repo name
    cd kargo-advanced # Or your repo name
    ```
3.  **Personalize Manifests:** The `personalize.sh` script updates YAML files (Kargo Warehouse/Stages, Argo CD AppSet, Kustomize overlays) with your GitHub username and Argo CD details.
    ```shell
    ./personalize.sh
    ```
    *Follow prompts. For Argo CD server, if in the same cluster as Kargo, use `https://kubernetes.default.svc`.*
4.  **Commit and Push Changes:**
    ```shell
    git commit -a -m "Personalize manifests for my setup"
    git push origin main
    ```

### 3. Prepare Container Image Repositories (GHCR.io)

For this microservices example, you'll need two image repositories on GHCR.io: `frontend-service` and `api-service`.

1.  **Create and Push Initial Images:**
    Replace `<your-github-username>` with your GitHub username.
    *   **`frontend-service`**:
        ```shell
        # Create a dummy index.html for the frontend
        echo "<h1>Frontend v0.0.1</h1>" > base/frontend-service/index.html
        # (Or use the more detailed one already created in base/frontend-service/index.html)

        docker build -t ghcr.io/<your-github-username>/frontend-service:v0.0.1 base/frontend-service/
        docker push ghcr.io/<your-github-username>/frontend-service:v0.0.1
        ```
    *   **`api-service`**:
        ```shell
        docker build -t ghcr.io/<your-github-username>/api-service:v0.0.1 base/api-service/
        docker push ghcr.io/<your-github-username>/api-service:v0.0.1
        ```
    *(Ensure Docker is logged into GHCR.io: `docker login ghcr.io -u <your-github-username> -p <YOUR_PAT>`).*

2.  **Set Package Visibilities to Public:**
    For *both* `frontend-service` and `api-service` packages on GHCR.io (via GitHub UI):
    *   Navigate to the package page (e.g., `https://github.com/<your-github-username>?tab=packages`).
    *   Select the package (`frontend-service` or `api-service`).
    *   Go to "Package settings".
    *   Change visibility to "Public". This allows Kargo to monitor for new images without credentials for this example.
    ![Change Package Visibility](docs/change-package-visibility.png) *(This image shows one package, repeat for both)*

### 4. Install CLIs and Login

1.  **Download CLIs:**
    ```shell
    ./download-cli.sh /usr/local/bin/kargo
    # ./download-cli.sh /usr/local/bin/argocd # Optional if Argo CD CLI already installed
    ```
    *(Ensure `/usr/local/bin` is in your PATH).*
2.  **Login to Kargo and Argo CD:**
    ```shell
    kargo login https://<kargo-url> --admin
    argocd login <argocd-hostname> --username <your-argocd-username> --password <your-argocd-password>
    ```

### 5. Deploy Kargo and Argo CD Resources

1.  **Create Argo CD Project and ApplicationSet:**
    ```shell
    argocd proj create -f ./argocd/appproj.yaml
    argocd appset create ./argocd/appset.yaml
    ```
2.  **Create Kargo Resources:**
    ```shell
    kargo apply -f ./kargo
    ```
3.  **Add Git Repository Credentials to Kargo:**
    Kargo needs to commit changes to your Git repository (updating Kustomize files).
    Replace placeholders with your GitHub username and a Personal Access Token (PAT) with `repo` scope.
    ```shell
    ./add-credential.sh \
      --project kargo-advanced \
      --git \
      --username <your-github-username> \
      --password <your-personal-access-token> \
      --repo-url https://github.com/<your-github-username>/kargo-advanced.git # Or your repo name
    ```

### 6. The Promotion Pipeline

1.  **Observe Pipeline & Initial Freight:**
    *   In Kargo UI, navigate to the `kargo-advanced` project.
    *   Refresh the `guestbook` Warehouse. Kargo will detect `v0.0.1` for both services and the latest Git commit, creating Freight.
2.  **`dev` Stage (Auto-Promotion):**
    *   The `dev` Stage is configured for auto-promotion. As soon as new eligible Freight (images + Git commit) is found by the Warehouse, Kargo should automatically promote it to `dev`.
    *   Kargo updates `env/dev/kustomization.yaml` image tags, commits to Git.
    *   Argo CD syncs `guestbook-dev` to the `guestbook-dev` namespace.
    *   Verify pod deployments: `kubectl get pods -n guestbook-dev`.
3.  **`staging` Stage (Auto-Promotion from verified `dev` Freight):**
    *   Once Freight is successfully running in `dev` (and passes any (placeholder) verifications configured for the `dev` Stage), it becomes "verified."
    *   The `staging` Stage, subscribing to `dev` and also configured for auto-promotion, will automatically pick up this verified Freight.
    *   Kargo updates `env/staging/kustomization.yaml`, commits, Argo CD syncs `guestbook-staging`.
    *   Verify: `kubectl get pods -n guestbook-staging`.
4.  **`prod` Stage (Manual Promotion):**
    *   Freight verified in `staging` becomes available to `prod`.
    *   Promotion to `prod` is **manual**. In the Kargo UI, go to the `prod` Stage.
    *   Click "Promote Freight", select the desired Freight from `staging`.
    *   Kargo updates `env/prod-central/kustomization.yaml` (our prod environment for this example), commits, Argo CD syncs `guestbook-prod`.
    *   Verify: `kubectl get pods -n guestbook-prod`.

### 7. Simulating a New Release (Image Updates)

1.  **Build and Push New Image Tags:**
    For example, for `frontend-service`:
    ```shell
    # Make a change to base/frontend-service/index.html if desired
    docker build -t ghcr.io/<your-github-username>/frontend-service:v0.0.2 base/frontend-service/
    docker push ghcr.io/<your-github-username>/frontend-service:v0.0.2
    ```
    Repeat for `api-service` if making changes there (`v0.0.2` or a new version).
2.  **Refresh Warehouse:** In Kargo UI, refresh the `guestbook` Warehouse.
3.  **Observe Promotion:** New Freight will appear. Since `dev` has auto-promotion, it should pick up `v0.0.2` automatically. This will then flow to `staging` automatically (after `dev` verification passes), and then be available for manual promotion to `prod`.

### 8. Promoting Manifest Changes (Git Update)

1.  **Edit Base Manifests:**
    Make a change to a file in `base/frontend-service/` or `base/api-service/`. For example, change replica count in `base/api-service/deployment.yaml`.
2.  **Commit and Push to `main` branch of your fork.**
3.  **Refresh Warehouse & Observe:** New Freight (new Git commit + existing images) will be created. This will also flow through the auto-promotion pipeline for `dev` and `staging`.

This setup provides a robust way to manage promotions of your microservices, ensuring changes are tested and deployed systematically across environments.
