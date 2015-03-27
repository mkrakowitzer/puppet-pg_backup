require 'spec_helper'

describe 'pg_backup' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "pg_backup class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('pg_backup') }
          it { is_expected.to contain_class('pg_backup::install')
            .that_comes_before('pg_backup::config') }
          it { is_expected.to contain_class('pg_backup::config') }
          it 'should manage the pg_backup directory' do
            should contain_file('/opt/pg_backup').with({
              'ensure' => 'directory',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0755',
            })
          end
          it 'should manage the postgres backup scripts' do
            should contain_file('/opt/pg_backup/pg_backup_rotated.sh').with({
              'ensure' => 'present',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0755',
            })
            should contain_file('/opt/pg_backup/pg_backup.sh').with({
              'ensure' => 'present',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0755',
            })
            should contain_file('/opt/pg_backup/pg_basebackup.sh').with({
              'ensure' => 'present',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0755',
            })
          end
          it 'should manage the postgres backup scripts config file' do
            should contain_file('/opt/pg_backup/pg_backup.config').with({
              'ensure' => 'present',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644',
            })
            .with_content(/^BACKUP_USER=postgres$/)
            .with_content(/^HOSTNAME=localhost$/)
            .with_content(/^USERNAME=postgres$/)
            .with_content(/^BACKUP_DIR=\/opt\/backups\/$/)
            .with_content(/^SCHEMA_ONLY_LIST=""/)
            .with_content(/^ENABLE_CUSTOM_BACKUPS=yes$/)
            .with_content(/^ENABLE_PLAIN_BACKUPS=yes$/)
            .with_content(/^DAY_OF_WEEK_TO_KEEP=5$/)
            .with_content(/^DAYS_TO_KEEP=7$/)
            .with_content(/^WEEKS_TO_KEEP=5$/)
            .with_content(/^DATADIR=$/)
            .with_content(/^PORT=5432$/)
          end
          it 'should manage a cron job for the  postgres backup' do
            should contain_cron('Scheduled postgres backup').with({
              'ensure'   => 'present',
              'command'  => "/opt/pg_backup/pg_backup_rotated.sh",
              'user'     => 'postgres',
              'hour'     => '20',
              'minute'   => '0',
            })
          end
        end
      end
    end
  end

#  context 'unsupported operating system' do
#    describe 'pg_backup class without any parameters on Solaris/Nexenta' do
#      let(:facts) {{
#        :osfamily        => 'Solaris',
#        :operatingsystem => 'Nexenta',
#      }}
#
#      it { expect { is_expected.to contain_class('pg_backup') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
#    end
#  end
end
