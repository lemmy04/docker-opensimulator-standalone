#!/bin/bash

opensim_version=0.9.1.0
# installing opensim-0.9.0.1
cd /opt/
wget http://opensimulator.org/dist/opensim-${opensim_version}.tar.gz
tar xvfvz opensim-${opensim_version}.tar.gz
mv /opt/opensim-${opensim_version} /opt/opensim
rm opensim-${opensim_version}.tar.gz

