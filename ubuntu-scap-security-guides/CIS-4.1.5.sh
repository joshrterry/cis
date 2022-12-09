#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------
set -u
#exit ${XCCDF_RESULT_FAIL}
#exit $XCCDF_RESULT_PASS

syscalls32=(sethostname setdomainname)
syscalls64=(${syscall32[@]})
paths=("/etc/issue" "/etc/issue.net" "/etc/hosts" "/etc/network" )
key=system-locale

for s32 in "${syscalls32[@]}"; do
    auditctl -l -k ${key} | egrep "^-a always,exit -F arch=b32 -S (\w+,)*"${s32}"\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

for s64 in "${syscalls64[@]}"; do
    auditctl -l -k ${key} | egrep "^-a always,exit -F arch=b64 -S (\w+,)*"${s64}"\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

for path in "${paths[@]}"; do
    auditctl -l -k ${key} | egrep "^-w ${path} -p wa\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

exit ${XCCDF_RESULT_PASS}
