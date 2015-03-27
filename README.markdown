#puppet-pg_backup
[![Puppet Forge](http://img.shields.io/puppetforge/v/puppet/pg_backup.svg)](https://forge.puppetlabs.com/puppet/pg_backup)
[![Build Status](https://travis-ci.org/puppet-community/puppet-pg_backup.svg?branch=master)](https://travis-ci.org/puppet-community/puppet-pg_backup)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with pg_backup](#setup)
    * [What pg_backup affects](#what-pg_backup-affects)
    * [Beginning with pg_backup](#beginning-with-pg_backup)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A simple no-frills module to schedule a postgres database backup.

## Module Description

A simple module to install Postgres backup scripts and schedule one of them to run via the cron. The scripts used are provided by [wiki.postgresql.org](https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux).

## Setup

### What pg_backup affects

* Creates /opt/pg_backup  directory.
* Creates files in pg_backup directory
  * pg_backup_rotated.sh (default)
    * The same as above pg_backup.sh it will delete expired backups based on the configuration. 
  * pg_backup.sh
    *  The normal backup script which will go through each database and save a gzipped and/or a custom format copy of the backup into a date-based directory. 
  * pg_basebackup.sh
    * Script for doing PITR backups.
* Creates cronjob to run a scheduled postgres backup.

### Beginning with pg_backup

```puppet
  include ::pg_backup
```

## Usage

A more complex example using UNIX domain sockets and not a hostname to connect to database.

```puppet
  class { 'pg_backup':
    hostname            => '/var/run/postgresql',
    backup_dir          => "/opt/backups/postgres/${::hostname}/",
    day_of_week_to_keep => 5,
    days_to_keep        => 7,
    weeks_to_keep       => 5,
    special             => 'daily',
  }
```
An example using the PITR recovery script
```puppet
  class { 'pg_backup':
    script_name => 'pg_basebackup.sh',
    hostname    => '/var/run/postgresql',
    backup_dir  => "/opt/backups/postgres/${::hostname}/",
    data_dir    => '/var/lib/posgresql/9.4/main',
    special     => 'daily',
  }
```

A more complete example with most available options using the module defaults.

```puppet
  class {  'pg_backup':
    ensure                => 'present',
    script_name           => 'pg_backup_rotated.sh',
    backup_user           => 'postgres',
    hostname              => 'localhost',
    port                  => '5432',
    username              => 'postgres',
    install_dir           => '/opt/pg_backup',
    backup_dir            => '/opt/backups/',
    enable_custom_backups => 'yes',
    enable_plain_backups  => 'yes',
    day_of_week_to_keep   => 5,
    days_to_keep          => 7,
    weeks_to_keep         => 5,
    hour                  => '20',
    minute                => '0',
  }
```

A hiera example.

```puppet
include ::pg_backup
```

```yaml
pg_backup::ensure:                'present'
pg_backup::script_name:           'pg_backup_rotated.sh'
pg_backup::backup_user:           'postgres'
pg_backup::hostname:              'localhost'
pg_backup::port:                  '5432'
pg_backup::username:              'postgres'
pg_backup::install_dir:           '/opt/pg_backup'
pg_backup::backup_dir:            '/opt/backups/'
pg_backup::enable_custom_backups: 'yes'
pg_backup::enable_plain_backups:  'yes'
pg_backup::day_of_week_to_keep:   5
pg_backup::days_to_keep:          7
pg_backup::weeks_to_keep:         5
pg_backup::special:               'daily'
```

## Reference

###Classes

####Public Classes
* `pg_backup`: Main class, manages the installation and configuration of the backup scripts.

####Private Classes
* `pg_backup::install`: Installs pg_backup scripts
* `pg_backup::config`:  Configures the cron job and configuration file.

###Parameters

#####`script_name`
The backup script to use. Options are:

*  'pg_backup_rotated.sh'   Rotates backups.
*  'pg_backup.sh'           Does not rotate/cleanup backups.
*  'pg_basebackup.sh'       PITR recovery backup using pg_basebackup.

Defaults to 'pg_backup_rotated.sh'.

#####`backup_user`
Optional system user to run backups as.  If the user the script is running as doesn't match this the script terminates.  Defaults to 'postgres'.

#####`hostname`
hostname to adhere to pg_hba policies.  Will default to 'localhost' if none specified. Valid options are also the Unix domain socket directory such as '/var/run/postgresql'

#####`port`
The port to connect to the database on. Defaults to '5432'.

#####`username`
Optional username to connect to database as. Will default to 'postgres' if none specified.

#####`backup_dir`
This dir will be created if it doesn't exist.  The creation is not managed by puppet however.  This must be writable by the user the script is running as. Defaults to '/opt/backups/'.

#####`data_dir`
The dir to backup when using the pg_basebackup.sh script for PITR backup.

#####`schema_only_list`
List of strings to match against in database name, separated by space or comma, for which we only wish to keep a backup of the schema, not the data. Any database names which contain any of these values will be considered candidates. (e.g. "system_log" will match "dev_system_log_2010-01"). Defaults to ''.

#####`enable_custom_backups`
Will produce a custom-format backup if set to "yes". Defaults to yes.

#####`enable_plain_backups`
Will produce a gzipped plain-format backup if set to "yes". Defaults to yes.

#####`day_of_week_to_keep`
Which day to take the weekly backup from (1-7 = Monday-Sunday) to keep. Defaults to 5.

#####`days_to_keep`
  Number of days to keep daily backups. Defaults to 7.

#####`weeks_to_keep`
  How many weeks to keep weekly backups. Defaults to 5.

#####`hour`
  Allowed values '0-23'. Defaults to '20'.

#####`minute`
  Allowed values '0-59'. Defaults to undef.

#####`month`
  Allowed values '1-31'. Defaults to undef.

#####`monthday`
 Allowed values '1-12'. Defaults to undef.

#####`weekday`
 Allowed values '0-7'. Defaults to undef.

#####`special`
Instead of the first five fields, one of eight special strings may be used.  Defaults to 'undef'. Overrides more specific time of day/week settings. Valid values are:
*  reboot        Run once, at startup.
*  yearly        Run once a year
*  annually      (same as @yearly)
*  monthly       Run once a month
*  weekly        Run once a week
*  daily         Run once a day
*  midnight      (same as @daily)
*  hourly        Run once an hour

## Limitations

This module works with postgres 8+ by default. To use the backup script pg_basebackup.sh you mus have postgresql 9.2+.

This script will work with all supported operating systems listed in the metadata.json

## Development

See CONTRIBUTING.md

## Contributors

See CONTRIBUTORS
