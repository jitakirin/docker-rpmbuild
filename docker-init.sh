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

DEBUG=false
BUILD=true
while [[ $# -gt 0 ]]
do
KEY="$1"
case $KEY in
    --sh)
    BUILD=false
    shift #past argument
    ;;
    -s|--spec)
    SPEC="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--outdir)
    OUTDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--sign)
    SIGNATURE=(${2//;/ })
    if [ ${#SIGNATURE[@]} -ne 3 ]; then
      echo -e "Signature is required to have 3 segments delimited by ';'" \
        "\"<Name>;<KeyFile>;<Password>\"" >&2
      exit 2
    fi
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    echo -e "Typical usage is " \
      "\ndocker run [--rm] -v /path/to/source:/src -w /src rpmbuild -s SPECFILE [-a \"NAME;KEYFILE;PASSWORD\"]" \
      "[-o OUTDIR]" >&2
    echo -e "\nOptions: " \
         "\n--sh         Drop to shell for debugging" \
         "\n-s|--spec    Set spec file" \
         "\n-o|--outdir  Set output directory, defaults to '.'" \
         "\n-a|--sign    Set info for RPM signing, required to have 3 segments" \
         "\n             encased in quotes delimited by ';' ex: \"<Name>;<KeyFile>;<Password>\"" \
         "\n-h|--help    this help text." >&2
    exit 2
    ;;
    *)
    if ${VERBOSE:+true}; then 
      echo "Unknown arg: $1"
    fi
    shift
    ;;
esac
done

OUTDIR="${OUTDIR:-$PWD}"
SIGN_NAME=${SIGNATURE[0]}
SIGN_KEYFILE=${SIGNATURE[1]}
SIGN_PASS=${SIGNATURE[2]}

if ${DEBUG}; then
  echo "SPEC: ${SPEC}" \
   " OUTDIR: ${OUTDIR}" \
   " SIGN_NAME: ${SIGN_NAME}" \
   " SIGN_KEYFILE: ${SIGN_KEYFILE}" \
   " SIGN_PASS: ${SIGN_PASS}" >&2
fi

if [[ -z ${SPEC} || ! -e ${SPEC} ]]; then
  echo "Spec file not found! Cannot continue" >&2
  exit 2
fi

# pre-builddep hook for adding extra repos
if [[ -n ${PRE_BUILDDEP} ]]; then
  bash "${VERBOSE}" -c "${PRE_BUILDDEP}"
fi

# install build dependencies declared in the specfile
yum-builddep -y "${SPEC}"

# drop to the shell for debugging manually
if ! ${BUILD}; then
  exec "${SHELL:-/bin/bash}" -l
fi

# execute the build as rpmbuild user
runuser rpmbuild /usr/local/bin/docker-rpm-build.sh "$SPEC"

# if name, keyfile, and pass are provide, sign the rpms
if [ -n "$SIGN_NAME" ] && [ -e "$SIGN_KEYFILE" ] && [ -n "$SIGN_PASS" ]; then
  # attempt to import the keyfile
  runuser rpmbuild -c "/usr/bin/gpg --import $SIGN_KEYFILE"
  #TODO: verify keyfile import success
  #for each RPM created, attempt to sign
  find ~rpmbuild/rpmbuild/{RPMS,SRPMS}/ -iname "*rpm" \
    -exec runuser -u rpmbuild /usr/bin/expect /usr/local/bin/docker-rpm-sign.sh {} "$SIGN_NAME" "$SIGN_PASS" \;
  #TODO: verify signing?
fi

# copy the results back; done as root as rpmbuild most likely doesn't
# have permissions for OUTDIR; ensure ownership of output is consistent
# with source so that the caller of this image doesn't run into
# permission issues
mkdir -p "${OUTDIR}"
cp ${VERBOSE:+-v} -a --reflink=auto \
  ~rpmbuild/rpmbuild/{RPMS,SRPMS} "${OUTDIR}/"
TO_CHOWN=( "${OUTDIR}/"{RPMS,SRPMS} )
if [[ ${OUTDIR} != ${PWD} ]]; then
  TO_CHOWN=( "${OUTDIR}" )
fi
chown ${VERBOSE:+-v} -R --reference="${PWD}" "${TO_CHOWN[@]}"
