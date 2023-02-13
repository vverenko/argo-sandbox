set -e
set -u

echo "[+] Action start"
SOURCE_DIRECTORY="${2}"
DESTINATION_GITHUB_USERNAME="${3}"
DESTINATION_REPOSITORY_NAME="argo-sandbox-manifest"
GITHUB_SERVER="github.com"
USER_EMAIL="${6}"
USER_NAME="${7}"
DESTINATION_REPOSITORY_USERNAME="vverenko"
TARGET_BRANCH="master"
COMMIT_MESSAGE="[BOT]update tags"
TARGET_DIRECTORY="${11}"

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
	echo "[+] GIT_CMD_REPOSITORY: $GIT_CMD_REPOSITORY"
else
	echo "::error::API_TOKEN_GITHUB and SSH_DEPLOY_KEY are empty. Please fill one (recommended the SSH_DEPLOY_KEY)"
	exit 1
fi

echo "[+] Git version"
git --version