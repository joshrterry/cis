#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------
set -u
#exit ${XCCDF_RESULT_FAIL}
#exit $XCCDF_RESULT_PASS

syscalls32=()
syscalls64=()
path_logins=("/var/log/wtmp" "/var/log/btmp")
path_session=("/var/run/utmp")

for s32 in "${syscalls32[@]}"; do
    auditctl -l -k ${key} | egrep "^-a always,exit -F arch=b32 -S (\w+,)*"${s32}"\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

for s64 in "${syscalls64[@]}"; do
    auditctl -l -k ${key} | egrep "^-a always,exit -F arch=b64 -S (\w+,)*"${s64}"\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

for path in "${path_logins[@]}"; do
    auditctl -l -k logins | egrep "^-w ${path} -p wa\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

for path in "${path_session[@]}"; do
    auditctl -l -k session | egrep "^-w ${path} -p wa\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

exit ${XCCDF_RESULT_PASS}