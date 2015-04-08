# == Class pg_backup::config
#
# This class is called from pg_backup for config files.
#
class pg_backup::config (
  $ensure                = $pg_backup::ensure,
  $script_name           = $pg_backup::script_name,
  $backup_user           = $pg_backup::backup_user,
  $hostname              = $pg_backup::hostname,
  $port                  = $pg_backup::port,
  $username              = $pg_backup::username,
  $install_dir           = $pg_backup::install_dir,
  $backup_dir            = $pg_backup::backup_dir,
  $data_dir              = $pg_backup::data_dir,
  $schema_only_list      = $pg_backup::schema_only_list,
  $enable_custom_backups = $pg_backup::enable_custom_backups,
  $enable_plain_backups  = $pg_backup::enable_plain_backups,
  $day_of_week_to_keep   = $pg_backup::day_of_week_to_keep,
  $days_to_keep          = $pg_backup::days_to_keep,
  $weeks_to_keep         = $pg_backup::weeks_to_keep,

) {
  if $pg_backup::special == 'UNSET' {
    $hour     = $pg_backup::hour
    $minute   = $pg_backup::minute
    $month    = $pg_backup::month
    $monthday = $pg_backup::monthday
    $weekday  = $pg_backup::weekday
    $special  = undef
  } else {
    $hour     = undef
    $minute   = undef
    $month    = undef
    $monthday = undef
    $weekday  = undef
    $special  = $pg_backup::special
  }

  file { "${install_dir}/pg_backup.config":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('pg_backup/pg_backup.config.erb'),
  }

  if $special == 'UNSET' {
    $special_real = undef
  } else {
    $special_real = $special
  }
  
  cron { 'Scheduled postgres backup':
    ensure   => $ensure,
    command  => "${install_dir}/${script_name}",
    user     => $backup_user,
    hour     => $hour,
    minute   => $minute,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
    special  => $special_real,
    require  => File["${install_dir}/pg_backup.config"]
  }

}
