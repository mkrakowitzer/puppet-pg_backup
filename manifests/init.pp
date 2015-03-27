# == Class: pg_backup
#
# A puppet module to configure/manage local and remote postgresql backups.
#
# === Parameters
#
# [*script_name*]
#   The backup script to use. Options are:
#
#   'pg_backup_rotated.sh'   Rotates backups.
#   'pg_backup.sh'           Does not rotate/cleanup backups.
#   'pg_basebackup.sh'       PITR recovery backup using pg_basebackup.
#
#   Defaults to 'pg_backup_rotated.sh'.
#
# [*backup_user*]
#   Optional system user to run backups as.  If the user the script is running
#   as doesn't match this the script terminates.  Defaults to 'postgres'.
#
# [*hostname*]
#   hostname to adhere to pg_hba policies.
#   Will default to 'localhost' if none specified.
#   Valid options are also the Unix domain socket directory
#   such as '/var/run/postgresql'
#
# [*port*]
#   The port to connect to the database on. Defaults to '5432'.
#
# [*username*]
#   Optional username to connect to database as.
#   Will default to 'postgres' if none specified.
#
# [*backup_dir*]
#   This dir will be created if it doesn't exist.  The creation is not managed
#   by puppet however.  This must be writable by the user the script is running
#   as. Defaults to '/opt/backups/'.
#
# [*data_dir*]
#   The dir to backup when using the pg_basebackup.sh script for PITR backup.
#
# [*schema_only_list*]
#   List of strings to match against in database name, separated by space or
#   comma, for which we only wish to keep a backup of the schema, not the data.
#   Any database names which contain any of these values will be considered
#   candidates. (e.g. "system_log" will match "dev_system_log_2010-01").
#   Defaults to ''.
#
# [*enable_custom_backups*]
#   Will produce a custom-format backup if set to "yes". Defaults to yes.
#
# [*enable_plain_backups*]
#   Will produce a gzipped plain-format backup if set to "yes".
#   Defaults to yes.
#
# [*day_of_week_to_keep*]
#   Which day to take the weekly backup from (1-7 = Monday-Sunday) to keep.
#   Defaults to 5.
#
# [*days_to_keep*]
#   Number of days to keep daily backups. Defaults to 7.
#
# [*weeks_to_keep*]
#   How many weeks to keep weekly backups. Defaults to 5.
#
# [*hour*]
#   Allowed values '0-23'. Defaults to '20'.
#
# [*minute*]
#   Allowed values '0-59'. Defaults to undef.
#
# [*month*]
#   Allowed values '1-31'. Defaults to undef.
#
# [*monthday*]
#  Allowed values '1-12'. Defaults to undef.
#
# [*weekday*]
#  Allowed values '0-7'. Defaults to undef.
#
# [*special*]
#   Instead of the first five fields, one of eight special strings
#   may be used.  Defaults to 'undef'. Overrides more specific time
#   of day/week settings. Valid values are:
#   @reboot        Run once, at startup.
#   @yearly        Run once a year
#   @annually      (same as @yearly)
#   @monthly       Run once a month
#   @weekly        Run once a week
#   @daily         Run once a day
#   @midnight      (same as @daily)
#   @hourly        Run once an hour
#
class pg_backup (

  $ensure                = 'present',
  $script_name           = 'pg_backup_rotated.sh',
  $backup_user           = 'postgres',
  $hostname              = 'localhost',
  $port                  = '5432',
  $username              = 'postgres',
  $install_dir           = '/opt/pg_backup',
  $backup_dir            = '/opt/backups/',
  $data_dir              = '',
  $schema_only_list      = '',
  $enable_custom_backups = 'yes',
  $enable_plain_backups  = 'yes',
  $day_of_week_to_keep   = 5,
  $days_to_keep          = 7,
  $weeks_to_keep         = 5,

  # Backup date
  $hour     = '20',
  $minute   = '0',
  $month    = undef,
  $monthday = undef,
  $weekday  = undef,
  $special  = 'UNSET',

) {

  class { '::pg_backup::install': } ->
  class { '::pg_backup::config': } ->
  Class['::pg_backup']

  validate_re($ensure, [ '^present', '^absent' ])
  validate_string($backup_user)
  validate_string($username)
  validate_string($hostname)
  validate_absolute_path($backup_dir)
  validate_re($backup_dir, '/$', 'Paths must have a trailing / (slash)')
  validate_re($enable_custom_backups, [ '^yes', '^no' ])
  validate_re($enable_plain_backups, [ '^yes', '^no' ])

  #TODO: Waiting for stdlib 4.6
  #validate_integer($day_of_week_to_keep,7,0)
  #validate_integer($days_to_keep)
  #validate_integer($weeks_to_keep)

  validate_re($script_name, [
    '^pg_backup_rotated.sh',
    '^pg_backup.sh',
    'pg_basebackup.sh'
  ],
    'script_name is not valid'
  )

  validate_re($special, [
    'reboot',
    'yearly',
    'annually',
    'monthly',
    'weekly',
    'daily',
    'midnight',
    'hourly',
    'UNSET',
  ])

}
