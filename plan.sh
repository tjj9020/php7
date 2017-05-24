pkg_origin=pftim
pkg_name=php71
pkg_distname=php
pkg_version=7.1.5
pkg_maintainer="timothy.johnson2@purina.nestle.com"
pkg_license=('PHP-3.01')
pkg_upstream_url=http://php.net/
pkg_source=http://php.net/get/${pkg_distname}-${pkg_version}.tar.bz2/from/this/mirror
pkg_shasum=28eaa4784f1bd8b7dc71206dc8c4375510199432dc17af6906b14d16b3058697
pkg_filename=${pkg_distname}-${pkg_version}.tar.bz2
pkg_dirname=${pkg_distname}-${pkg_version}
pkg_deps=(
  core/coreutils
  core/libxml2 
  core/curl 
  core/zlib
  core/openssl 
  core/bzip2 
  core/libpng 
  core/libjpeg-turbo 
  pftim/libmcrypt 
  core/mysql-client
  core/glibc
)
pkg_build_deps=(
  core/bison2 
  core/gcc 
  core/make 
  core/re2c 
)
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
    --enable-exif \
    --enable-fpm \
    --with-fpm-user=hab \
    --with-fpm-group=hab \
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
    --with-pdo-mysql=mysqlnd
  make
}

do_install() {
  do_default_install

  ln -s $pkg_prefix/sbin/php-fpm $pkg_prefix/bin/php-fpm

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

