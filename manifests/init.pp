# Class: gitsource
#
# This class installs git compiling it from sources
#
# Paremeters:
#
#   $version - the version as denoted in source filename
#
#
class gitsource (
  $version    = '2.1.4',
)
{
  class { 'gitsource::prereqs': }
  
  exec { 'download git source':
    command => "curl -o /tmp/git-${version}.tar.gz https://www.kernel.org/pub/software/scm/git/git-${version}.tar.gz",
    unless  => "test -f /tmp/git-${version}.tar.gz",
    cwd     => '/tmp',
    timeout => 0,
    require => Class['gitsource::prereqs'],
  }

  exec { 'untar git source':
    command => "tar xvf git-${version}.tar.gz",
    cwd     => '/tmp',
    unless  => "test -d /tmp/git-${version}",
    timeout => 0,
    require => Exec['download git source'],
  }
  
  exec { 'make git all':
    command => 'make prefix=/usr/local/git all',
    cwd     => "/tmp/git-${version}",
    timeout => 0,
    require => Exec['untar git source'],
  }
  
  exec { 'make git install':
    command => 'make prefix=/usr/local/git install',
    cwd     => "/tmp/git-${version}",
    timeout => 0,
    require => Exec['make git all'],
  }
  
  if $::osfamily == 'RedHat'{
    file_line { 'export PATH=$PATH:/usr/local/git/bin':
      ensure  => present,
      path    => '/etc/bashrc',
      line    => 'export PATH=$PATH:/usr/local/git/bin',
      require => Exec['make git install'],
    }
  }
}

