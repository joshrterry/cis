#!/bin/bash
#
# "Copyright 2021 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# 3.5.2.6 Ensure loopback traffic is configured
rule_type="nftables"

# verify if rule type matches the current firewall being audited
if [ "${XCCDF_VALUE_fw_choice}" != "${rule_type}" ]; then
    exit ${XCCDF_RESULT_NOT_APPLICABLE}
fi

# Check if there are base chains for IPv4
nft list ruleset | awk '/hook input/,/}/' | grep 'iif "lo" accept' &>/dev/null &&\
    nft list ruleset | awk '/hook input/,/}/' | grep 'ip saddr' &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

# If IPv6 is enabled, check if there are base chains for it too
if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    nft list ruleset | awk '/hook input/,/}/' | grep 'ip6 saddr' &>/dev/null
    if [ $? -ne 0 ]; then
        exit ${XCCDF_RESULT_FAIL}
    fi
fi

exit ${XCCDF_RESULT_PASS}
