MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace

# Output the current date and time, for start up troubleshooting
date

# Retries a command a configurable number of times with backoff.
#
# The retry count is given by ATTEMPTS (default 5), the initial backoff
# timeout is given by TIMEOUT in seconds (default 1.)
#
# Successive backoffs double the timeout.
# 1 second, 2 seconds, 4 seconds, 8 seconds, 16 seconds

function with_backoff {
  # These need to be escaped for Terraform ($$)
  local max_attempts=$${ATTEMPTS-5}
  local timeout=$${TIMEOUT-5}
  local attempt=1
  local exitCode=0

  while (( $attempt < $max_attempts ))
  do
    if "$@"
    then
      return 0
    else
      exitCode=$?
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep $timeout
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ $exitCode == 0 ]]
  then
    return $exitCode
  else
    echo "You've failed me for the last time! ($@)" 1>&2
    # Terminate the userdata here, no point in proceeding
    exit $exitCode
  fi

}

# Add SSH public keys to authorized_keys
%{ for key in keys ~}
echo "${key}" >> /home/ec2-user/.ssh/authorized_keys
%{ endfor ~}

# Tweak system limits and settings
# Optimal for ElasticSearch
echo "vm.max_map_count=262144" | tee /etc/sysctl.d/99-vm_max_map_count.conf

# Optimal for Redis
echo "vm.overcommit_memory=1" | tee /etc/sysctl.d/99-vm_overcommit_memory.conf

# Optimal for ElasticSearch and Redis
echo "net.core.somaxconn=100000" | tee /etc/sysctl.d/99-net_core_somaxconn.conf
echo "net.ipv4.tcp_max_syn_backlog=100000" | tee /etc/sysctl.d/99-net_ipv4_tcp_max_syn_backlog.conf

# Optimal for Nginx
echo "net.core.netdev_max_backlog=100000" | tee /etc/sysctl.d/99-net_core_netdev_max_backlog.conf

# Optimal for Redis
echo "never" | tee /sys/kernel/mm/transparent_hugepage/enabled

# Load all system settings and persist in case of reboot
sysctl -p /etc/sysctl.d/*

--==MYBOUNDARY==--\
