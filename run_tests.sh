#!/bin/bash

set -e

./update_scripts.sh

pushd tests/

./run.sh

popd
