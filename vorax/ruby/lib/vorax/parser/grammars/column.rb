
# line 1 "lib/vorax/parser/grammars/column.rl"

# line 32 "lib/vorax/parser/grammars/column.rl"


module Vorax

  module Parser

    # An abstraction for SQL columns.
    class Column

      # Given a statement, it walks it in search for a column list. If the statement
      # contains more than one query, the first defined list is returned.
      #
      # @param data the statement to be walked
      # @return the string with the column list
      def walk(data)
        @columns = []
        if data
          data << ","
          eof = data.length
          
# line 26 "lib/vorax/parser/grammars/column.rb"
class << self
	attr_accessor :_column_actions
	private :_column_actions, :_column_actions=
end
self._column_actions = [
	0, 1, 1, 1, 2, 1, 3, 1, 
	7, 1, 9, 1, 10, 1, 11, 1, 
	12, 1, 13, 1, 14, 1, 15, 2, 
	0, 8, 2, 3, 4, 2, 3, 5, 
	2, 3, 6
]

class << self
	attr_accessor :_column_key_offsets
	private :_column_key_offsets, :_column_key_offsets=
end
self._column_key_offsets = [
	0, 1, 7, 8, 9, 10, 11, 13, 
	22, 23, 30, 39, 40, 55, 71, 87, 
	88, 89, 90, 92, 105, 106, 113, 129, 
	130, 131, 137, 138
]

class << self
	attr_accessor :_column_trans_keys
	private :_column_trans_keys, :_column_trans_keys=
end
self._column_trans_keys = [
	34, 32, 44, 45, 47, 9, 13, 45, 
	10, 42, 42, 42, 47, 34, 42, 95, 
	35, 36, 65, 90, 97, 122, 34, 32, 
	44, 45, 46, 47, 9, 13, 34, 42, 
	95, 35, 36, 65, 90, 97, 122, 34, 
	32, 44, 45, 47, 95, 9, 13, 35, 
	36, 48, 57, 65, 90, 97, 122, 32, 
	44, 45, 46, 47, 95, 9, 13, 35, 
	36, 48, 57, 65, 90, 97, 122, 32, 
	44, 45, 46, 47, 95, 9, 13, 35, 
	36, 48, 57, 65, 90, 97, 122, 39, 
	10, 42, 42, 47, 34, 39, 40, 42, 
	45, 47, 95, 35, 36, 65, 90, 97, 
	122, 34, 32, 44, 45, 46, 47, 9, 
	13, 32, 44, 45, 46, 47, 95, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 39, 39, 32, 44, 45, 47, 9, 
	13, 45, 42, 0
]

class << self
	attr_accessor :_column_single_lengths
	private :_column_single_lengths, :_column_single_lengths=
end
self._column_single_lengths = [
	1, 4, 1, 1, 1, 1, 2, 3, 
	1, 5, 3, 1, 5, 6, 6, 1, 
	1, 1, 2, 7, 1, 5, 6, 1, 
	1, 4, 1, 1
]

class << self
	attr_accessor :_column_range_lengths
	private :_column_range_lengths, :_column_range_lengths=
end
self._column_range_lengths = [
	0, 1, 0, 0, 0, 0, 0, 3, 
	0, 1, 3, 0, 5, 5, 5, 0, 
	0, 0, 0, 3, 0, 1, 5, 0, 
	0, 1, 0, 0
]

class << self
	attr_accessor :_column_index_offsets
	private :_column_index_offsets, :_column_index_offsets=
end
self._column_index_offsets = [
	0, 2, 8, 10, 12, 14, 16, 19, 
	26, 28, 35, 42, 44, 55, 67, 79, 
	81, 83, 85, 88, 99, 101, 108, 120, 
	122, 124, 130, 132
]

class << self
	attr_accessor :_column_indicies
	private :_column_indicies, :_column_indicies=
end
self._column_indicies = [
	2, 1, 4, 5, 6, 7, 4, 3, 
	8, 3, 4, 8, 9, 3, 10, 9, 
	10, 4, 9, 11, 4, 12, 12, 12, 
	12, 3, 13, 11, 4, 5, 6, 14, 
	7, 4, 3, 15, 4, 16, 16, 16, 
	16, 3, 4, 15, 4, 5, 6, 7, 
	16, 4, 16, 16, 16, 16, 3, 4, 
	5, 6, 14, 7, 12, 4, 12, 12, 
	12, 12, 3, 4, 5, 6, 18, 7, 
	17, 4, 17, 17, 17, 17, 0, 20, 
	19, 22, 21, 24, 23, 24, 22, 23, 
	26, 28, 29, 30, 31, 32, 27, 27, 
	27, 27, 25, 2, 1, 4, 5, 6, 
	18, 7, 4, 34, 4, 5, 6, 18, 
	7, 17, 4, 17, 17, 17, 17, 33, 
	20, 19, 19, 35, 4, 5, 6, 7, 
	4, 33, 21, 33, 23, 33, 0
]

