#!/usr/bin/expect
set rpmfile [lindex $argv 0]
set gpgname [lindex $argv 1]
set passphrase [lindex $argv 2]

spawn rpm --adsign -D "_gpg_name $gpgname" $rpmfile
expect -exact "Enter pass phrase: "
send -- $passphrase
expect eof
