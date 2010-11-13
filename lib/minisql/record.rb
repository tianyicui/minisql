require 'minisql/buffer'

module MiniSQL

  class Record

    def initialize table_info, buffer, update_table_callback
      @table = table_info
      @table[:size] = 0 unless @table[:size]
      @pack_string = pack_string
      @record_size = record_size

      @buffer = buffer
      @block_size = buffer.block_size
      @records_in_block = block_size / record_size

      @update_table = update_table_callback
    end

    def size
      @table[:size]
    end

    def size= value
      @table[:size]=value
      @update_table.call(@table)
    end

    def record_size
      result = 0
      columns.each do |col|
        result +=
          case col[:type]
          when :int then 4
          when :float then 4
          when :char then col[:length]
          end
      end
      result
    end

    def columns
      @table[:column]
    end

    def insert_record item
      data = serialize(item)
      write_data data, @size
      size += 1
    end

    def read_record num
      raise "No such record: ##{num}" unless 0 <= num && num < size
      block = buffer.get_block(num / @records_in_block)
      data = block[num % @records_in_block, @record_size]
      deserialize data
    end

    def serialize item
      item.pack(@pack_string)
    end

    def deserialize data
      data.unpack(@pack_string)
    end

    def pack_string
      rst = ''
      columns.each do |col|
        rst <<
        case col[:type]
        when :int then 'N'
        when :float then 'G'
        when :char then "a#{col[:length]}"
        end
      end
      rst
    end

  end

end
