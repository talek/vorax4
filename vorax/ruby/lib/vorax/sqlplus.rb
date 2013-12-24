# encoding: UTF-8

module Vorax

  # Provides integration with Oracle SqlPlus CLI tool.
  class Sqlplus

    attr_reader :bin_file, :default_funnel_name, :process
    
    # Creates a new sqlplus instance.
    #
    # @param bin_file [String] the path to the SqlPlus executable. By
    #   default is "sqlplus", which requires that the executable to be
    #   in $PATH.
    def initialize(bin_file = "sqlplus")
      @bin_file = bin_file
      @busy = false
      @start_marker, @end_marker, @cancel_marker = [2.chr, 3.chr, 4.chr]
      @process = ChildProcess.build(@bin_file, "/nolog")
      # On Unix we may abort the currently executing query by sending a
      # INT signal to the Sqlplus process, but we need access to the 
      # send_term private method.
      class << @process; public :send_signal; end if ChildProcess.unix?
      @process.duplex = true
      @process.detach = true
      @process.io.inherit!
      @io_read, @io_write = VoraxIO.pipe
      @process.io.stdout = @io_write
      @process.start
      @process.io.stdin.sync = true
      @current_funnel = nil
      @default_convertor_name = nil
      @registered_convertors = {:vertical => Output::VerticalConvertor,
                                :pagezip => Output::PagezipConvertor,
                                :tablezip => Output::TablezipConvertor}
      # warm up
      sleep 0.2
      # set the blockterm as the end_marker. The blockterm should
      # not be touch by the Vorax user, otherwise nasty things
      # may happen. This is also a workaround to mark the end of
      # output when the "echo" setting of sqlplus is "on". See the
      # implementation of pack().
      send_text("\n#set blockterm \"#@end_marker\"\n")
    end

    # Set the default convertor for the output returned by sqlplus.
    #
    # @param convertor_name [Symbol] the default funnel name. The
    #   valid values are: :vertical, :pagezip and :tablezip
    def default_convertor=(convertor_name)
      Vorax.debug("default_convertor=#{convertor_name.inspect}")
      @default_convertor_name = convertor_name
    end

    # Register a new convertor for the sqlplus output.
    # 
    # @param convertor_name [Symbol] the name of the convertor (key)
    # @param convertor_class [Class] the class which implements the
    #   convertor. It must be a subclass of BaseConvertor.
    def register_convertor(convertor_name, convertor_class)
      @registered_convertors[convertor_name] = convertor_class
    end

    # Execute an sqlplus command.
    #
    # @param command [String] the command to be executed.
    # @param params [Hash] additional parameters. You may use
    #   the following options:
    #     :prep => a string with commands to be executed just before
    #              running the provided command. For example, you may
    #              choose to set some sqlplus options.
    #     :post => a string with commands to be executed after the
    #              provided command was run. Here it's a good place
    #              to put commands that restores some options affected
    #              by the executed command.
    #     :convertor => the convertor used to convert the output received
    #                from Sqlplus. By default it's the convertor set with
    #                "default_convertor=" method.
    #     :pack_file => the file name into which the command(s) to be
    #                   executed are wrapped into and then sent for
    #                   execution to sqlplus using '@<file_name>'. 
    #                   Providing this option may prove to be a good
    #                   thing for big commands. If this parameter is
    #                   not provided then the command is sent directly
    #                   to the input IO of the sqlplus process.
    def exec(command, params = {})
      Vorax.debug("exec: command=[\n#{command}\n]\nparams=#{params.inspect}")
      raise AnotherExecRunning if busy?
      opts = {
        :prep => nil,
        :post => nil,
        :convertor => @default_convertor_name,
        :pack_file => nil,
      }.merge(params)
      @busy = true
      @look_for = @start_marker
      prepare_funnel(opts[:convertor])
      if @current_funnel && @current_funnel.is_a?(Output::HTMLFunnel)
        # all HTML funnels expects html format
        send_text("set markup html on\n")
      else
        send_text("set markup html off\n")
      end
      if opts[:pack_file]
        send_text("@#{pack(command, opts)}\n")
      else
        send_text("#{opts[:prep]}\n") if opts[:prep]
        capture { send_text("#{command}\n") }
        send_text("#{opts[:post]}\n") if opts[:post]
      end
    end

    # Send a text directly to the stdin of the sqlplus process.
    #
    # @param text [String] the text to be sent to sqlplus
    def send_text(text)
      Vorax.debug("sent to sqlplus: #{text}")
      @process.io.stdin.print(text)
    end

    # Check if the sqlplus process is busy executing something.
    #
    # @return true if the sqlplus is busy executing something, 
    #   false otherwise
    def busy?
      @busy
    end

    # Check if the output of a previous executed sqlpus command
    # was completely fetched out.
    #
    # @return true if the whole output was fetched, false otherwise
    def eof?
      not busy?
    end

    # Read the output spit by sqlplus process. If there is any default
    # convertor, the returned output will be formatted according to
    # that convertor.
    #
    # @param bytes [int] the maximum output chunk size
    # @return the output chunk
    def read_output(bytes=4086)
      output = ""
      raw_output = nil
      begin
        raw_output = @io_read.read_nonblock(bytes)
      rescue Errno::EAGAIN
      end
      if raw_output
        raw_output.gsub!(/\r/, '')
        scanner = StringScanner.new(raw_output)
        while not scanner.eos?
          if @look_for == @start_marker
            if text = scanner.scan_until(/#{@look_for}/)
              if text !~ /pro #{@look_for}/
                # Only if it's not part of a PROMPT sqlplus command.
                # This might happen when the "echo" sqlplus option
                # is ON and the begin marker is included into the
                # sql pack file. Because we are using big chunks to
                # read data it's very unlikely that the echoing of the
                # prompt command to be split in the middle.
                @look_for = @end_marker
              end
            else
              scanner.terminate
            end
          end
          if @look_for == @end_marker
            output = scanner.scan(/[^#{@look_for}]*/)
            if scanner.scan(/#{@look_for}/)
              # end of output reached
              scanner.terminate
              @busy = false
            end
          end
        end
      end
      chunk = output.force_encoding('UTF-8')
      if @current_funnel && !chunk.empty?
        # nokogiri may be confused about those unclosed <p> tags
        # sqlplus emits, so it's better to get rid of them and use
        # <br> instead. 
        @current_funnel.write(br_only(chunk))
        chunk = @current_funnel.read
      end
      return chunk
    end

    # Cancel the currently executing statement. This is supported on Unix
    # only. On Windows there's no way to send a CTRL+C signal to Sqlplus
    # without aborting the process. There's an old enhancement request on 
    # Oracle support: 
    #
    # Bug 8890996: ENH: CONTROL-C SHOULD NOT EXIT WINDOWS CONSOLE SQLPLUS
    #
    # So, as soon as we have some fixes from the Oracle guys I will come
    # back to this method.
    def cancel
      raise PlatformNotSupported if ChildProcess.windows?
      if busy?
        @process.send_signal 'INT'
        mark_cancel
        # read until the cancel marker
        raw_output = ""
        until raw_output =~ /#{@cancel_marker}/
          begin
            raw_output = @io_read.read_nonblock(1024)
          rescue Errno::EAGAIN
            sleep 0.1
          end
          yield if block_given?
        end
        @busy = false
      end
    end

    # Kill the sqlplus process.
    def terminate
      @process.stop
    end

    private

    def br_only(chunk)
      # be prepared for chunks with <p> tag broken in the middle
      chunk.gsub(/<p>/, "<br>").gsub(/<p\z/, "<br").gsub(/\Ap>/, "br>")
    end

    def prepare_funnel(convertor_name)
      convertor = @registered_convertors[convertor_name]
      if convertor
        @current_funnel = Output::HTMLFunnel.new(convertor.new)
      else
        @current_funnel = nil
      end
    end

    def capture
      send_text("#pro #{@start_marker}\n")
      yield
      send_text("#{@end_marker}\n")
      send_text("#pro #{@end_marker}\n")

      # Once again with termout enforced
      send_text("set termout on\n")
      send_text("#{@end_marker}\n")
      send_text("#pro #{@end_marker}\n")
    end

    def mark_cancel
      @process.io.stdin.puts
      @process.io.stdin.puts("set termout on")
      @process.io.stdin.puts("pro #{@cancel_marker}")
    end

    def pack(command, opts)
      pack_file = opts[:pack_file]
      if pack_file
        File.open(pack_file, 'wb') do |f|
          f.puts opts[:prep]
          f.puts "#pro #@start_marker"
          f.puts command.strip
          # we assume that the @end_marker is also
          # set as a block terminator. If "set echo on"
          # the output region will end here since the
          # block terminator command will be echoed. Otherwise,
          # the next prompt statement will do the job.
          f.puts "#{@end_marker}"
          f.puts "#pro #@end_marker"
          
          # once again with termout enforced
          f.puts("set termout on")
          f.puts "#{@end_marker}"
          f.puts "#pro #@end_marker"
          f.puts opts[:post]
        end
      end
      Vorax.debug("pack_file #{pack_file}:\n#{File.open(pack_file, 'rb') { |f| f.read }}")
      pack_file
    end


  end

end
