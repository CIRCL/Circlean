#!/bin/bash

set -e
set -x

USERNAME='kitten'

su  ${USERNAME} -c ./groomer.sh

echo 'Done.'
# Only if running on a rPi
# shutdown -h now

