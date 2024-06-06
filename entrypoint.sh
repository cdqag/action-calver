#!/bin/sh -l

# Env and options
if [ -z "${GITHUB_WORKSPACE}" ]; then
  echo "The GITHUB_WORKSPACE environment variable is not defined."
  exit 1
fi

if [ -z "${DATE_FORMAT}" ]; then
    echo "The DATE_FORMAT environment variable is not defined."
    exit 1
fi

cd "${GITHUB_WORKSPACE}" || exit 1

# Security
git config --global --add safe.directory "${GITHUB_WORKSPACE}"

NEXT_DATE_PART="v$(date "+${DATE_FORMAT}")"

LAST_VERSION=$(git tag --sort=-v:refname | grep -E "^v" | head -n 1)
echo "Last version: ${LAST_VERSION}"

LAST_HASH="$(git show-ref -s "${LAST_VERSION}")"
echo "Last hash : ${LAST_HASH}"


if case $LAST_VERSION in $NEXT_DATE_PART*) ;; *) false;; esac ; then
	echo "Incrementing patch version.";
	new_version="${LAST_VERSION%.*}.$(( ${LAST_VERSION##*.} + 1 ))";
else
	new_version="$NEXT_DATE_PART.0";
fi;


if [ "${PRERELEASE}" = "true" ]; then \
	new_version="$new_version-pre-release"; \
fi;

NEXT_VERSION=$new_version;
echo "Next version: ${NEXT_VERSION}";
if [ "$GITHUB_OUTPUT" != "" ]; then
	echo "last_version=${LAST_VERSION}" >> "${GITHUB_OUTPUT}";
	echo "next_version=${NEXT_VERSION}" >> "${GITHUB_OUTPUT}";
fi
