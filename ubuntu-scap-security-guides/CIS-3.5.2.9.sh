#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# 3.5.2.9 Ensure nftables service is enabled
rule_type="nftables"

# verify if rule type matches the current firewall being audited
if [ "${XCCDF_VALUE_fw_choice}" != "${rule_type}" ]; then
    exit ${XCCDF_RESULT_NOT_APPLICABLE}
fi

# Check if nftables is enabled
systemctl is-enabled nftables &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
