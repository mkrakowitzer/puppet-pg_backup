require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts


RSpec.configure do |c|
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
    c.fail_fast = true
  end
end

#RSpec.configure do |c|
#  c.default_facts = {
#    :puppetversion    => '3.7.4',
#  }
#end
#
