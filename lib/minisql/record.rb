require 'minisql/buffer'

module MiniSQL

  class Record

    def initialize table_info, buffer, update_table_callback
      @table = table_info
      @columns = columns
      @table[:size] = 0 unless @table[:size]
      @pack_string = get_pack_string
      @record_size = get_record_size

      @buffer = buffer
      @block_size = buffer.block_size
      @records_per_block = @block_size / @record_size

      @update_table = update_table_callback
    end

    attr_reader :record_size

    def serialize item
      item.pack(pack_string)
    end

    def deserialize data
      data.unpack(pack_string)
    end

    def size
      table[:size]
    end

    def get_record_size
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

    def insert_record item
      data = serialize(item)
      self.size+=1
      write_data data, size-1
    end

    def read_record num
      raise "No such record: ##{num}" unless 0 <= num && num < size
      data = read_data num
      deserialize data
    end

    def delete_record num
      raise "No such record: ##{num}" unless 0 <= num && num < size
      self.size-=1
      return if num == self.size
      data = read_data self.size
      write_data data, num
    end

    def update_record num, item
      raise "No such record: ##{num}" unless 0 <= num && num < size
      data = serialize item
      write_data data, num
    end

    def select_records func
      rst = []
      blocks_num = size / records_per_block
      (0...blocks_num).each do |i|
         block = buffer.get_block(i)
         records_num = [size-i*records_per_block, records_per_block].min
         (0...records_num).each do |j|
           data = block[j*record_size, record_size]
           item = deserialize data
           rst << item if func[item]
         end
      end
      rst
    end

    protected

    attr_reader :pack_string, :records_per_block, :block_size
    attr_reader :buffer, :table

    def columns
      table[:columns]
    end

    def size= value
      table[:size]=value
      @update_table[table]
    end

    def read_data num
      block = buffer.get_block(num / records_per_block)
      block[num % records_per_block * record_size, record_size]
    end

    def write_data data, num
      raise "No such record: ##{num}" unless 0 <= num && num < size
      block_number = num / records_per_block
      block = buffer.get_block(block_number)
      block = "\0"*block_size if not block
      block[num % records_per_block * record_size, record_size] = data
      buffer.set_block(block_number, block)
    end

   def get_pack_string
      rst = ''
      @columns.each do |col|
        rst <<
        case col[:type]
        when :int then 'N'
        when :float then 'g'
        when :char then "a#{col[:length]}"
        end
      end
      rst
    end

  end

end
