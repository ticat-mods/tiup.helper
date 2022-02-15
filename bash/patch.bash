function cluster_patch()
{
	local dir="${1}"
	local cluster="${2}"
	local role="${3}"

	local plain=''
	if [ ! -z "${4+x}" ]; then
		local plain="${4}"
	fi
	if [ -z "${plain}" ]; then
		local plain=' --format=plain'
	fi

	(
		echo "(${dir})"
		cd "${dir}"
		echo "[:-] patching local '${role}' to cluster '${cluster}'"
		local os=`_must_get_os_tiup_name`
		local arch=`_must_get_arch_tiup_name`
		echo tar -czvf "${role}-local-${os}-${arch}.tar.gz" "${role}-server"
		tar -czvf "${role}-local-${os}-${arch}.tar.gz" "${role}-server"
		echo tiup cluster${plain} patch "${cluster}" "${role}-local-${os}-${arch}.tar.gz" -R "${role}" --yes
		tiup cluster${plain} patch "${cluster}" "${role}-local-${os}-${arch}.tar.gz" -R "${role}" --yes
		echo "[:)] patched local '${role}' to cluster '${cluster}'"
	)
}

function path_patch()
{
	local cluster="${1}"
	local path="${2}"
	local plain=''
	if [ ! -z "${3+x}" ]; then
		local plain="${3}"
	fi

	if [ -d "${path}" ]; then
		if [ -f "tidb-server" ]; then
			cluster_patch "${path}" "${cluster}" 'tidb' "${plain}"
		fi
		if [ -f "tikv-server" ]; then
			cluster_patch "${path}" "${cluster}" 'tikv' "${plain}"
		fi
		if [ -f "pd-server" ]; then
			cluster_patch "${path}" "${cluster}" 'pd' "${plain}"
		fi
		# TODO: support tiflash
	elif [ -f "${path}" ]; then
		local base=`basename ${path}`
		local dir=`dirname ${path}`
		local role="${base%*-server}"
		if [ ! "${role}" ]; then
			echo "[:(] unrecognized file '${path}'" >&2
			exit 1
		fi
		cluster_patch "${dir}" "${cluster}" "${role}" "${plain}"
	fi
}

function expand_version_and_path()
{
	ver_path=`expr "${ver}" : '\(.*+\)' || true`
	if [ "${ver_path}" ]; then
		path="${ver#*+}"
		ver="${ver_path%+}"
	else
		path=''
	fi
	echo "${ver} ${path}"
}

function _must_get_os_tiup_name()
{
	if [[ "${OSTYPE}" == 'linux-gnu'* ]]; then
		local os='linux'
	elif [[ "${OSTYPE}" == 'darwin'* ]]; then
		local os='darwin'
	else
		echo "[:(] not support os '${OSTYPE}'" >&2
		exit 1
	fi
	echo "${os}"
}

function _must_get_arch_tiup_name()
{
	case $(uname -m) in
		i386)   local arch='386' ;;
		i686)   local arch='386' ;;
		x86_64) local arch='amd64' ;;
		arm)    local arch='arm64' ;;
	esac
	echo "${arch}"
}
