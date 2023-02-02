#!/usr/bin/env bash
set -e

INPUT_DOCKERFILE=${INPUT_DOCKERFILE:-Dockerfile}
INPUT_TAG=${INPUT_TAG:-${GITHUB_SHA::8}}
INPUT_BRANCH=${INPUT_BRANCH:-master}
IMAGE_PART=""

echo "Build args: ${INPUT_BUILD_ARGS}"

if [ "$INPUT_IMAGE" != "" ]; then
        IMAGE_PART="/${INPUT_IMAGE}"
fi

if [ -n "$INPUT_GIT_ACCESS_TOKEN" ]; then
        GIT_ACCESS_TOKEN_FLAG="${INPUT_GIT_ACCESS_TOKEN}@"
fi

echo "Building Docker image ${INPUT_REPOSITORY}${IMAGE_PART}:${INPUT_TAG} from ${GITHUB_REPOSITORY} on ${INPUT_BRANCH} and using context ${INPUT_FOLDER} ; and pushing it to ${INPUT_REGISTRY} Azure Container Registry"

echo "Logging into azure.."
az login --service-principal -u ${INPUT_SERVICE_PRINCIPAL} -p ${INPUT_SERVICE_PRINCIPAL_PASSWORD} --tenant ${INPUT_TENANT}

echo "Sending build job to ACR.."
az acr build -r ${INPUT_REGISTRY} ${INPUT_BUILD_ARGS} -f ${INPUT_DOCKERFILE} -t ${INPUT_REPOSITORY}${IMAGE_PART}:${INPUT_TAG} https://${GIT_ACCESS_TOKEN_FLAG}github.com/${GITHUB_REPOSITORY}.git#${INPUT_BRANCH}:${INPUT_FOLDER}
