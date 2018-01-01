#!/bin/bash

base="/var/www/html"

set -x


sleep 8

cp -r live/ "rec/$(date)"

df -h