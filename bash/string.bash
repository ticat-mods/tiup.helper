function tiup_output_fmt_str()
{
	local env="${1}"
	local plain=`env_val "${env}" 'tidb.tiup.plain-output'`
	local plain=`to_false "${plain}"`
	if [ "${plain}" == 'false' ]; then
		echo ''
	else
		echo ' --format=plain'
	fi
}

function tiup_confirm_str()
{
	local env="${1}"
	local confirm=`must_env_val "${env}" 'tidb.op.confirm'`
	local is_false=`to_false "${confirm}"`
	if [ "${is_false}" != 'false' ]; then
		echo ''
	else
		# skip confirm
		echo ' --yes'
	fi
}

function tiup_maybe_enable_opt()
{
	local value=`to_true "${1}"`
	local opt="${2}"
	if [ "${value}" == 'true' ]; then
		echo " ${opt}"
	else
		echo ''
	fi
}