class << self
	attr_accessor :_column_trans_targs
	private :_column_trans_targs, :_column_trans_targs=
end
self._column_trans_targs = [
	19, 0, 21, 19, 1, 19, 2, 4, 
	3, 5, 6, 8, 13, 9, 10, 11, 
	12, 14, 7, 15, 24, 16, 19, 17, 
	18, 19, 20, 22, 23, 19, 25, 26, 
	27, 19, 19, 19
]

class << self
	attr_accessor :_column_trans_actions
	private :_column_trans_actions, :_column_trans_actions=
end
self._column_trans_actions = [
	19, 0, 29, 21, 0, 9, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 26, 0, 7, 0, 
	0, 11, 5, 32, 32, 23, 32, 5, 
	5, 17, 15, 13
]

class << self
	attr_accessor :_column_to_state_actions
	private :_column_to_state_actions, :_column_to_state_actions=
end
self._column_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_column_from_state_actions
	private :_column_from_state_actions, :_column_from_state_actions=
end
self._column_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 3, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_column_eof_trans
	private :_column_eof_trans, :_column_eof_trans=
end
self._column_eof_trans = [
	1, 4, 4, 4, 4, 4, 4, 4, 
	4, 4, 4, 4, 4, 4, 1, 4, 
	1, 1, 1, 0, 34, 35, 34, 34, 
	36, 34, 34, 34
]

class << self
	attr_accessor :column_start
end
self.column_start = 19;
class << self
	attr_accessor :column_first_final
end
self.column_first_final = 19;
class << self
	attr_accessor :column_error
end
self.column_error = -1;

class << self
	attr_accessor :column_en_main
end
self.column_en_main = 19;


# line 52 "lib/vorax/parser/grammars/column.rl"
          
# line 210 "lib/vorax/parser/grammars/column.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = column_start
	ts = nil
	te = nil
	act = 0
end

# line 53 "lib/vorax/parser/grammars/column.rl"
          
# line 222 "lib/vorax/parser/grammars/column.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	end
	if _goto_level <= _resume
	_acts = _column_from_state_actions[cs]
	_nacts = _column_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _column_actions[_acts - 1]
			when 2 then
# line 1 "NONE"
		begin
ts = p
		end
# line 252 "lib/vorax/parser/grammars/column.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _column_key_offsets[cs]
	_trans = _column_index_offsets[cs]
	_klen = _column_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _column_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _column_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _column_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _column_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _column_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	_trans = _column_indicies[_trans]
	end
	if _goto_level <= _eof_trans
	cs = _column_trans_targs[_trans]
	if _column_trans_actions[_trans] != 0
		_acts = _column_trans_actions[_trans]
		_nacts = _column_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _column_actions[_acts - 1]
when 0 then
# line 5 "lib/vorax/parser/grammars/column.rl"
		begin

  expr = Parser.walk_balanced_paren(data[(p..-1)])
  p += expr.length
  te = p
		end
when 3 then
# line 1 "NONE"
		begin
te = p+1
		end
when 4 then
# line 24 "lib/vorax/parser/grammars/column.rl"
		begin
act = 1;		end
when 5 then
# line 25 "lib/vorax/parser/grammars/column.rl"
		begin
act = 2;		end
when 6 then
# line 29 "lib/vorax/parser/grammars/column.rl"
		begin
act = 6;		end
when 7 then
# line 26 "lib/vorax/parser/grammars/column.rl"
		begin
te = p+1
		end
when 8 then
# line 27 "lib/vorax/parser/grammars/column.rl"
		begin
te = p+1
		end
when 9 then
# line 28 "lib/vorax/parser/grammars/column.rl"
		begin
te = p+1
 begin  @columns << data[(ts..te)].gsub(/\s*,\s*$/, '')  end
		end
when 10 then
# line 29 "lib/vorax/parser/grammars/column.rl"
		begin
te = p+1
		end
when 11 then
# line 24 "lib/vorax/parser/grammars/column.rl"
		begin
te = p
p = p - 1;		end
when 12 then
# line 25 "lib/vorax/parser/grammars/column.rl"
		begin
te = p
p = p - 1;		end
when 13 then
# line 29 "lib/vorax/parser/grammars/column.rl"
		begin
te = p
p = p - 1;		end
when 14 then
# line 29 "lib/vorax/parser/grammars/column.rl"
		begin
 begin p = ((te))-1; end
		end
when 15 then
# line 1 "NONE"
		begin
	case act
	when 6 then
	begin begin p = ((te))-1; end
end
	else
	begin begin p = ((te))-1; end
end
end 
			end
# line 397 "lib/vorax/parser/grammars/column.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _column_to_state_actions[cs]
	_nacts = _column_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _column_actions[_acts - 1]
when 1 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 417 "lib/vorax/parser/grammars/column.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _column_eof_trans[cs] > 0
		_trans = _column_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 54 "lib/vorax/parser/grammars/column.rl"
          data.chop!
        end
        return @columns
      end

    end

  end

end

