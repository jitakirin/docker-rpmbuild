#!/bin/bash
# Copyright 2015 jitakirin
#
# This file is part of devops-utils.
#
# devops-utils is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# devops-utils is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with devops-utils.  If not, see <http://www.gnu.org/licenses/>.

set -e "${VERBOSE:+-x}"

SPEC="${1:?}"
TOPDIR="${HOME}/rpmbuild"

# copy sources and spec into rpmbuild's work dir
cp "${VERBOSE:+-v}" -a --reflink=auto * "${TOPDIR}/SOURCES/"
cp "${VERBOSE:+-v}" -a --reflink=auto "${SPEC}" "${TOPDIR}/SPECS/"
SPEC="${TOPDIR}/SPECS/${SPEC##*/}"

# build the RPMs
rpmbuild "${VERBOSE:+-v}" -ba "${SPEC}"
