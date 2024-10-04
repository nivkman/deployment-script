#!/bin/bash

echo "running apt update"
sudo apt-get update

echo "running apt upgrade"
sudo apt-get upgrade -y

echo "installing docker"
sudo apt install docker.io -y

echo "installing docker-compose"
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

docker compose version

# Exit immediately if a command exits with a non-zero status
set -e

# Create the shared network if it doesn't exist
docker network create ci_network 2>/dev/null || true

# Start Artifactory
echo "Starting Artifactory..."
docker compose -f artifactory.docker-compose.yml up -d

# Start Jenkins
echo "Starting Jenkins..."
docker compose -f jenkins.docker-compose.yml up -d

echo "CI environment setup complete!"
echo "Artifactory should be accessible at http://localhost:8081"
echo "Jenkins should be accessible at http://localhost:8080"
echo "Please check the logs for any additional setup steps or initial passwords:"
echo "  Artifactory logs: docker compose -f artifactory.docker-compose.yml logs"
echo "  Jenkins logs: docker compose -f jenkins.docker-compose.yml logs"
echo "To get the initial Jenkins admin password, run:"
echo "docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"

