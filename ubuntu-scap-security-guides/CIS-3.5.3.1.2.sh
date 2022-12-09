#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# 3.5.3.1.2 Ensure nftables is not installed
rule_type="iptables"
pkgname="nftables"

# verify if rule type matches the current firewall being audited
if [ "${XCCDF_VALUE_fw_choice}" != "${rule_type}" ]; then
    exit ${XCCDF_RESULT_NOT_APPLICABLE}
fi

dpkg -s -- ${pkgname} 2>/dev/null | grep -qw "Status: install ok installed"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_PASS}
else
    exit ${XCCDF_RESULT_FAIL}
fi
