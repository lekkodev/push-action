#!/bin/bash -e
cd ${GITHUB_WORKSPACE}
DOT_LEKKO="$(lekko conf)"
echo "repository="$(echo "$DOT_LEKKO" | jq '.repository' --raw-output)"" >> $GITHUB_OUTPUT
echo "lekko_path="$(echo "$DOT_LEKKO" | jq '.lekkoPath' --raw-output)"" >> $GITHUB_OUTPUT
