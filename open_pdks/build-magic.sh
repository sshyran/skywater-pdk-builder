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

apt-get update -qq

export DEBIAN_FRONTEND=noninteractive

apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    python3 \

apt-get -y install --no-install-recommends \
    build-essential \
    git \
    make \

apt-get -y install --no-install-recommends \
    csh \
    libcairo2-dev \
    libglu1-mesa-dev \
    libncurses-dev \
    libx11-dev \
    m4 \
    python3-dev \
    tcl \
    tcl-dev \
    tcl-expect \
    tcsh \
    tk-dev \

apt-get autoclean
apt-get clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*

cd /host
echo $PWD
ls -l
cd magic
./configure --prefix=/host/out/magic
make -j$(nproc)
make install
find /host/out
