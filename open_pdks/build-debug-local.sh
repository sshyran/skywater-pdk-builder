#!/usr/bin/env bash
# Copyright 2021 SkyWater PDK Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

CALLED=$_
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && SOURCED=1 || SOURCED=0

SCRIPT_SRC="$(realpath ${BASH_SOURCE[0]})"
SCRIPT_DIR="$(dirname "${SCRIPT_SRC}")"

SCRIPT_DIR_REL="$(realpath $SCRIPT_DIR --relative-to=$PWD)"

TOP_DIR=$PWD
export TOP_DIR

set -xe

# Cleanup any existing docker build
docker stop --time 0 builder || true
docker rm builder || true

# Start the docker container to do the build inside.
docker run -dt \
  --mount type=bind,source="$(pwd)",target=/host \
  --name builder \
  debian || docker start builder

docker ps

DOCKER_CMD="docker exec builder"

$DOCKER_CMD ls /host

cat > debug.list <<EOF
deb http://deb.debian.org/debian-debug/ bullseye-debug main
deb http://deb.debian.org/debian-debug/ bullseye-proposed-updates-debug main
EOF

$DOCKER_CMD mv /host/debug.list /etc/apt/sources.list.d/
$DOCKER_CMD chown root:root /etc/apt/sources.list.d/debug.list

$DOCKER_CMD apt-get update -qq

$DOCKER_CMD apt-cache search tcsh dbg

$DOCKER_CMD apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    python3 \

$DOCKER_CMD apt-get -y install --no-install-recommends \
    build-essential \
    gdb \
    git \
    make \

$DOCKER_CMD apt-get -y install --no-install-recommends \
    csh \
    libcairo2-dbgsym \
    libglu1-mesa-dbgsym \
    libncurses6-dbgsym \
    libpython3-all-dbg \
    libx11-6-dbgsym \
    m4 \
    python3.9-dbg \
    tk8.6-dbgsym \
    tcl8.6-dbgsym \
    tcl-expect-dbgsym \
    tcsh-dbgsym \
    libc6-dbg \
