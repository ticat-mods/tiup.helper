function must_cluster_version()
{
	local name="${1}"
	local version=`tiup cluster display "${name}" --version 2>/dev/null`
	if [ $? != 0 ]; then
		echo "[:(] no such cluster exists, please ensure the cluster name '${name}'"
		exit 1
	fi
	echo "${version}"
}

function _cluster_meta()
{
	local name="${1}"
	tiup cluster list 2>/dev/null | \
		{ grep -v 'PrivateKey$' || test $? = 1; } | \
		{ grep -P -v '\-\-\-\-\-\-\-$' || test $? = 1; } | \
		{ grep "^${name} " || test $? = 1; }
}

function cluster_exist()
{
	local name="${1}"
	local meta=`_cluster_meta ${name}`
	if [ -z "${meta}" ]; then
		echo "false"
	else
		echo "true"
	fi
}

function must_cluster_exist()
{
	local name="${1}"
	meta=`_cluster_meta ${name}`
	if [ -z "${meta}" ]; then
		echo "[:(] cluster name '${name}' not exists" >&2
		exit 1
	fi
}
