# vim: ts=2 sw=2 et
#
# Copyright (c) 2016-2018 Jorrit Folmer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class splunk (
  $type                       = $splunk::params::type,
  $package_source             = $splunk::params::package_source,
  $splunk_os_user             = $splunk::params::splunk_os_user,
  $splunk_os_group            = $splunk::params::splunk_os_group,
  $splunk_bindip              = $splunk::params::splunk_bindip,
  $splunk_db                  = $splunk::params::splunk_db,
  $splunk_home                = $splunk::params::splunk_home,
  $lm                         = $splunk::params::lm,
  $ds                         = $splunk::params::ds,
  $sslcompatibility           = $splunk::params::sslcompatibility,
  $ciphersuite_modern         = $splunk::params::ciphersuite_modern,
  $sslversions_modern         = $splunk::params::sslversions_modern,
  $dhparamsize_modern         = $splunk::params::dhparamsize_modern,
  $ecdhcurvename_modern       = $splunk::params::ecdhcurvename_modern,
  $ciphersuite_intermediate   = $splunk::params::ciphersuite_intermediate,
  $sslversions_intermediate   = $splunk::params::sslversions_intermediate,
  $dhparamsize_intermediate   = $splunk::params::dhparamsize_intermediate,
  $ecdhcurvename_intermediate = $splunk::params::ecdhcurvename_intermediate,
  $requireclientcert          = $splunk::params::requireclientcert,
  $reuse_puppet_certs         = $splunk::params::reuse_puppet_certs,
  $sslcertpath                = $splunk::params::sslcertpath,
  $sslrootcapath              = $splunk::params::sslrootcapath,
  $sslpassword                = $splunk::params::sslpassword,
  $sslverifyservercert        = $splunk::params::sslverifyservercert,
  $inputport                  = $splunk::params::inputport,
  $httpport                   = $splunk::params::httpport,
  $kvstoreport                = $splunk::params::kvstoreport,
  $mgmthostport               = $splunk::params::mgmthostport,
  $tcpout                     = $splunk::params::tcpout,
  $searchpeers                = $splunk::params::searchpeers,
  $admin                      = $splunk::params::admin,
  $clustering                 = $splunk::params::clustering,
  $replication_port           = $splunk::params::replication_port,
  $shclustering               = $splunk::params::shclustering,
  $service                    = $splunk::params::service,
  $use_ack                    = $splunk::params::use_ack,
  $ds_intermediate            = $splunk::params::ds_intermediate,
  $repositorylocation         = $splunk::params::repositorylocation,
  $version                    = $splunk::params::version,
  $auth                       = $splunk::params::auth,
  $rolemap                    = $splunk::params::rolemap,
  $dontruncmds                = $splunk::params::dontruncmds,
  $pass4symmkey               = $splunk::params::pass4symmkey,
  $minfreespace               = $splunk::params::minfreespace,
  $phonehomeintervalinsec     = $splunk::params::phonehomeintervalinsec,
  $secret                     = $splunk::params::secret,
  $maxbackupindex             = $splunk::params::maxbackupindex,
  $maxfilesize                = $splunk::params::maxfilesize,
  $maxkbps                    = $splunk::params::maxkbps
  ) inherits splunk::params {

  case $::osfamily {
    /^[Ww]indows$/: {
      if $type == 'uf' {
        $splunk_home = 'c:/program files/splunkuniversalforwarder'
        $package = 'UniversalForwarder'
      } else {
        $splunk_home = 'c:/program files/splunk'
        $package = 'Splunk Enterprise'
      }
      if $splunk_os_user == undef {
        $real_splunk_os_user = 'S-1-5-18'
      }
      if $splunk_os_group == undef {
        $real_splunk_os_group = 'Administrators'
      }
      $real_splunk_dir_mode = '0775'
      $real_splunk_file_mode = '0774'
    }
    default: {
      if $type == 'uf' {
        $splunk_home = '/opt/splunkforwarder'
        $package = 'splunkforwarder'
      } else {
        $splunk_home = '/opt/splunk'
        $package = 'splunk'
      }
      if $splunk_os_user == undef {
        $real_splunk_os_user = 'splunk'
      }
      if $splunk_os_group == undef {
        $real_splunk_os_group = 'splunk'
      }
      $real_splunk_dir_mode = '0700'
      $real_splunk_file_mode = '0600'
    }
  }

  case $sslcompatibility {
    'modern':            {
      $ciphersuite   = $ciphersuite_modern
      $sslversions   = $sslversions_modern
      $dhparamsize   = $dhparamsize_modern
      $ecdhcurvename = $ecdhcurvename_modern }
    'intermediate':      {
      $ciphersuite   = $ciphersuite_intermediate
      $sslversions   = $sslversions_intermediate
      $dhparamsize   = $dhparamsize_intermediate
      $ecdhcurvename = undef }
    default: {
      $ciphersuite   = undef
      $sslversions   = undef
      $dhparamsize   = undef
      $ecdhcurvename = undef }
  }

  if $shclustering[mode] == 'searchhead' {
    # for SHC nodes we only place bootstrap config, so make
    # sure that staging directories end up using default dir
    # instead of local, and don't replace any existing config 
    $splunk_app_precedence_dir = 'default'
    $splunk_app_replace = false
  } else {
    $splunk_app_precedence_dir = 'local'
    $splunk_app_replace = true
  }

  include splunk::installed
  include splunk::inputs
  include splunk::outputs
  include splunk::certs::s2s
  include splunk::web
  include splunk::server::general
  include splunk::server::ssl
  include splunk::server::license
  include splunk::server::kvstore
  include splunk::server::clustering
  include splunk::server::shclustering
  include splunk::server::diskusage
  include splunk::splunk_launch
  include splunk::deploymentclient
  include splunk::distsearch
  include splunk::passwd
  include splunk::authentication
  include splunk::secret
  include splunk::mgmtport
  include splunk::first_time_run
  include splunk::loglocal
  include splunk::limits
  include splunk::service

  # make sure classes are properly ordered and contained
  anchor { 'splunk_first': }
  -> Class['splunk::installed']
  -> Class['splunk::inputs']
  -> Class['splunk::outputs']
  -> Class['splunk::certs::s2s']
  -> Class['splunk::web']
  -> Class['splunk::server::general']
  -> Class['splunk::server::ssl']
  -> Class['splunk::server::license']
  -> Class['splunk::server::kvstore']
  -> Class['splunk::server::clustering']
  -> Class['splunk::server::shclustering']
  -> Class['splunk::server::diskusage']
  -> Class['splunk::splunk_launch']
  -> Class['splunk::deploymentclient']
  -> Class['splunk::distsearch']
  -> Class['splunk::passwd']
  -> Class['splunk::authentication']
  -> Class['splunk::secret']
  -> Class['splunk::mgmtport']
  -> Class['splunk::first_time_run']
  -> Class['splunk::loglocal']
  -> Class['splunk::limits']
  -> Class['splunk::service']
  -> splunk::addsearchpeers { $searchpeers: }
  anchor { 'splunk_last': }
}

