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

set -e

echo
echo "Setting up Kokoro system"
echo "====================================================="
echo

git clone https://gerrit.googlesource.com/gcompute-tools ${KOKORO_ARTIFACTS_DIR}/gcompute-tools
${KOKORO_ARTIFACTS_DIR}/gcompute-tools/git-cookie-authdaemon

git ls-remote https://foss-eda-tools.googlesource.com/skywater-pdk/builder

curl -b ~/.git-credential-cache/cookie https://foss-eda-tools.googlesource.com/?format=TEXT

echo "====================================================="

echo
echo
echo "Update the builder source location"
echo "====================================================="
(
	cd git/builder
	git remote rm origin
	git remote add origin https://foss-eda-tools.googlesource.com/skywater-pdk/builder.git
	git ls-remote --heads origin
)
echo "====================================================="

echo
echo
echo "Create the output repository"
echo "====================================================="
(
	cd git
	git clone https://foss-eda-tools.googlesource.com/skywater-pdk/output.git
	ls -l output/
)
echo "====================================================="
