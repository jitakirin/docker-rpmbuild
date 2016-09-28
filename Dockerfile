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

# Based on: http://fedoraproject.org/wiki/How_to_create_an_RPM_package
# And also:
# - https://registry.hub.docker.com/u/nishigori/rpmbuild
# - https://registry.hub.docker.com/u/sydneyuni/rpm-build-env/

FROM centos:7
MAINTAINER jitakirin <jitakirin@gmail.com>

RUN yum install -y rpmdevtools yum-utils && \
    yum clean all && \
    rm -r -f /var/cache/*
ADD docker-init.sh docker-rpm-build.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-*.sh

RUN useradd rpmbuild
USER rpmbuild
RUN rpmdev-setuptree
USER root

ENTRYPOINT ["/usr/local/bin/docker-init.sh"]
