#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# 3.5.2.1 Ensure nftables is installed
rule_type="nftables"
pkgname="nftables"

# verify if rule type matches the current firewall being audited
if [ "${XCCDF_VALUE_fw_choice}" != "${rule_type}" ]; then
    exit ${XCCDF_RESULT_NOT_APPLICABLE}
fi

dpkg -s -- ${pkgname} 2>/dev/null | grep -qw "Status: install ok installed"
if [ $? -eq 0 ]; then
    exit ${XCCDF_RESULT_PASS}
else
    exit ${XCCDF_RESULT_FAIL}
fi
