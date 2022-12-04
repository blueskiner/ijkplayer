#! /usr/bin/env bash
#
# Copyright (C) 2013-2015 Bilibili
# Copyright (C) 2013-2015 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#IJK_LIBFDK_AAC_UPSTREAM=https://github.com/mstorsjo/fdk-aac
IJK_LIBFDK_AAC_UPSTREAM=https://github.com/mstorsjo/fdk-aac.git
IJK_LIBFDK_AAC_FORK=https://github.com/mstorsjo/fdk-aac.git
IJK_LIBFDK_AAC_COMMIT=v0.1.6
IJK_LIBFDK_AAC_LOCAL_REPO=extra/fdk-aac

set -e
TOOLS=tools

echo "== pull fdk-aac base =="
sh $TOOLS/pull-repo-base.sh $IJK_LIBFDK_AAC_UPSTREAM $IJK_LIBFDK_AAC_LOCAL_REPO

function pull_fork()
{
    echo "== pull fdk-aac fork $1 =="
    sh $TOOLS/pull-repo-ref.sh $IJK_LIBFDK_AAC_FORK android/contrib/fdk-aac-$1 ${IJK_LIBFDK_AAC_LOCAL_REPO}
    cd android/contrib/fdk-aac-$1
    git checkout ${IJK_LIBFDK_AAC_COMMIT} -B ijkplayer
    cd -
}

pull_fork "armv5"
pull_fork "armv7a"
pull_fork "arm64"
pull_fork "x86"
pull_fork "x86_64"
