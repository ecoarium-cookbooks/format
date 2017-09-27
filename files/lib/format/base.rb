require 'chef/log'
require 'chef/mixin/command'

module Format
	class Base
		include Chef::Mixin::ShellOut
		
		attr_reader :device, :timeout, :run_context
    def initialize(device, timeout, run_context)
      @device = device
      @timeout = timeout
      @run_context = run_context
    end

    def shell_true?(command, args={})
      args = {
        :timeout => 3600,
        :live_stream => STDOUT
      }.merge(args)

      Chef::Log.debug("executing command: [#{command}]")
      shell_out(command, args).status.success?
    end

    def shell_command!(command, args={})
      args = {
        :timeout => 3600,
        :live_stream => STDOUT
      }.merge(args)

      Chef::Log.debug("executing command: [#{command}]")
      shell_out!(command, args)
    end

    def shell_script!(script, args={})
      args = {
        :timeout => 3600,
        :live_stream => STDOUT
      }.merge(args)

      script_file = Tempfile.open("shell-helper")
      begin
        script_file.puts(script)
        script_file.close

        FileUtils.chown(args[:user], args[:group], script_file.path)

        shell_out!("/bin/bash -xe #{script_file.path}", args)
      ensure
        script_file.close
        script_file.unlink
      end
    end
	end
end