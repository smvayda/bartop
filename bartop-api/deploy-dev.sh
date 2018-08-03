#!/bin/bash

set -e

export NODE_ENV=development

docker build -t gcr.io/${PROJECT_NAME_DEV}/${IMAGE_NAME}:$TRAVIS_COMMIT .

echo $GCLOUD_SERVICE_KEY_DEV | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME_DEV
gcloud --quiet config set container/cluster $CLUSTER_NAME_DEV
gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
gcloud --quiet container clusters get-credentials $CLUSTER_NAME_DEV

gcloud docker push gcr.io/${PROJECT_NAME_DEV}/${IMAGE_NAME}

yes | gcloud beta container images add-tag gcr.io/${PROJECT_NAME_DEV}/${IMAGE_NAME}:$TRAVIS_COMMIT gcr.io/${PROJECT_NAME_DEV}/${IMAGE_NAME}:latest

kubectl config view
kubectl config current-context

kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_CONTAINER_NAME}=gcr.io/${PROJECT_NAME_DEV}/${IMAGE_NAME}:$TRAVIS_COMMIT