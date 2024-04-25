venv() {
	case "$1" in
		'++')                           # create
			deactivate 2> /dev/null
			if [ -z "$2" ]; then
				py -m venv venv
				echo 'export PYTHONPATH="\$PWD:\$PYTHONPATH"' >> venv/bin/activate  # For pytest
				source venv/bin/activate
				if [ -f "venv.txt" ]; then
					echo "venv.txt exists, installing..."
					while read package; do
						pip install $package
					done < venv.txt
				else
					echo "venv.txt does not exist, creating new venv.txt..."
					touch venv.txt
				fi
			else
				mkdir $2
				cd $2
				venv '++'
			fi
			;;
		'+')                            # start or install
			if [ -z "$2" ]; then
				source venv/bin/activate
			else
				source venv/bin/activate
				pip install $2
				echo $2 >> venv.txt
			fi
			;;
		'-')                            # stop or uninstall
			if [ -z "$2" ]; then
				deactivate
			else
				source venv/bin/activate
				pip uninstall $2
				grep -v "^$2$" venv.txt > venv.txt.tmp && mv venv.txt.tmp venv.txt
			fi
			;;
		'--')                           # delete
			rm -rf venv
			rm venv.txt
			deactivate 2> /dev/null
			;;
		'sync')                         # install requirements
			while read package; do
				pip install $package
			done < venv.txt
			;;
		'show')                         # show installed
			cat venv.txt
			;;
		*)
			deactivate
			source venv/bin/activate
			;;
	esac
}
