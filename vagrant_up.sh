#!/bin/bash

EXIT=0
vagrant up debian-router --color <<< 'boot' || EXIT=$?
vagrant up cisco-iosxe --color <<< 'boot' || EXIT=$?
echo $EXIT
exit $EXIT
