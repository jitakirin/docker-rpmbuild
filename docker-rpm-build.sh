#!/bin/bash
# Copyright 2015-2016 jitakirin
# Modified by Setheck 6/28/2018
#
# This file is part of docker-rpmbuild.
#
# docker-rpmbuild is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# docker-rpmbuild is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with docker-rpmbuild.  If not, see <http://www.gnu.org/licenses/>.

set -e ${VERBOSE:+-x}

SPEC="${1:?}"
TOPDIR="${HOME}/rpmbuild"

# copy sources and spec into rpmbuild's work dir
cp ${VERBOSE:+-v} -a --reflink=auto * "${TOPDIR}/SOURCES/"
cp ${VERBOSE:+-v} -a --reflink=auto "${SPEC}" "${TOPDIR}/SPECS/"
SPEC="${TOPDIR}/SPECS/${SPEC##*/}"

# build the RPMs
rpmbuild ${VERBOSE:+-v} -ba "${SPEC}"
