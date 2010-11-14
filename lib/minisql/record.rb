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

    def delete_records cond
      all_records do |item, i|
        while cond[item]
          delete_record(i)
          break if i == size
          item = read_record(i)
        end
      end
    end

    def select_records func
      rst = []
      all_records do |item,_|
          rst << item if func[item]
      end
      rst
    end

    def update_record num, item
      raise "No such record: ##{num}" unless 0 <= num && num < size
      data = serialize item
      write_data data, num
    end

    def update_records cond, trans
      all_blocks do |block, i|
        changed = false
        records_in_block(block, i) do |item, j|
          if cond[item]
            item = trans[item]
            data = serialize item
            block[j*record_size, record_size] = data
            changed = true
          end
        end
        buffer.set_block(i, block) if changed
      end
    end

    protected

    def all_records
      all_blocks do |block,i|
        records_in_block(block, i) do |item,j|
          yield item, i*records_per_block+j
        end
      end
    end

    def all_blocks
      blocks_num = size / records_per_block
      (0...blocks_num).each do |i|
        yield buffer.get_block(i), i
      end
    end

    def records_in_block block, block_no
      records_num = [size-block_no*records_per_block, records_per_block].min
      (0...records_num).each do |i|
        data = block[i*record_size, record_size]
        item = deserialize data
        yield item, i
      end
    end

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
