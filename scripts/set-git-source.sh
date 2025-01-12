#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

GIT_USER=${GIT_USER}
if [ -z ${GIT_USER} ]; then echo "Please set GIT_USER when running script, optional GIT_BASEURL and GIT_REPO to formed the git url GIT_BASEURL/GIT_USER/GIT_REPO"; exit 1; fi
set -u

GIT_REPO=${GIT_REPO:-multi-tenancy-gitops.git}
GIT_BASEURL=${GIT_BASEURL:-https://github.com}
GIT_BRANCH=${GIT_BRANCH:-master}


echo "Setting source git to ${GIT_BASEURL}/${GIT_USER}/${GIT_REPO}"

find ${SCRIPTDIR}/.. -name '*.yaml' -print0 | 
  while IFS= read -r -d '' File; do 
    if grep -q "kind: Application" "$File"; then
      echo "$File"
      sed -i'.bak' -e "s#repoURL: https://github.com/vgadepal/multi-tenancy-gitops.git#repoURL: ${GIT_BASEURL}/${GIT_USER}/${GIT_REPO}#" $File
      sed -i'.bak' -e "s#targetRevision: master#targetRevision: ${GIT_BRANCH}#" $File
      rm "${File}.bak"
    fi
  done

echo "git commit and push changes now"
