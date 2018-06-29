#!/bin/bash
# Copyright 2018 Setheck
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

#!/usr/bin/expect
set rpmfile [lindex $argv 0]
set gpgname [lindex $argv 1]
set passphrase [lindex $argv 2]

spawn rpmsign --addsign -D "_gpg_name $gpgname" $rpmfile
expect -exact "Enter pass phrase: "
send -- "$passphrase\r"
expect eof
