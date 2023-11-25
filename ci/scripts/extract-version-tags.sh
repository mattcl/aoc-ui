#!/bin/sh
set -ex

# this is fragile, and we'd be better off with jq, but keep this similar to the
# rust one
VERSION=$(cat repo/package.json | grep version | head -1 | cut -d '"' -f 4)

docker_tag_exists() {
    curl --silent -f --head -lL https://hub.docker.com/v2/repositories/$1/tags/$2/ > /dev/null
}

if docker_tag_exists "$IMAGE_REPO" "$VERSION"; then
    echo "Version ${VERSION} already exists. Not including it in tags."
    echo "dev" > image-tags/tags
else
    echo "Version ${VERSION} not detected in remote. Including it in the tags."
    echo "${VERSION} dev" > image-tags/tags
fi

cat image-tags/tags
