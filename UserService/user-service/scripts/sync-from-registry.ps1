# Pulls the image CI pushed to GHCR and updates the user-service Deployment on your current kubectl context.
# Use this on the same machine as Docker Desktop Kubernetes after you push to main (when you do not use remote deploy).
#
# Prerequisites: kubectl context = docker-desktop, namespace user-service already applied once, deployment exists.
# For a private GHCR package: create a PAT with read:packages, then either:
#   echo <PAT> | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
# or pass -Pat to this script once per session.
#
# Usage:
#   .\scripts\sync-from-registry.ps1 -GithubUsernameLower yourgithubname
#   .\scripts\sync-from-registry.ps1 -GithubUsernameLower yourgithubname -Tag abc123def
#   .\scripts\sync-from-registry.ps1 -GithubUsernameLower yourgithubname -Pat ghp_xxxx

param(
    [Parameter(Mandatory = $true)]
    [string] $GithubUsernameLower,

    [string] $Tag = "latest",

    [string] $Pat = ""
)

$ErrorActionPreference = "Stop"
$image = "ghcr.io/$GithubUsernameLower/user-service:$Tag"

if ($Pat) {
    Write-Host "Logging in to ghcr.io..."
    $Pat | docker login ghcr.io -u $GithubUsernameLower --password-stdin
}

Write-Host "Pulling $image ..."
docker pull $image

Write-Host "Updating deployment user-service in namespace user-service..."
kubectl set image deployment/user-service "user-service=$image" -n user-service
kubectl rollout status deployment/user-service -n user-service --timeout=180s

Write-Host "Current image:"
kubectl get deploy user-service -n user-service -o jsonpath='{.spec.template.spec.containers[0].image}'
Write-Host ""
