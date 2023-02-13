set -e
set -u

echo "[+] Action start"
DESTINATION_REPOSITORY_NAME="argo-sandbox-manifest"
GITHUB_SERVER="github.com"
DESTINATION_REPOSITORY_USERNAME="vverenko"
TARGET_BRANCH="master"
COMMIT_MESSAGE="[BOT] update tags"

if [ -n "${SSH_DEPLOY_KEY:=}" ]
then
	echo "[+] Using SSH_DEPLOY_KEY"

	mkdir --parents "$HOME/.ssh"
	DEPLOY_KEY_FILE="$HOME/.ssh/deploy_key"
	echo "${SSH_DEPLOY_KEY}" > "$DEPLOY_KEY_FILE"
	chmod 600 "$DEPLOY_KEY_FILE"

	SSH_KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
	ssh-keyscan -H "$GITHUB_SERVER" > "$SSH_KNOWN_HOSTS_FILE"

	export GIT_SSH_COMMAND="ssh -i "$DEPLOY_KEY_FILE" -o UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE"

	GIT_CMD_REPOSITORY="git@$GITHUB_SERVER:$DESTINATION_REPOSITORY_USERNAME/$DESTINATION_REPOSITORY_NAME.git"
else
	echo "::error::API_TOKEN_GITHUB and SSH_DEPLOY_KEY are empty. Please fill one (recommended the SSH_DEPLOY_KEY)"
	exit 1
fi

git config --global user.email "updater@email.com"
git config --global user.name "[BOT] UPDATE TAGS"

echo "[+] Git version"
git --version


CLONE_DIR=$(mktemp -d)
git clone --single-branch --depth 1 --branch "$TARGET_BRANCH" "$GIT_CMD_REPOSITORY" "$CLONE_DIR"

cd "$CLONE_DIR"

touch test.txt && echo "test $RANDOM" > test.txt
git add test.txt
git commit -m "$COMMIT_MESSAGE"
git push origin "$TARGET_BRANCH"