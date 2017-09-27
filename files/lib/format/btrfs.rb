require "format/base"

module Format
  class Btrfs < Base

    def initialize(device, timeout, run_context)
      super

      begin
        require 'deep_merge'
      rescue LoadError
        if @deep_merge_installed.nil?
          chef_gem = Chef::Resource::ChefGem.new('deep_merge', run_context)
          chef_gem.provider_for_action(:install).run_action
          require 'deep_merge'
          @deep_merge_installed = true
        end
      end
    end

    def run_resource()
      shell_command! "mkfs.btrfs #{device}", {:timeout => timeout}
    end

    def should_run?
      pkg_install = Chef::Resource::Package.new("btrfs-progs", run_context)
      pkg_install.run_action(:install)

      shell_command! "modprobe btrfs" if shell_true?("cat /proc/modules | grep -q btrfs")

      !shell_true?("btrfs-show | grep -q '#{device}'")
    end
  end
end