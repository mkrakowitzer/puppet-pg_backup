require 'spec_helper'

describe 'pg_backup' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "pg_backup class without ensure => absent" do
          let(:params) { {:ensure => 'absent'} }

          it 'should ensure all files and directories are removed' do
            should contain_file('/opt/pg_backup').with({
              'ensure' => 'absent',
            })
            should contain_file('/opt/pg_backup/pg_backup_rotated.sh').with({
              'ensure' => 'absent',
            })
            should contain_file('/opt/pg_backup/pg_backup.sh').with({
              'ensure' => 'absent',
            })
            should contain_file('/opt/pg_backup/pg_basebackup.sh').with({
              'ensure' => 'absent',
            })
          end
        end

        context "should call pg_backup class without script_name => pg_basebackup.sh" do
          let(:params) { {:script_name => 'pg_basebackup.sh'} }
          it 'should create cronjob calling pg_basebackup.sh script' do
            should contain_cron('Scheduled postgres backup').with({
              'command'  => "/opt/pg_backup/pg_basebackup.sh",
            })
          end
        end

        context "Should connect to database with custom backup_user" do
          let(:params) { {:backup_user => 'myuser'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^BACKUP_USER=myuser$/)
            should contain_cron('Scheduled postgres backup').with({
              'user'  => "myuser",
            })
          end
        end

        context "Should connect to database with custom hostname" do
          let(:params) { {:hostname => 'hostname.example.co.za'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^HOSTNAME=hostname\.example\.co\.za$/)
          end
        end

        context "Should connect to database on port 9999" do
          let(:params) { {:port => '9999'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^PORT=9999$/)
          end
        end

        context "Should connect to database as custom user" do
          let(:params) { {:username => 'myuser'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^USERNAME=myuser$/)
          end
        end

        context "Should set custom backup directory" do
          let(:params) { {:backup_dir => '/custom/dir/'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
            .with_content(/^BACKUP_DIR=\/custom\/dir\/$/)
          end
        end

        context "Should set DATADIR to /path/to/postgresdata" do
          let(:params) { {:data_dir => '/path/to/postgresdata'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
            .with_content(/^DATADIR=\/path\/to\/postgresdata$/)
          end
        end

        context "Should set SCHEMA_ONLY_LIST to matchschema" do
          let(:params) { {:schema_only_list => 'matchschema'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^SCHEMA_ONLY_LIST="matchschema"$/)
          end
        end

        context "Should set ENABLE_CUSTOM_BACKUPS to yes" do
          let(:params) { {:enable_custom_backups => 'no'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^ENABLE_CUSTOM_BACKUPS=no$/)
          end
        end

        context "Should set ENABLE_PLAIN_BACKUPS to no" do
          let(:params) { {:enable_plain_backups => 'no'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^ENABLE_PLAIN_BACKUPS=no$/)
          end
        end

        context "Should set DAY_OF_WEEK_TO_KEEP to 7" do
          let(:params) { {:day_of_week_to_keep => '7'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^DAY_OF_WEEK_TO_KEEP=7$/)
          end
        end

        context "Should set DAYS_TO_KEEP to 365" do
          let(:params) { {:days_to_keep => '365'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^DAYS_TO_KEEP=365$/)
          end
        end

        context "Should set WEEKS_TO_KEEP to 54" do
          let(:params) { {:weeks_to_keep => '54'} }
          it do
            should contain_file('/opt/pg_backup/pg_backup.config')
              .with_content(/^WEEKS_TO_KEEP=54$/)
          end
        end

        context "Should schedule a cron job at very specific time" do
          let(:params) {{
            :hour     => '1',
            :minute   => '10',
            :month    => '7',
            :monthday => '28',
            :weekday  => '3',
          }}
          it do
            should contain_cron('Scheduled postgres backup').with({
              'hour'     => '1',
              'minute'   => '10',
              'month'    => '7',
              'monthday' => '28',
              'weekday'  => '3',
              'special'  => nil,
            })
          end
        end

        context "Should schedule a cron job at special time" do
          let(:params) {{
            :special     => 'daily',
          }}
          it do
            should contain_cron('Scheduled postgres backup').with({
              'hour'     => nil,
              'minute'   => nil,
              'month'    => nil,
              'monthday' => nil,
              'weekday'  => nil,
              'special' => 'daily',
            })
          end
        end
      end
    end
  end
end
