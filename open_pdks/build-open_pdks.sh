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

export PATH=/host/out/magic/bin:$PATH

cd /host/github/open_pdks
git describe

POSSIBLE_TOOLS="all" # klayout magic netgen irsim openlane qflow xschem"
for TTOOL in $POSSIBLE_TOOLS; do

  #  --enable-klayout
  if [ x$TTOOL = xklayout -o x$TTOOL = xall ]; then
    KLAYOUT=--enable-klayout
  else
    KLAYOUT=--disable-klayout
  fi

  #  --enable-magic
  if [ x$TTOOL = xmagic -o x$TTOOL = xall  ]; then
    MAGIC=--enable-magic
  else
    MAGIC=--disable-magic
  fi

  #  --enable-netgen
  if [ x$TTOOL = xnetgen -o x$TTOOL = xall ]; then
    NETGEN=--enable-netgen
  else
    NETGEN=--disable-netgen
  fi

  #  --enable-irsim
  if [ x$TTOOL = xirsim -o x$TTOOL = xall ]; then
    IRSIM=--enable-irsim
  else
    IRSIM=--disable-irsim
  fi

  #  --enable-openlane
  if [ x$TTOOL = xopenlane -o x$TTOOL = xall ]; then
    OPENLANE=--enable-openlane
  else
    OPENLANE=--disable-openlane
  fi

  #  --enable-qflow
  if [ x$TTOOL = xqflow -o x$TTOOL = xall ]; then
    QFLOW=--enable-qflow
  else
    QFLOW=--disable-qflow
  fi

  #  --enable-xschem
  if [ x$TTOOL = xxschem -o x$TTOOL = xall ]; then
    XSCHEM=--enable-xschem
  else
    XSCHEM=--disable-xschem
  fi

  echo
  echo "========================================="
  echo " Building PDK files for $TTOOL"
  echo "-----------------------------------------"
  ./configure \
	--enable-sky130-pdk=/host/github/skywater-pdk \
	--enable-alpha-sky130 \
	--prefix=/usr/local \
        $KLAYOUT \
        $MAGIC \
        $NETGEN \
        $IRSIM \
        $OPENLANE \
        $QFLOW \
        $XSCHEM \

  make -j$(nproc) > /host/out/pdk-$TTOOL.build.log
  make DESTDIR=/host/out/pdk-$TTOOL install > /host/out/pdk-$TTOOL.install.log
  echo "========================================="

  echo
  echo "========================================="
  echo " PDK files for $TTOOL"
  echo "-----------------------------------------"
  find /host/out/pdk-$TTOOL | sort
  echo "========================================="
  echo
  if [ ! -d /host/out/pdk-$TTOOL ]; then
     echo "Missing install files for $TTOOL"
     exit 1
  fi
done
