#!/bin/bash -e

# Expected args:
# $1: base sha
# $2: head sha
# $3: whether head - base introduced Lekko to the repo

git config --global user.email "108442683+lekko-app[bot]@users.noreply.github.com"
git config --global user.name "lekko-app[bot]"
# 000... sha means no previous commit
if [[ "$1" != "0000000000000000000000000000000000000000" ]]; then
  if [[ "$3" != true ]]; then
    git reset --hard && git clean -fd
    git checkout $1
    echo "pre-sync base"
    set +e
    if ! lekko bisync -r ~/lekko; then
      # If bisync fails on base commit, ignore and try to proceed
      # This might result in detecting "unnecessary" additions, but hopefully fix PR should help resolve that
      echo "Warning: bisync failed on base ($1). The current state of your Lekko repository will be used as the base of changes."
    fi
    set -e
  else
    echo "Base did not have Lekko"
  fi
else
  echo "Base points to null commit"
fi
git reset --hard && git clean -fd
cd ~/lekko
git checkout -b ${GITHUB_REPOSITORY}-base
git add .
git commit --allow-empty -m "Reset configs to base"
cd ${GITHUB_WORKSPACE}
git checkout $2
echo "pre-sync head"
lekko bisync -r ~/lekko
git reset --hard && git clean -fd
cd ~/lekko
git checkout -b ${GITHUB_REPOSITORY}-head
git add .
git commit --allow-empty -m "After applying config changes from head"
echo "------------diffs------------"
git diff --binary --no-renames HEAD~1 HEAD > ~/lekko.patch
cat ~/lekko.patch
echo "-----------------------------"
if [[ -s ${HOME}/lekko.patch ]]; then
  # Each line is e.g. default/example;M based on status
  DIFF_INFO="$(git diff --binary --name-status --no-renames HEAD~1 HEAD | grep .star | sed -E 's/(^.+)\t(.*).star/\2;\1/g' | sort)"
  echo "diff_info<<\n" >> $GITHUB_OUTPUT
  echo -e "$DIFF_INFO" >> $GITHUB_OUTPUT
  echo "\n" >> $GITHUB_OUTPUT
fi
