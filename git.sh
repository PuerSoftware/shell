# Git

alias gitdrop="git stash; git stash drop;"

# git push in one line
function gitpush() {
	if [ -z "$1" ]; then
		echo "No commit message provided"
		return 1
	fi
	
	git add --all
	git commit -m "$1"
	git push
}

function pushall() {
    local message="$1"
    local original_dir=$(pwd)

    # First repository
    local repo1=$REPO_EXTERNAL
    echo "Pushing in $repo1 with message: $message"
    cd "$repo1" && git add --all && git commit -m "$message" && git push

    # Second repository
    local repo2=$REPO_PUERJS
    echo "Pushing in $repo2 with message: $message"
    cd "$repo2" && git add --all && git commit -m "$message" && git push

    # Go back to the original directory
    cd "$original_dir"
}

function pushgpt() {
    local message="$1"
    local original_dir=$(pwd)

    # First repository
    local repo1=$REPO_GPT_EXTERNAL
    echo "Pushing in $repo1 with message: $message"
    cd "$repo1" && git add --all && git commit -m "$message" && git push

    # Second repository
    local repo2=$REPO_PORTS
    echo "Pushing in $repo2 with message: $message"
    cd "$repo2" && git add --all && git commit -m "$message" && git push

    # Second repository
    local repo3=$REPO_DATES
    echo "Pushing in $repo3 with message: $message"
    cd "$repo3" && git add --all && git commit -m "$message" && git push

    # Go back to the original directory
    cd "$original_dir"
}

function pullall() {
    local original_dir=$(pwd)

    # First repository
    local repo1=$REPO_EXTERNAL
    echo "Pulling from $repo1"
    cd "$repo1" && git pull

    # Second repository
    local repo2=$REPO_PUERJS
    echo "Pulling from $repo2"
    cd "$repo2" && git pull

    # Go back to the original directory
    cd "$original_dir"
}

function gitpurge() {
	git reset --hard HEAD^
}

# Initialize Git repository and sync with remote
function git_init_and_sync() {
    local git_url=$1

    if [ -z "$git_url" ]; then
        echo "No Git URL provided."
        return 1
    fi

    # Check if the folder is already a Git repository
    if [ ! -d .git ]; then
        echo "Initializing a new Git repository."
        git init
    else
        echo "Existing Git repository found."
    fi

    # Add or update the remote origin
    if git remote get-url origin 2>/dev/null; then
        echo "Updating remote 'origin' to $git_url."
        git remote set-url origin "$git_url"
    else
        echo "Adding new remote 'origin' as $git_url."
        git remote add origin "$git_url"
    fi

    # Fetch changes from the remote
    git fetch origin
    echo "Fetched changes from origin."

    # Check if the remote has a master branch
    if git show-ref --verify --quiet "refs/remotes/origin/master"; then
        echo "Remote 'master' branch found. Setting up local 'master' to track remote 'master'."
        git checkout master 2>/dev/null || git checkout -b master
        git branch --set-upstream-to=origin/master master
        git pull --rebase origin master
    else
        echo "No remote 'master' branch found."
    fi

    # Check for uncommitted or untracked changes
    if ! git diff-index --quiet HEAD -- || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "Changes found. Adding and committing them."
        git add -A
        git commit -m "Auto-committing changes"
        git push -u origin master
    else
        echo "No changes to push."
    fi
}


# git st == git status
git config --global alias.st status

