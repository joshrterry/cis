#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# 3.5.3.2.4 Ensure firewall rules exist for all open ports
rule_type="iptables"

# verify if rule type matches the current firewall being audited
if [ "${XCCDF_VALUE_fw_choice}" != "${rule_type}" ]; then
    exit ${XCCDF_RESULT_NOT_APPLICABLE}
fi

# If iptables is not installed, this pass
dpkg -s iptables | grep -w "^Status: install ok installed" &>/dev/null || exit $XCCDF_RESULT_PASS

# Iterate list of open ports which are not local-address-bound-only
# Fields cut below are <protocol> and <address:port>
ss -4tuln | tail -n+2 | tr -s ' '| cut -d' ' -f1,5 | egrep -v '127(\.[0-9]{1,3}){3}(%lo)?' | tr ':' ' ' |\
 while read proto addr port; do
    # Address can contain the associated interface (suffix %<interface name>), so separate it before looking at
    # iptables output
    filt_addr=$(echo ${addr} | cut -d% -f1)

    # Try to match each triplet found to one or more iptables rules.
    # Fields cut below are <target> <protocol> <interface> <source address> <destination address> <protocol> dpt:<port>
    iptables -n -L INPUT -v | tail -n+3 | tr -s ' ' | cut -d ' ' -f4,5,7,9,10,11,12 |\
      grep -P "^ACCEPT\s+${proto}\s+[^\s]+(?<!\blo)\s+0\.0\.0\.0/0\s+(${filt_addr}|0\.0\.0\.0)(/0)?\s+${proto}\s+dpt:${port}"
    if [ $? -ne 0 ]; then
        # If there is no match, end subshell with failure status.
        exit 1
    fi
done

# Check the return status of the subshell loop
if [ $? -eq 0 ]; then
    exit $XCCDF_RESULT_PASS
fi

# If it didn't succeed, then a port was found without a respective firewall rule
exit $XCCDF_RESULT_FAIL
