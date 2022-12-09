#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------
set -u
#exit ${XCCDF_RESULT_FAIL}
#exit $XCCDF_RESULT_PASS

syscalls64=(init_module delete_module)
paths=(/sbin/insmod /sbin/rmmod /sbin/modprobe)
key=modules

for s64 in "${syscalls64[@]}"; do
    auditctl -l -k ${key} | egrep "^-a always,exit -F arch=b64 -S (\w+,)*"${s64}"\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

for path in "${paths[@]}"; do
    auditctl -l -k ${key} | egrep "^-w ${path} -p x\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

exit ${XCCDF_RESULT_PASS}
