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

echo
echo "              Current directory: $PWD"
echo "                         Script: $SCRIPT_SRC"
echo "         Directory with scripts: $SCRIPT_DIR"
echo "Relative directory with scripts: $SCRIPT_DIR_REL"
echo

find $PWD -type d | sort

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
$DOCKER_CMD bash /host/$SCRIPT_DIR_REL/build-magic.sh

# Run `make timing` inside the cloned skywater-pdk repository
$DOCKER_CMD bash /host/$SCRIPT_DIR_REL/build-skywater-pdk.sh

# Run `./configure` targeting the output directory.
$DOCKER_CMD bash /host/$SCRIPT_DIR_REL/build-open_pdks.sh

# Tar up result.
find out/pdk-* | sort | tee pdk.files
(
	whoami
	ls -l out/pdk-all
	cd out/pdk-all
	# Try to create a deterministic tar file
	# https://reproducible-builds.org/docs/archives/
	sudo tar \
		--create \
		--xz \
		--verbose \
		\
		--mtime='2020-05-07 00:00Z' \
		--sort=name \
		--owner=0 \
		--group=0 \
		--numeric-owner \
		--pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
		\
		--file $TOP_DIR/out/pdk-SKY130A.tar.xz .
)
sudo chown $UID $TOP_DIR/out/*.tar.xz
du -h $TOP_DIR/out/*.tar.xz
