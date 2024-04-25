function poetry_init {
	# Check if Poetry is installed
	if command -v poetry &>/dev/null; then
		echo "Poetry is already installed."
	else
		echo "Installing Poetry..."
		pip install poetry

		echo "Installing poetry-exec-plugin..."
		pip install poetry-exec-plugin
		poetry self add poetry-exec-plugin

		echo "Poetry and poetry-exec-plugin have been installed."
	fi
}

poetry_init()