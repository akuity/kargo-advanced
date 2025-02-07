# Kargo Advanced Example

This is a GitOps repository of an Kargo example that showcases advanced Kargo
techniques and features. This example will create multiple Argo CD Applications
and Kargo Stages with a pipeline to progress both Git and image changes through
multiple Stages.

## Features

* A Warehouse which monitors both a container repository for new images and manifest changes in Git
* Stage deploy pipeline with A/B testing
* Promotion of Git changes and image tags
* Verification with analysis of an HTTP REST endpoint
* Argo CD Application syncing
* Control flow Stage to coordinate promotion to multiple Stages
* Rendered branches

## Requirements

* Kargo v1.2.x (for older Kargo versions, switch to the release-X.Y branch)
* An Argo CD instance
* GitHub and a container registry (GHCR.io)
* `git` and `docker` installed

## Instructions

1. Fork this repo, then clone it locally (from your fork).
2. Run the `personalize.sh` to customize the manifests to use your GitHub
   username and Argo CD destination:

   ```shell
   ./personalize.sh
   ```
3. `git commit` the personalized changes:

   ```shell
   git commit -a -m "personalize manifests"
   git push
   ```
4. Create a guestbook container image repository in your GitHub account. 

   The easiest way to create a new ghcr.io image repository, is by retagging and
   pushing an existing image with your GitHub username:

   ```shell
   docker buildx imagetools create \
     ghcr.io/akuity/guestbook:latest \
     -t ghcr.io/<yourgithubusername>/guestbook:v0.0.1
   ```

   You will now have a `guestbook` container image repository. e.g.:
   https://github.com/yourgithubusername/guestbook/pkgs/container/guestbook

5. Change guestbook container image repository to public.

   In the GitHub UI, navigate to the "guestbook" container repository, Package 
   settings, and change the visibility of the package to public. This will allow
   Kargo to monitor this repository for new images, without requiring you to
   configuring Kargo with container image repository credentials.

   ![change-package-visibility](docs/change-package-visibility.png)

6. Download and install the latest CLI from [Kargo Releases](https://github.com/akuity/kargo/releases) and Argo CD:

   ```shell
   ./download-cli.sh /usr/local/bin/kargo
   ```

7. Login to Kargo and Argo CD:

   ```shell
   kargo login https://<kargo-url> --admin
   argocd login <argocd-hostname>
   ```

8. Create the Argo CD `guestbook` Project and Applications

   ```shell
   argocd proj create -f ./argocd/appproj.yaml
   argocd appset create ./argocd/appset.yaml
   ```

9. Create the Kargo resources

   ```shell
   kargo apply -f ./kargo
   ```

10. Add git repository credentials to Kargo (replace `<yourgithubusername>`
    with your username).

    ```shell
    kargo create credentials github-creds \
      --project kargo-advanced \
      --git \
      --username <yourgithubusername> \
      --repo-url https://github.com/<yourgithubusername>/kargo-advanced.git
    ```

    As part of the promotion process, Kargo requires privileges to commit changes
    to your Git repository. Ensure that the given token has these privileges.

11. Promote the image!

    You now have a Kargo Pipeline which promotes images from the guestbook
    container image repository, through a multi-stage deploy pipeline.
    Visit the`kargo-advanced` Project in the Kargo UI to see the deploy pipeline.

    ![pipeline](docs/pipeline.png)

    To promote, click the target icon to the left of the `dev` Stage, select the
    detected Freight, and click `Yes` to promote. Once promoted, the freight will
    be qualified to be promoted to downstream Stages (`staging`, `prod`).

## Simulating a release

To simulate a release, simply retag an image with a newer semantic version. e.g.:

```shell
docker buildx imagetools create \
  ghcr.io/akuity/guestbook:latest \
  -t ghcr.io/<yourgithubusername>/guestbook:v0.0.2
```

Then refresh the Warehouse in the UI to detect the new Freight.

## Promoting Manifest Changes

To promote a manifest change, edit the contents under the [`base`](./base)
directory. For example, you modify `guestbook-deploy.yaml` with an additional
environment variable:

```yaml
        env:
        - name: FOO
          value: bar
```

Kargo will promote the environment variable in the same manner as with image tags.

