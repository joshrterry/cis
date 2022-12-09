#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------
set -u
#exit ${XCCDF_RESULT_FAIL}
#exit $XCCDF_RESULT_PASS

# Limitation: only checks / partition
key=privileged
uid_min=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
uid_min=${uid_min:-1000} # default value if no UID_MIN found

while read p; do
    auditctl -l -k ${key} | grep -P "^-a always,exit (?=.*-F path=${p}\b)(?=.*-F perm=x\b)" \
        | grep -P "(?=.*\bauid!=-1\b)(?=.*\bauid>=${uid_min}\b)" ||\
        exit ${XCCDF_RESULT_FAIL}
done < <(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f)

exit ${XCCDF_RESULT_PASS}
