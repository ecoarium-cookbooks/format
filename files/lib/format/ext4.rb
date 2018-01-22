require "format/base"

module Format
  class Ext4 < Base

    def run_resource()
      shell_command! "parted #{device} mklabel gpt" unless shell_true?("parted #{device} print | grep gpt")
      shell_command! "yes | parted #{device} mkpart logical ext4 1 -- \"-1\"" unless shell_true?("parted #{device} print | grep logical | grep -v physical")
      shell_command! "parted #{device} set 1 lvm on" unless shell_true?("parted #{device} print | grep lvm")
      shell_command! "mkfs.ext4 #{device}" , {:timeout => timeout}
    end

    def should_run?
      pkg_install = Chef::Resource::Package.new("parted", run_context)
      pkg_install.run_action(:install)

      !shell_true?("parted #{device} print | grep ext4")
    end
  end
end
