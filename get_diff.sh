#!/bin/bash -e
git config --global user.email "108442683+lekko-app[bot]@users.noreply.github.com"
git config --global user.name "lekko-app[bot]"
git fsck --full
git checkout $1
echo "pre-sync base"
lekko bisync -r ~/lekko
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
