#!/bin/bash

# tmux depends on libevent
./libevent.bash

source build-systems/autotools.bash

# alter the compiler flags so it picks up on libevent
EXTRA_CONFIGURE_FLAGS=("CPPFLAGS=-I$PREFIX/include" "LDFLAGS=-L$PREFIX/lib -L$PREFIX/lib64")
autotools http://sourceforge.net/projects/tmux/files/tmux/tmux-1.6/tmux-1.6.tar.gz
