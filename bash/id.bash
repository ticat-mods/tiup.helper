function must_pd_leader_id()
{
	local name="${1}"
	set +e
	local pd=`tiup cluster display "${name}" -R pd --json 2>/dev/null | \
		jq --raw-output ".instances[]|select(.status | contains(\"L\"))|.id" 2>/dev/null`
	set -e
	if [ -z "${pd}" ]; then
		set +e
		local host_port=`tiup cluster display "${name}" -R pd | grep '\-\-\-' -A 99999 | grep 'L' | awk '{if ($2=="pd") print $3,$4}'`
		set -e
		if [ ! -z "${host_port}" ]; then
			local pd_host=`echo "${host_port}" | awk '{print $1}'`
			local pd_port=`echo "${host_port}" | awk '{print $2}' | awk -F '/' '{print $1}'`
			local pd="${pd_host}:${pd_port}"
		fi
	fi
	if [ -z "${pd}" ]; then
		echo "[:(] no pd leader found in cluster '${name}'" >&2
		exit 1
	fi
	echo "${pd}"
}

function must_store_id()
{
	local pd_leader_id="${1}"
	local version="${2}"
	local address="${3}"

	local store_id=`tiup ctl:${version} pd -u "${pd_leader_id}" store 2>/dev/null|\
		jq --raw-output ".stores[]|select(.store.address==\"${address}\").store.id"`
	if [ -z "${store_id}" ]; then
		echo "[:(] couldn't found the store id of the host '${host}'"
		exit 1
	fi
	echo "${store_id}"
}
