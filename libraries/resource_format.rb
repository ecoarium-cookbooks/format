
require 'chef/resource'

class Chef
  class Resource
    class FormatDrive < Chef::Resource

      def initialize(name, run_context=nil)
        super
        @device = name
        @resource_name = :format_drive
        @allowed_actions.push(:format)
        @action = :format
        @provider = Chef::Provider::FormatDrive
      end

      def type(arg=nil)
        set_or_return(
          :type,
          arg,
          kind_of: Symbol,
          default: :ext4
        )
      end

      def device(arg=nil)
        set_or_return(
          :device,
          arg,
          kind_of: String,
          require: true
        )
      end

      def timeout(arg=nil)
        set_or_return(
          :timeout,
          arg,
          kind_of: Integer,
          default: 300
        )
      end

    end
  end
end

