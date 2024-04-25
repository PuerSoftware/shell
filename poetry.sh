function poetry_init {
	# Check if Poetry is not installed, silently
	if ! command -v poetry &>/dev/null; then
		pip install poetry &>/dev/null
		pip install poetry-exec-plugin &>/dev/null
		poetry self add poetry-exec-plugin &>/dev/null
	fi
}


poetry_init()