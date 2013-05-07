# encoding: UTF-8

module Vorax

  # Implements an IO pipe to link the stdin and stdout handlers of the
  # sqlplus process to the ends of this pipe. This is required for Windows
  # processes only. On Unix it's enough to use a builtin IO object.
  class VoraxIO < IO

    # A proxy for the original read_nonblock method
    alias :old_read_nonblock :read_nonblock

    # Creates a new IO.
    def initialize(*args)
      super(*args)
      if ChildProcess.windows?
        require 'Win32API'
        @hFile = ChildProcess::Windows::Lib.get_osfhandle(fileno)
        peek_params = [
          'L', # handle to pipe to copy from
          'L', # pointer to data buffer
          'L', # size, in bytes, of data buffer
          'L', # pointer to number of bytes read
          'P', # pointer to total number of bytes available
          'L'] # pointer to unread bytes in this message
        @peekNamedPipe = Win32API.new("kernel32", "PeekNamedPipe", peek_params, 'I')
        read_params = [
            'L', # handle of file to read
            'P', # pointer to buffer that receives data
            'L', # number of bytes to read
            'P', # pointer to number of bytes read
            'L'] #pointer to structure for data
        @readFile = Win32API.new("kernel32", "ReadFile", read_params, 'I')
      end
    end

    # Read in nonblock mode from the pipe.
    #
    # @param bytes [int] the number of bytes to be read at once
    # @see IO.read_nonblock
    def read_nonblock(bytes)
      if ChildProcess.windows?
        read_file(peek)
      else
        old_read_nonblock(bytes)
      end
    end

    private

    def peek
      available = [0].pack('I')
      if @peekNamedPipe.Call(@hFile, 0, 0, 0, available, 0).zero?
        raise IOError, 'Named pipe unavailable'
      end
      available.unpack('I')[0]
    end

    def read_file(bytes)
      if bytes > 0
        number = [0].pack('I')
        buffer = ' ' * bytes
        return '' if @readFile.call(@hFile, buffer, bytes, number, 0).zero?
        buffer[0...number.unpack('I')[0]]
      end
    end

  end

end
