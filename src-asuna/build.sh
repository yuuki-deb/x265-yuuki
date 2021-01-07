#!/bin/bash

distributions="${@:-buster}"
reg='_(.*)\+'
os_cache_date=$(date +%Y-%W)
git_tag=${git_tag:-Asuna}
rev=${rev:-1}
git_commit=$(git ls-remote https://github.com/msg7086/x265-Yuuki-Asuna.git $git_tag | cut -f1)

echo OS Cache: $os_cache_date
echo Git Tag: $git_tag
echo Git Commit: $git_commit
echo Build Rev: $rev

for distribution in $distributions; do
  if [[ -f $distribution/Dockerfile ]]; then
    dockerfile=$distribution/Dockerfile
  else
    dockerfile=_shared/Dockerfile
  fi
  echo Using dockerfile: $dockerfile
  docker build \
    --add-host=deb.debian.org:185.255.55.26 \
    --add-host=security.debian.org:185.255.55.26 \
    --add-host=archive.ubuntu.com:185.255.55.26 \
    --add-host=security.ubuntu.com:185.255.55.26 \
    --build-arg os=$distribution \
    --build-arg os_cache_date=$os_cache_date \
    --build-arg git_tag=$git_tag \
    --build-arg git_commit=$git_commit \
    --build-arg rev=$rev \
    -f $dockerfile -t x265-asuna:$distribution .

  build_dir=`docker inspect x265-asuna:$distribution | jq -r '.[0].GraphDriver.Data.UpperDir'`/build

  [[ $(ls $build_dir/reg/x265-asuna_*.deb | head -1) =~ $reg ]]
  version=${BASH_REMATCH[1]}
  mkdir -p ../dist/$version
  rm -rf ../dist/$version/$distribution
  rm -r $build_dir/reg/*dbgsym*
  cp -r $build_dir/reg ../dist/$version/$distribution
done
