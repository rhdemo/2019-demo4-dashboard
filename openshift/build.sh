#!/bin/bash
#set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ -z "${SERVER_IMAGE_REPOSITORY}" ]] && { SERVER_IMAGE_REPOSITORY="quay.io/redhatdemo/demo4-dashboard-server:latest"; }
[[ -z "${GIT_REPOSITORY}" ]] && { GIT_REPOSITORY="git@github.com:rhdemo/2019-demo4-dashboard.git"; }
[[ -z "${GIT_BRANCH}" ]] && { GIT_BRANCH="dist"; }

echo "Building ${SERVER_IMAGE_REPOSITORY} from ${GIT_REPOSITORY} on ${GIT_BRANCH}"

s2i build ${GIT_REPOSITORY} --ref ${GIT_BRANCH} --context-dir /server docker.io/centos/nodejs-10-centos7:latest ${SERVER_IMAGE_REPOSITORY}


[[ -z "${UI_IMAGE_REPOSITORY}" ]] && { UI_IMAGE_REPOSITORY="quay.io/redhatdemo/demo4-dashboard-nginx:latest"; }

echo "Building ${UI_IMAGE_REPOSITORY}"

s2i build ${GIT_REPOSITORY} --ref ${GIT_BRANCH} --context-dir /nginx docker.io/centos/nginx-112-centos7:latest ${UI_IMAGE_REPOSITORY}



