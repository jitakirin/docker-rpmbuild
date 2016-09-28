#!/bin/bash
# Copyright 2015-2016 jitakirin
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

set -e "${VERBOSE:+-x}"

BUILD=true
if [[ $1 == --sh ]]; then
  BUILD=false
  shift
fi

SPEC="$1"
OUTDIR="${2:-$PWD}"
if [[ -z ${SPEC} || ! -e ${SPEC} ]]; then
  echo "Usage: docker run [--rm]" \
    "--volume=/path/to/source:/src --workdir=/src" \
    "rpmbuild [--sh] SPECFILE [OUTDIR=.]" >&2
  exit 2
fi

# pre-builddep hook for adding extra repos
if [[ -n ${PRE_BUILDDEP} ]]; then
  bash "${VERBOSE:+-x}" -c "${PRE_BUILDDEP}"
fi

# install build dependencies declared in the specfile
yum-builddep -y "${SPEC}"

# drop to the shell for debugging manually
if ! ${BUILD}; then
  exec "${SHELL:-/bin/bash}" -l
fi

# execute the build as rpmbuild user
runuser rpmbuild /usr/local/bin/docker-rpm-build.sh "$@"

# copy the results back; done as root as rpmbuild most likely doesn't
# have permissions for OUTDIR; ensure ownership of output is consistent
# with source so that the caller of this image doesn't run into
# permission issues
mkdir -p "${OUTDIR}"
cp "${VERBOSE:+-v}" -a --reflink=auto \
  ~rpmbuild/rpmbuild/{RPMS,SRPMS} "${OUTDIR}/"
TO_CHOWN=( "${OUTDIR}/"{RPMS,SRPMS} )
if [[ ${OUTDIR} != ${PWD} ]]; then
  TO_CHOWN=( "${OUTDIR}" )
fi
chown "${VERBOSE:+-v}" -R --reference="${PWD}" "${TO_CHOWN[@]}"
