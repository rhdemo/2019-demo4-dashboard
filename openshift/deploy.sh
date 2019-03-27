#!/bin/bash
#set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ -z "${SERVER_IMAGE_REPOSITORY}" ]] && { SERVER_IMAGE_REPOSITORY="quay.io/redhatdemo/demo4-dashboard-nginx:latest"; }

oc project
echo "Deploying ${SERVER_IMAGE_REPOSITORY}"

oc process -f ${DIR}/demo4-dashboard-server.yml \
  -p IMAGE_REPOSITORY=${SERVER_IMAGE_REPOSITORY} \
  | oc create -f -


[[ -z "${UI_IMAGE_REPOSITORY}" ]] && { UI_IMAGE_REPOSITORY="quay.io/redhatdemo/demo4-dashboard-nginx:latest"; }

oc project
echo "Deploying ${UI_IMAGE_REPOSITORY}"

oc process -f ${DIR}/demo4-dashboard-ui.yml \
  -p IMAGE_REPOSITORY=${UI_IMAGE_REPOSITORY} \
  | oc create -f -