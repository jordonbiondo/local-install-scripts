#!/bin/bash

source install_scripts.bash

download_and_extract http://mercurial.selenic.com/release/mercurial-2.0.2.tar.gz

cd $src_dir_name
make PREFIX="$PREFIX" install