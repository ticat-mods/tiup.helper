function cluster_patch()
{
	local cluster="${1}"
	local role="${2}"
	local plain=''
	if [ ! -z "${3+x}" ]; then
		local plain="${3}"
	fi

	echo "[:-] patching local '${role}' to cluster '${cluster}'"
	local os=`_must_get_os_tiup_name`
	local arch=`_must_get_arch_tiup_name`
	tar -czvf "${role}-local-${os}-${arch}.tar.gz" "${role}-server"
	tiup cluster${plain} patch "${cluster}" "${role}-local-${os}-${arch}.tar.gz" -R "${role}" --yes #--offline
	echo "[:)] patched local '${role}' to cluster '${cluster}'"
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
		(
			cd "${path}";
			if [ -f "tidb-server" ]; then
				cluster_patch "${cluster}" 'tidb' "${plain}"
			fi
			if [ -f "tikv-server" ]; then
				cluster_patch "${cluster}" 'tikv' "${plain}"
			fi
			if [ -f "pd-server" ]; then
				cluster_patch "${cluster}" 'pd' "${plain}"
			fi
			# TODO: support tiflash
		)
	elif [ -f "${path}" ]; then
		local base=`basename ${path}`
		local dir=`dirname ${path}`
		local role="${base%*-server}"
		if [ ! "${role}" ]; then
			echo "[:(] unrecognized file '${path}'" >&2
			exit 1
		fi
		(
			cd "${dir}";
			cluster_patch "${cluster}" "${role}" "${plain}"
		)
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
