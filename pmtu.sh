#!/usr/bin/env bash

pingit () {
	if [ "$(uname -s)" == "Linux" ]; then
		if ping -c 1 -q -w 2 -W 2 -M do -s ${2} ${1} >/dev/null 2>&1; then
			return 0
		else
			return 1
		fi
	elif [ "$(uname -s)" == "Darwin" ]; then
		if ping -c 1 -q -W 2000 -D -s ${2} ${1} >/dev/null 2>&1; then
			return 0
		else
			return 1
		fi

	fi
}

# test initial ping, exit if failed
if ! pingit ${1} 56 ; then
  echo "ERROR: cannot ping ${1}"
  exit
fi

lo=56
hi=1400

lr=0
hr=0
count=0
lowest_fail=99999

while [ ${count} -lt 30 ]; do
	count=$(( ${count}+1 ))

	# echo "count: ${count}, lo: ${lo}, hi: ${hi}"
	echo -n "."
	pingit ${1} ${lo}
	lr=$?
	echo -n "."
	pingit ${1} ${hi}
	hr=$?
	# echo "lr: ${lr}, hr: ${hr}"

	rsum=$(( ${lr} + ${hr} ))

	if [ ${rsum} -eq 0 ] && [ ${lo} -eq ${hi} ]; then
		echo
		echo "path to ${1} MTU: $(( ${lo} + 28 ))"
		echo
		break
	fi

	if [ ${rsum} -eq 0 ] && [ ${lo} -ne ${hi} ]; then
		lo=${hi}
		hi=$(( ${hi}*2 ))
		hi=$(( ${hi} < ${lowest_fail} ? ${hi} : ${lowest_fail} ))
	fi

	if [ ${rsum} -eq 1 ]; then
		if [ ${hi} -lt ${lowest_fail} ]; then
			lowest_fail=${hi}
		fi
		hi=$(( (( ${lo} + ${hi} )) / 2 ))
	fi

done
