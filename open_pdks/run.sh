#!/usr/bin/bash
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

set -xe

# This script tries to follows the instructions in the README @
# https://github.com/RTimothyEdwards/open_pdks/tree/master/sky130 with a couple
# of differences;
# 1) It uses the git repositories already cloned by Kokoro
# 2) It runs inside a Docker container

# Cleanup any existing docker build
docker stop --time 0 builder || true
docker rm builder || true
rm -rf out

# Start the docker container to do the build inside.
docker run -dt \
  --mount type=bind,source="$(pwd)",target=/host \
  --name builder \
  debian || docker start builder

docker ps

function kill_docker_builder {
	docker stop --time 0 builder || true
	docker ps
}
trap kill_docker_builder EXIT

DOCKER_CMD="docker exec builder"

$DOCKER_CMD ls /host

# Build Magic in a container from the cloned magic repository
$DOCKER_CMD bash /host/build-magic.sh

# Run `make timing` inside the cloned skywater-pdk repository
$DOCKER_CMD bash /host/build-skywater-pdk.sh

# Run `./configure` targeting the output directory.
$DOCKER_CMD bash /host/build-open_pdks.sh

# Tar up result.
find out/pdk-* | sort | tee pdk.files
