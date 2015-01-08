#!/bin/bash

if [[ $1 == 1 ]]; then
	echo 0 > /proc/sys/kernel/randomize_va_space
	ulimit -c unlimited
	sysctl kernel.core_uses_pid=1 >/dev/null 2>&1
	sysctl kernel.core_pattern=/tmp/core-%e-%s-%u-%g-%p-%t >/dev/null 2>&1
	sysctl fs.suid_dumpable=2 >/dev/null 2>&1
	sysctl -a|grep "kernel.core\|suid"
	echo "****"
	ulimit -a |grep "core"
	echo "****"
	cat /proc/sys/kernel/randomize_va_space
	echo "****"
fi
gcc -fno-stack-protector -O0 -g3 -o formatstrings formatstrings.c
