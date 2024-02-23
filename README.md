# Kargo Simple Example

This is an example GitOps repository for simple Kargo example for getting started.

Features:
* A Warehouse which monitors a container repository for new images
* Three Stages (dev, staging, prod)

It does not require an Argo CD instance and so could work with any GitOps operator (Argo CD, Flux)
that deploys manifest changes from a path in a git repo automatically.


## Instructions

1. Fork this repo
2. Run `personalize.sh` to customize the repo with your username
3. Commit the changes
4. Create a guestbook container repository

```
docker buildx imagetools create -t ghcr.io/<yourusername>/guestbook:v0.0.1 ghcr.io/akuity/guestbook:latest
```

5. Mark the container repository public

6. Login to kargo
```
kargo login https://<kargo-url> --admin
```

7. Apply the Kargo manifests

```
kargo apply -f ./kargo
```

8. Add a PAT to Kargo that can write to the git repository. Modify the `username` and `password` 
fields of github-creds.yaml. Then apply the Secret:

```
# edit github-creds.yaml
kargo apply -f ./github-creds.yaml
```


## Simulating a release

To simulate a release, simply retag an image with a newer semantic version. e.g.:

```
docker buildx imagetools create -t ghcr.io/<yourusername>/guestbook:v0.0.2 ghcr.io/akuity/guestbook:latest
```
