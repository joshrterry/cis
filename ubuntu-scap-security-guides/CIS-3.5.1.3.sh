#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# 3.5.1.3 Ensure ufw service is enabled
rule_type="ufw"

# verify if rule type matches the current firewall being audited
if [ "${XCCDF_VALUE_fw_choice}" != "${rule_type}" ]; then
    exit ${XCCDF_RESULT_NOT_APPLICABLE}
fi

# Check if ufw is enabled in systemd
systemctl status ufw | grep -w "Active: active" &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

# Check if ufw is active
ufw status | grep -w "Status: active" &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
