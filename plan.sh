pkg_origin=pftim
pkg_name=php71
pkg_distname=php
pkg_version=7.1.0
pkg_maintainer="timothy.johnson2@purina.nestle.com"
pkg_license=('PHP-7.1.0')
pkg_source=http://php.net/get/${pkg_distname}-${pkg_version}.tar.bz2/from/this/mirror
pkg_shasum=68bcfd7deed5b3474d81dec9f74d122058327e2bed0ac25bbc9ec70995228e61
pkg_filename=${pkg_distname}-${pkg_version}.tar.bz2
pkg_dirname=${pkg_distname}-${pkg_version}
pkg_deps=(
  core/libxml2 
  core/curl 
  core/zlib
  core/openssl 
  core/bzip2 
  pftim/libpng 
  core/libjpeg-turbo 
  pftim/libmcrypt 
  nsdavidson/mysql-client
)
pkg_build_deps=(
  core/bison2 
  core/gcc 
  core/make 
  core/re2c )
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_interpreters=(bin/php)

do_prepare() {
  # The configure script expects libxml2 binaries to either be in `/usr/bin`, `/usr/local/bin` or be
  # passed in as a configure param. Instead of overriding the entire do_build, symlink the
  # required executable into place.
  if [[ ! -r /usr/bin/xml2-config ]]; then
    ln -sv "$(pkg_path_for libxml2)/bin/xml2-config" /usr/bin/xml2-config
  fi
  return 0
}

do_build() {
  ./configure --prefix="$pkg_prefix" \
    --enable-fpm \
    --enable-mbstring \
    --enable-opcache \
    --with-curl="$(pkg_path_for curl)" \
    --with-openssl="$(pkg_path_for openssl)" \
    --with-xmlrpc \
    --with-bz2="$(pkg_path_for bzip2)" \
    --with-calendar \
    --with-gd \
    --with-zlib="$(pkg_path_for zlib)" \
    --with-png-dir="$(pkg_path_for libpng)" \
    --with-jpeg-dir="$(pkg_path_for libjpeg-turbo)" \
    --with-mcrypt="$(pkg_path_for libmcrypt)" \
    --with-curl="$(pkg_path_for curl)" \
    --with-mysql=mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \

  make
}

do_check() {
  make test
}

do_end() {
  # Clean up the `xml2-config` link, if we set it up.
  if [[ -n "$_clean_xml2" ]]; then
    rm -fv /usr/bin/xml2-config
  fi
}
