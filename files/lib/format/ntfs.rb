require "format/base"

module Format
  class Ntfs < Base

    def run_resource()
      script = %^
select disk #{device}
attributes disk clear readonly
convert dynamic
create volume simple disk=#{device}
format fs=ntfs quick label=extra
exit
^

      test_script = %^
list disk
exit
^
      script_file = Tempfile.open("diskpart_script")
      test_script_file = Tempfile.open("test_script")
      begin
        script_file.puts(script)
        script_file.close
        test_script_file.puts(test_script)
        test_script_file.close

        shell_command! "diskpart /s #{script_file.path}" if shell_true?("diskpart /s #{test_script_file.path} | findstr \"Disk #{device}\"")
      ensure
        script_file.close
        script_file.unlink
        test_script_file.close
        test_script_file.unlink
      end
    end

    def should_run?
      test_script = %^
list volume
exit
^

      test_script_file = Tempfile.open("test_script")
      begin
        test_script_file.puts(test_script)
        test_script_file.close
        result = !shell_true?("diskpart /s #{test_script_file.path} | findstr extra")
      ensure
        test_script_file.close
        test_script_file.unlink
      end
      result
    end
  end
end
