function cluster_tidbs()
{
	local name="${1}"
	set +e
	local tidbs=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep -P '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | \
		awk '{if ($2=="tidb") print $1}'`
	set -e
	echo "${tidbs}"
}

function must_cluster_tidbs()
{
	local name="${1}"
	local tidbs=`cluster_tidbs "${name}"`
	if [ -z "${tidbs}" ]; then
		echo "[:(] no tidb found in cluster '${name}'" >&2
		return 1
	fi
	echo "${tidbs}"
}

function cluster_tikvs()
{
	local name="${1}"
	set +e
	local tikvs=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep -P '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | \
		awk '{if ($2=="tikv") print $1}'`
	set -e
	echo "${tikvs}"
}

function must_cluster_tikvs()
{
	local name="${1}"
	local tikvs=`cluster_tikvs "${name}"`
	if [ -z "${tikvs}" ]; then
		echo "[:(] no tikv found in cluster '${name}'" >&2
		return 1
	fi
	echo "${tikvs}"
}

function cluster_tiflashs()
{
	local name="${1}"
	set +e
	local tiflashs=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep -P '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | \
		awk '{if ($2=="tiflash") print $1}'`
	set -e
	echo "${tiflashs}"
}

function must_cluster_tiflashs()
{
	local name="${1}"
	local tiflashs=`cluster_tiflashs "${name}"`
	if [ -z "${tiflashs}" ]; then
		echo "[:(] no tiflash found in cluster '${name}'" >&2
		return 1
	fi
	echo "${tiflashs}"
}

function cluster_dashboard()
{
	local name="${1}"
	set +e
	local dashboard=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep -P '\-\-\-\-\-\-\-$' -B 9999 || test $? = 1; } | \
		{ grep 'dashboard' || test $? = 1; } | awk '{print $NF}'`
	set -e
	echo "${dashboard}"
}

function cluster_grafana()
{
	local name="${1}"
	set +e
	local grafana=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep -P '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | \
		awk '{if ($2=="grafana") print $1}'`
	set -e
	echo "${grafana}"
}

function must_cluster_pd()
{
	local name="${1}"
	set +e
	local pd=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep -P '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | \
		awk '{if ($2=="pd") print $1}' | head -n 1`
	set -e
	if [ -z "${pd}" ]; then
		echo "[:(] no pd found in cluster '${name}'" >&2
		return 1
	fi
	echo "${pd}"
}

function must_pd_addr()
{
	local name="${1}"
	set +e
	local pd=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep -P '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | \
		awk '{if ($2=="pd") print $1}' | head -n 1`
	set -e
	if [ -z "${pd}" ]; then
		echo "[:(] no pd found in cluster '${name}'" >&2
		return 1
	fi
	echo "${pd%/*}"
}

function prometheus_addr()
{
	local name="${1}"
	set +e
	local prom=`tiup cluster display "${name}" 2>/dev/null | \
		{ grep -P '\-\-\-\-\-\-\-$' -A 9999 || test $? = 1; } | \
		awk '{if ($2=="prometheus") print $3":"$4}' | awk -F '/' '{print $1}'`
	set -e
	echo "${prom}"
}

function must_prometheus_addr()
{
	local name="${1}"
	local prom=`prometheus_addr "${name}"`
	if [ -z "${prom}" ]; then
		echo "[:(] no prometheus found in cluster '${name}'" >&2
		return 1
	fi
	echo "${prom}"
}
