$:.push File.expand_path("../files/lib", File.dirname(__FILE__))

require 'format/ext4'
require 'format/btrfs'
require 'format/ntfs'
require 'chef/provider'

class Chef
  class Provider
    class FormatDrive < Chef::Provider

      def load_current_resource
      end

      def action_format
        formater = create_formater(@new_resource.type)

        if formater.should_run?
          Chef::Log.debug("#{@new_resource} device  will be formated as a #{@new_resource.type} filesystem")
          case node['platform']
          when 'redhat', 'centos', 'fedora'
            child_pid = fork do
              formater.run_resource
              exit()
            end

            sleep_increment = 10
            max_count = @new_resource.timeout/sleep_increment

            1.upto(max_count).each{ |count|
              resource_still_running = Process.waitpid(child_pid, Process::WNOHANG).nil?

              if resource_still_running
                Chef::Log.info("Waiting for drive formatting to complete, count: #{count}")
                sleep sleep_increment
              else
                raise "failed to format drive, see above for more information!" if $?.exitstatus != 0
                break
              end
            }
          when 'mac_os_x'

          when 'windows'
            formater.run_resource
          else
            Chef::Application.fatal!("this OS is not supported: #{node['platform']}")
          end


        else
          Chef::Log.debug("#{@new_resource} device is already formated as a #{@new_resource.type} filesystem")
        end
      end

      def create_formater(format)
        formater_map   = {
          :ext4 => ::Format::Ext4,
          :btrfs => ::Format::Btrfs,
          :ntfs => ::Format::Ntfs
        }

        klass = formater_map[format]

        raise "#{format} is not a supported file system.  These are supported: #{formater_map.keys.join(', ')}." if klass.nil?

        klass.new(@new_resource.device, @new_resource.timeout, run_context)
      end
    end
  end
end
