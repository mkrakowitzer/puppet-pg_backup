# == Class pg_backup::install
#
# This class is called from pg_backup for install.
#
class pg_backup::install(
  $install_dir = $pg_backup::install_dir,
  $ensure      = $pg_backup::ensure,
)  {

  if $ensure == 'present' {
    $real_ensure = 'directory'
  } else {
    $real_ensure = $ensure
  }

  file { $install_dir:
    ensure => $real_ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => [
      File["${install_dir}/pg_backup_rotated.sh"],
      File["${install_dir}/pg_backup.sh"],
      File["${install_dir}/pg_basebackup.sh"],
    ]
  }

  file { "${install_dir}/pg_backup_rotated.sh":
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/pg_backup/pg_backup_rotated.sh',
  }

  file { "${install_dir}/pg_backup.sh":
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/pg_backup/pg_backup.sh',
  }

  file { "${install_dir}/pg_basebackup.sh":
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/pg_backup/pg_basebackup.sh',
  }

}
