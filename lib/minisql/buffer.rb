module MiniSQL

  class Buffer

    def initialize file, block_size = nil
      @file = File.open(file, File::RDWR|File::CREAT).binmode
      @block_size = block_size || 4096
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
      fail unless num*block_size == file.pos
      file.write content
      file.flush
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
      if to_grow >= 0
        file.seek 0, IO::SEEK_END
        to_grow.times do
          file.write "\0" * block_size
        end
      else
        file.seek num * block_size
      end
    end

  end

  class CachedBuffer < Buffer

    CACHED_PAGES = 15

    def initialize file, block_size = nil
      super(file, block_size)
      @cache = {}
      @queue = []
    end

    def get_block num
      return @cache[num] if @cache.has_key?(num)
      add_cache(num, super(num))
    end

    def set_block num, content
      @cache[num] = content if @cache.has_key?(num)
      super(num,content)
    end

    protected

    def add_cache num, content
      @queue << num
      if @queue.size >= CACHED_PAGES
        @cache.delete(@queue.shift)
      end
      @cache[num] = content
    end

  end

end
