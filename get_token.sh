#!/bin/bash
if [[ "$STAGING" == true ]]; then
  HOST="https://staging.api.lekko.dev"
else
  HOST="https://prod.api.lekko.dev"
fi
echo "Fetching GitHub access token for ${OWNER_NAME}/${REPO_NAME} for Lekko team ${TEAM_NAME}"
RESPONSE="$(buf curl ${HOST}/lekko.backend.v1beta1.GitHubService/GetInstallationAccessToken \
  -H "apikey: ${API_KEY}" \
  -d '{"team_name": "'"${TEAM_NAME}"'", "owner_name": "'"${OWNER_NAME}"'", "repo_name": "'"${REPO_NAME}"'"}')"
if [[ $? -ne 0 ]]; then
  echo "Please make sure you have accepted the latest permissions for the Lekko GitHub App by going to https://github.com/organizations/${OWNER_NAME}/settings/installations and that the app has access to this repository"
  exit 1
fi
TOKEN="$(echo "$RESPONSE" | jq --raw-output '.token')"
INSTALLATION_ID="$(echo "$RESPONSE" | jq --raw-output '.installationId')"
echo "token=${TOKEN}" >> $GITHUB_OUTPUT
echo "installation_id=${INSTALLATION_ID}" >> $GITHUB_OUTPUT
