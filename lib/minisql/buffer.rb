module MiniSQL

  # currently mocked
  class Buffer

    def initialize file, block_size = 4096
      @file = File.open(file, 'a+b')
      @block_size = block_size
    end

    attr_reader :file, :block_size

    def get_block num
      check_file_size
      file.seek num * block_size
      file.read block_size # will return nil if beyond end of the file
    end

    def set_block num, content
      raise 'content must be multiples of block_size' unless content.size % block_size == 0
      grow_and_seek num
      file.write content
    end

    def close
      file.close
    end

    protected

    def check_file_size
      raise 'file size is not multiples of block_size, data corruption?' unless file.size % block_size == 0
    end

    def grow_and_seek num
      check_file_size
      to_grow = num - file.size / block_size
      if to_grow > 0
        file.seek 0, IO::SEEK_END
        to_grow.times do
          file.write "\0" * block_size
        end
      else
        file.seek num * block_size
      end
    end

  end

end
