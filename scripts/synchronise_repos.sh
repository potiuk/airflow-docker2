#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
set -xeuo pipefail

AIRFLOW_DIR="airflow"
IMAGE_DIR="."

pip install git-filter-repo==2.32.0

git_filter_repo_path=$(python -c "import site; print(site.getsitepackages()[-1])")/git_filter_repo.py

chmod a+x "${git_filter_repo_path}"
# shellcheck disable=SC2139
alias git-filter-repo="${git_filter_repo_path}"

git status

# The first time we run, it we have to run it with force as git-filter-repo has
# protections against overwriting history accidentally
EXTRA_ARG=""
# preserve the git-filter-repo map so that we can keep the history
# We know we can do it because main is never push --forced
if [[ -d "${IMAGE_DIR}"/filter-repo ]]; then
    echo "Copying previous version of commit map to .git-filter-repo"
    EXTRA_ARG=""
    mkdir -pv "${IMAGE_DIR}"/.git/filter-repo/
    cp -v "${IMAGE_DIR}"/filter-repo/already_ran \
          "${IMAGE_DIR}"/filter-repo/commit-map \
          "${IMAGE_DIR}"/filter-repo/ref-map \
            .git/filter-repo/
fi
readonly EXTRA_ARG

filter_repo_map_hash=$(tar cvf - "${IMAGE_DIR}"/.git/filter-repo/commit-map "${IMAGE_DIR}"/.git/filter-repo/ref-map 2>/dev/null | sha1sum || true)

git-filter-repo --partial --path Dockerfile --path .dockerignore --path scripts/docker \
   --path scripts/in_container/prod --path docker-context-files --path empty \
   --source "${AIRFLOW_DIR}" --target "${IMAGE_DIR}" "${EXTRA_ARG}"

updated_filter_repo_map_hash=$(tar cvf - "${IMAGE_DIR}"/.git/filter-repo/commit-map "${IMAGE_DIR}"/.git/filter-repo/ref-map | sha1sum)

cd "${IMAGE_DIR}"

# only copy the git-reflog map if the content changed (i.e. if there are new commits)
if [[ ${filter_repo_map_hash} != "${updated_filter_repo_map_hash}" ]]; then
    echo "Copying back the new version of commit map from .git-filter-repo"
    mkdir -pv filter-repo/
    cp -v .git/filter-repo/already_ran \
          .git/filter-repo/commit-map \
          .git/filter-repo/ref-map \
            filter-repo/
    # We commit it back so that next time we can incrementally pull it
    git config --local user.email "dev@airflow.apache.org"
    git config --local user.name "Automated GitHub Actions commit"
    git add filter-repo
    git commit -m "Updating filter map with new changes"
fi

