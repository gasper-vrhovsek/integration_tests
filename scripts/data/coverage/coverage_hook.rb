# set up simplecov, broken out by process for recombining later
require 'fileutils'
require 'yaml'
require 'linux_admin'
require 'simplecov'

rails_root = '/var/www/miq/vmdb'

class NullFormatter
  # Takes a SimpleCov::Result and does nothing with it
  # This ensures we only get the .resultset.json files that get manually merged later
  def format(result)
    ""
  end
end

SimpleCov.start 'rails' do
  root '/'
  filters.clear
  add_filter do |src|
    include_file = src.filename =~ /^#{rails_root}/
    unless include_file
      include_file = src.filename =~ /manageiq-/
    end
    ! include_file
  end
  # Set the coverage dir for this process to "RAILS_ROOT/coverage/[ipaddress]/[pid]/"
  eth0 = LinuxAdmin::NetworkInterface.new("eth0")
  coverage_dir File.join(rails_root, "coverage", eth0.address, Process.pid.to_s)
  # make sure coverage_dir exists
  FileUtils.mkdir_p(SimpleCov.coverage_dir)
  # This needs to be unique per simplecov runner
  command_name "%s-%s" %  [eth0.address, Process.pid]
  formatter NullFormatter
end
