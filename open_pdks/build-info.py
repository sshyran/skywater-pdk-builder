#!/usr/bin/env python
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

import subprocess
import json

GIT_FETCH_TAGS="git fetch --tags"
GIT_DESCRIBE_CMD="git describe --long --always"
GIT_LOG_CMD="git log -n 1 --stat"

versions = {
    'builder': {
        'name': 'Builder',
        'dir': 'git/builder',
        'commit': {},
    },
    'skywater_pdk': {
        'name': 'SkyWater PDK',
        'dir': 'github/google/skywater-pdk',
        'commit': {},
    },
    'open_pdks': {
        'name': 'Open-PDKs',
        'dir': 'github/RTimothyEdwards/open_pdks',
        'commit': {},
    },
    'magic': {
        'name': 'Magic',
        'dir': 'github/RTimothyEdwards/magic',
        'commit': {},
    },
}

out_version = [0, 0, 0, 0]
for k in versions:
    # Make sure that we have tags.
    subprocess.check_call(
        GIT_FETCH_TAGS.split(),
        cwd=versions[k]['dir'],
    )

    v_str = subprocess.check_output(
        GIT_DESCRIBE_CMD.split(),
        cwd=versions[k]['dir'],
    ).strip()
    if v_str[0] != 'v':
        v_str = 'v'+v_str
    versions[k]['version'] = v_str

    ver, count, commit = v_str.split('-')
    assert commit.startswith('g'), commit
    commit = commit[1:]

    versions[k]['commit']['hash'] = commit
    ver = [int(i) for i in ver[1:].split('.')]
    if len(ver) < 3:
        ver.append(0)
    ver.append(int(count))

    versions[k]['v'] = ver
    for i in range(0, len(out_version)):
        out_version[i] += ver[i]

    versions[k]['commit']['msg'] = subprocess.check_output(
        (GIT_LOG_CMD+' '+commit).split(),
        cwd=versions[k]['dir'],
    ).strip()


version_strings = {'final': 'v{0}.{1}.{2}-{3}'.format(*out_version)}
for k in versions:
    version_strings[k] = versions[k]['version']

info = """\
 SKY130A PDK version: {final}

 Which was built using:
       Builder: {builder}
  SkyWater PDK: {skywater_pdk}
     Open-PDKs: {open_pdks}
         Magic: {magic}
""".format(**version_strings)

print(info)

with open('out/build.info', 'w') as f:
    f.write(info)

with open('out/build.json', 'w') as f:
    json.dump(versions, f, sort_keys=True, indent=2)
