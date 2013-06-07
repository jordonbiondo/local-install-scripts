set -o nounset
set -o errexit
set -o xtrace

readonly PREFIX=$HOME/.local
readonly SOURCE_DIR=$PREFIX/src

# Sandbox directory for downloading sources
[[ ! -d $SOURCE_DIR ]] && mkdir -p "$SOURCE_DIR"
cd $SOURCE_DIR

# Download and extract a source archive (tarball).
# $1: tarball URL
# returns
# $src_dir_name: name of the source directory
download_and_extract()
{
  local archive_name=${1##*/}
	[[ -f $archive_name ]] && rm "$archive_name"
	wget "$1"
	extracted_files=$(tar -xvf "$archive_name")
	src_dir_name=$(head --lines=1 <<< "$extracted_files")
	# Remove trailing slash
	src_dir_name=${src_dir_name%%/*}
}

# Create the build directory and change to it.
# $1: name of the directory to create
create_build_dir()
{
  local build_dir=$PREFIX/build/$1
	[[ -d $build_dir ]] && rm -r "$build_dir"
  mkdir -p "$build_dir"
  cd $build_dir
}

# Patches all binaries in the current directory with the $PREFIX
# rpath.
set_rpath()
{
  find . -type f -executable -print0 | while read -r -d $'\0' binary; do
    if [[ "$(file --brief "$binary")" == ELF* ]]; then
      patchelf --set-rpath "$(patchelf --print-rpath "$binary"):$PREFIX/lib:$PREFIX/lib64" "$binary"
    fi
  done
}

# Run make and make install.
# $EXTRA_MAKE_FLAGS: array of more flags to pass to make
# $EXTRA_MAKE_STEPS: array of more make steps to run, e.g. ("make check")
# $EXTRA_MAKE_INSTALL_FLAGS: array of more flags to pass to make install
make_install()
{
  make "${EXTRA_MAKE_FLAGS[@]:+${EXTRA_MAKE_FLAGS[@]}}"
  for step in ${EXTRA_MAKE_STEPS[@]:+${EXTRA_MAKE_STEPS[@]}}; do
    make "$step"
  done
  set_rpath
  make "${EXTRA_MAKE_INSTALL_FLAGS[@]:+${EXTRA_MAKE_INSTALL_FLAGS[@]}}" install
}