# from: http://www.digitalinternals.com/unix/unix-linux-include-header-in-grep-result/478/
function grepb () {
	IFS= read -r header
	echo "$header"
	grep "$@"
}

# No arguments: `git status`
# With arguments: acts like `git`
# from: https://github.com/thoughtbot/dotfiles/blob/master/zsh/functions/g
function g() {
	if [[ $# -gt 0 ]]; then
		git $*
	else
		git status
	fi
}

# Run "up" to "cd ..", or I can run "up 6" to "cd ../../../../../.."
# from: https://news.ycombinator.com/item?id=9869231#up_9869613
function up {
	if [[ "$#" < 1 ]] ; then
		cd ..
	else
		CDSTR=""
		for i in {1..$1} ; do
			CDSTR="../$CDSTR"
		done
		cd $CDSTR
	fi
}

function takedir() {
	mkdir -p "$1"
	cd "$1"
}

# FROM: https://coderwall.com/p/mmnoyw/a-function-to-find-and-kill-processes-running-on-a-certain-port
# USAGE: "portkill 3000"
function portkill() {
	# lsof -i TCP:$1 | grep LISTEN | awk '{print $2}' | xargs kill -9
	lsof -i TCP:$1 | awk '/LISTEN/{print $2}' | xargs kill -9
	echo "Port" $1 "found and killed."
}

# List all installed brew packages with sizes
# FROM: https://gist.github.com/eguven/23d8c9fc78856bd20f65f8bcf03e691b
function brew-sizes() {
	brew list -f1 | xargs -n1 -P8 -I {} \
		sh -c "brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'" | \
		sort -h -r -k2 - | column -t
}

function start_docker() {
	sudo service docker start; 

	# Wait for Docker daemon to start
	while ! docker info >/dev/null 2>&1; do
		echo "Waiting for Docker daemon to start..."
		sleep 1
	done

	echo "Docker daemon started."
	return 0  # Return success status (0) to make it chainable
}

