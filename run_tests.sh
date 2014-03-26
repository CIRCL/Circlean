#!/bin/bash

./update_scripts.sh

pushd tests/

./run.sh

popd
