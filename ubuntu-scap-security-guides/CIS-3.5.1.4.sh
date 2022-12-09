#!/bin/bash
#
# "Copyright 2020-2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# 3.5.1.4 Ensure loopback traffic is configured
rule_type="ufw"

# verify if rule type matches the current firewall being audited
if [ "${XCCDF_VALUE_fw_choice}" != "${rule_type}" ]; then
    exit ${XCCDF_RESULT_NOT_APPLICABLE}
fi

# if ufw is enabled, check for loopback traffic rule

# 1st for IPv4

ufw status verbose | grep -Pz "Anywhere on lo\s+ALLOW IN\s+Anywhere\s+Anywhere\s+DENY IN\s+127.0.0.0/8\b" &&\
    ufw status verbose | grep -P "^Anywhere\s+ALLOW OUT\s+Anywhere on lo\b"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

# then for IPv6, if IPv6 is enabled

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    # Also must be the first IPv6 rules
    ufw status verbose | grep -Pz "Anywhere \(v6\) on lo\s+ALLOW IN\s+Anywhere \(v6\)\s+Anywhere \(v6\)\s+DENY IN\s+::1\b" &&\
        ufw status verbose | grep -P "^Anywhere \(v6\)\s+ALLOW OUT\s+Anywhere \(v6\) on lo\b"
    if [ $? -ne 0 ]; then
        exit ${XCCDF_RESULT_FAIL}
    fi
fi

exit ${XCCDF_RESULT_PASS}
