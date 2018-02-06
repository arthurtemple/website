#!/bin/bash
# Welcome to some awkward git helper
# Do not use at home

MESSAGE=$1

if [ -z "$MESSAGE" ]; then
	echo "No commit message supplied"
	exit 1
fi

REMOTE=${2:-origin}
BRANCH=${3:-master}

# Push submodules
git submodule update
pushd output
git checkout master
git add -A
git commit -m "$MESSAGE"
git push $REMOTE $BRANCH
popd

# Push root
git add -A
git commit -m "$MESSAGE"
git push $REMOTE $BRANCH
