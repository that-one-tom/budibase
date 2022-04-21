if [[ -z "${CI}" ]]; then
  echo 'Cannot run release.sh unless in CI'
  exit 0
fi

# Go to pro package
cd ../budibase-pro

# Install NPM credentials
echo //registry.npmjs.org/:_authToken=${NPM_TOKEN} >> .npmrc 

# Release pro as same version as budibase
VERSION=$(jq -r .version lerna.json)

# Determine tag to use
COMMAND=$1
TAG=""
if [[ $COMMAND == "develop" ]]
then
  TAG="develop"
else
  TAG="latest"
fi

echo "Releasing version $VERSION"
echo "Releasing tag $TAG"
lerna publish $VERSION --yes --force-publish --dist-tag $TAG

cd -

if [[ $COMMAND == "develop" ]]
then
  # Pin pro version for develop container build
  echo "Pinning pro version"
  cd packages/server
  jq '.dependencies."@budibase/pro"="'$VERSION'"' package.json > package.json.tmp && mv package.json.tmp package.json
  cd -
  cd packages/worker
  jq '.dependencies."@budibase/pro"="'$VERSION'"' package.json > package.json.tmp && mv package.json.tmp package.json
fi
