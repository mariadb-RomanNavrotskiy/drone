#!/usr/bin/env bash

for i in $(drone server ls); do
  eval "$(drone server env $i)"
  drone server info $i | grep 'Name\|Address'
  docker images
  docker ps && echo;
done
