#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# 3.5.2.2 Ensure Uncomplicated Firewall is not installed or disabled
rule_type="nftables"

# verify if rule type matches the current firewall being audited
if [ "${XCCDF_VALUE_fw_choice}" != "${rule_type}" ]; then
    exit ${XCCDF_RESULT_NOT_APPLICABLE}
fi

# Check if ufw is active
ufw status | grep -w "Status: active" &>/dev/null
if [ $? -eq 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
