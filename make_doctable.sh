#!/bin/bash

cat template/versiontable_intro
./make_versioncsv.sh | ./versioncsv2doctable.py
cat template/versiontable_outro

