#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------
set -u
#exit ${XCCDF_RESULT_FAIL}
#exit $XCCDF_RESULT_PASS

syscalls32=(execve)
syscalls64=(${syscalls32[@]})
paths=()
key=actions
uid_min=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
uid_min=${uid_min:-1000} # default value if no UID_MIN found


for s32 in "${syscalls32[@]}"; do
    auditctl -l -k ${key} | egrep "^-a always,exit -F arch=b32 -S (\w+,)*"${s32}"\b" \
        | grep -P "(?=.*\bauid!=-1\b)(?=.*\bauid>=${uid_min}\b)(?=.*-C\s+uid!=euid\b)(?=.*-F\s+euid=0\b)" ||\
        exit ${XCCDF_RESULT_FAIL}
done

for s64 in "${syscalls64[@]}"; do
    auditctl -l -k ${key} | egrep "^-a always,exit -F arch=b64 -S (\w+,)*"${s64}"\b" |\
        grep -P "(?=.*\bauid!=-1\b)(?=.*\bauid>=${uid_min}\b)(?=.*-C\s+uid!=euid\b)(?=.*-F\s+euid=0\b)" ||\
        exit ${XCCDF_RESULT_FAIL}
done

for path in "${paths[@]}"; do
    auditctl -l -k ${key} | egrep "^-w ${path} -p wa\b" ||\
        exit ${XCCDF_RESULT_FAIL}
done

exit ${XCCDF_RESULT_PASS}
