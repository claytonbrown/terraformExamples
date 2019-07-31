#!/bin/bash
# Configure and install latest tar
cd /tmp/tar-* # This *should* be safe, there should only be one match
FORCE_UNSAFE_CONFIGURE=1 ./configure
make
make install
cd ..
touch /root/.ansible_tar_installed
