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

set -xe
set -o pipefail

export PATH=/host/out/magic/bin:$PATH

# Clear timestamps in magic files
find /host/out/pdk-* -name '*.mag' -exec sed -i -e's/timestamp [0-9]\+/timestamp 0/' \{\} \+

# Clear timestamps in GDS files
find /host/out/pdk-* -name '*.gds' -exec /host/git/builder/open_pdks/gds_change_date.py 1 0 \{\}
#find out/pdk-* -name '*.gds' -print | parallel -v /host/git/builder/open_pdks/gds_change_date.py 1 0 \{\}
