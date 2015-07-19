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

# Based on: http://fedoraproject.org/wiki/How_to_create_an_RPM_package
# And also: https://registry.hub.docker.com/u/nishigori/rpmbuild

FROM centos:7
MAINTAINER jitakirin <jitakirin@gmail.com>

RUN yum install -y rpmdevtools yum-utils && \
    yum clean all && \
    rm -r -f /var/cache/*
RUN useradd rpmbuild
USER rpmbuild
RUN rpmdev-setuptree
