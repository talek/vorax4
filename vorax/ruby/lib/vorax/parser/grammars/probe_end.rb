
# line 1 "lib/vorax/parser/grammars/probe_end.rl"

# line 14 "lib/vorax/parser/grammars/probe_end.rl"


module Vorax

  module Parser

    class Region

      # Tries to figure out the type of the end marker.
      # @param data [String] the PLSQL code to be checked
      # @return [Hash] with the following keys: :kind => :end, :end_loop, :end_if
      #   :pointer => where the "end" definition ends.
      # @example
      #   text = 'end if;'
      #   p Parser::Region.probe_end(text)
			def self.probe_end(data)
				@kind, @pointer = nil
				if data
					eof = data.length
					
# line 26 "lib/vorax/parser/grammars/probe_end.rb"
class << self
	attr_accessor :_probe_end_actions
	private :_probe_end_actions, :_probe_end_actions=
end
self._probe_end_actions = [
	0, 1, 0, 1, 1, 1, 2
]

class << self
	attr_accessor :_probe_end_key_offsets
	private :_probe_end_key_offsets, :_probe_end_key_offsets=
end
self._probe_end_key_offsets = [
	0, 0, 2, 4, 6, 16, 34, 35, 
	41, 42, 43, 44, 45, 47, 62, 63, 
	64, 65, 66, 68, 85, 100, 106, 107, 
	108, 109, 110, 112, 129, 146, 163, 178, 
	184, 185, 186, 187, 188, 190, 192, 194, 
	196, 198
]

class << self
	attr_accessor :_probe_end_trans_keys
	private :_probe_end_trans_keys, :_probe_end_trans_keys=
end
self._probe_end_trans_keys = [
	69, 101, 78, 110, 68, 100, 32, 45, 
	47, 59, 73, 76, 105, 108, 9, 13, 
	32, 34, 45, 47, 59, 73, 76, 95, 
	105, 108, 9, 13, 35, 36, 65, 90, 
	97, 122, 34, 32, 45, 47, 59, 9, 
	13, 45, 10, 42, 42, 42, 47, 32, 
	45, 47, 59, 95, 9, 13, 35, 36, 
	48, 57, 65, 90, 97, 122, 45, 10, 
	42, 42, 42, 47, 32, 45, 47, 59, 
	70, 95, 102, 9, 13, 35, 36, 48, 
	57, 65, 90, 97, 122, 32, 45, 47, 
	59, 95, 9, 13, 35, 36, 48, 57, 
	65, 90, 97, 122, 32, 45, 47, 59, 
	9, 13, 45, 10, 42, 42, 42, 47, 
	32, 45, 47, 59, 79, 95, 111, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 59, 79, 95, 111, 
	9, 13, 35, 36, 48, 57, 65, 90, 
	97, 122, 32, 45, 47, 59, 80, 95, 
	112, 9, 13, 35, 36, 48, 57, 65, 
	90, 97, 122, 32, 45, 47, 59, 95, 
	9, 13, 35, 36, 48, 57, 65, 90, 
	97, 122, 32, 45, 47, 59, 9, 13, 
	45, 10, 42, 42, 42, 47, 70, 102, 
	79, 111, 79, 111, 80, 112, 0
]

class << self
	attr_accessor :_probe_end_single_lengths
	private :_probe_end_single_lengths, :_probe_end_single_lengths=
end
self._probe_end_single_lengths = [
	0, 2, 2, 2, 8, 10, 1, 4, 
	1, 1, 1, 1, 2, 5, 1, 1, 
	1, 1, 2, 7, 5, 4, 1, 1, 
	1, 1, 2, 7, 7, 7, 5, 4, 
	1, 1, 1, 1, 2, 2, 2, 2, 
	2, 0
]

class << self
	attr_accessor :_probe_end_range_lengths
	private :_probe_end_range_lengths, :_probe_end_range_lengths=
end
self._probe_end_range_lengths = [
	0, 0, 0, 0, 1, 4, 0, 1, 
	0, 0, 0, 0, 0, 5, 0, 0, 
	0, 0, 0, 5, 5, 1, 0, 0, 
	0, 0, 0, 5, 5, 5, 5, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0
]

class << self
	attr_accessor :_probe_end_index_offsets
	private :_probe_end_index_offsets, :_probe_end_index_offsets=
end
self._probe_end_index_offsets = [
	0, 0, 3, 6, 9, 19, 34, 36, 
	42, 44, 46, 48, 50, 53, 64, 66, 
	68, 70, 72, 75, 88, 99, 105, 107, 
	109, 111, 113, 116, 129, 142, 155, 166, 
	172, 174, 176, 178, 180, 183, 186, 189, 
	192, 195
]

class << self
	attr_accessor :_probe_end_indicies
	private :_probe_end_indicies, :_probe_end_indicies=
end
self._probe_end_indicies = [
	0, 0, 1, 2, 2, 1, 3, 3, 
	1, 4, 5, 6, 7, 8, 9, 8, 
	9, 4, 1, 4, 10, 5, 6, 7, 
	12, 13, 11, 12, 13, 4, 11, 11, 
	11, 1, 14, 10, 14, 15, 16, 7, 
	14, 1, 17, 1, 14, 17, 18, 1, 
	19, 18, 19, 14, 18, 14, 15, 16, 
	7, 11, 14, 11, 11, 11, 11, 1, 
	20, 1, 4, 20, 21, 1, 22, 21, 
	22, 4, 21, 14, 15, 16, 7, 23, 
	11, 23, 14, 11, 11, 11, 11, 1, 
	24, 25, 26, 27, 11, 24, 11, 11, 
	11, 11, 1, 24, 25, 26, 27, 24, 
	1, 28, 1, 24, 28, 29, 1, 30, 
	29, 30, 24, 29, 14, 15, 16, 7, 
	31, 11, 31, 14, 11, 11, 11, 11, 
	1, 14, 15, 16, 7, 32, 11, 32, 
	14, 11, 11, 11, 11, 1, 14, 15, 
	16, 7, 33, 11, 33, 14, 11, 11, 
	11, 11, 1, 34, 35, 36, 37, 11, 
	34, 11, 11, 11, 11, 1, 34, 35, 
	36, 37, 34, 1, 38, 1, 34, 38, 
	39, 1, 40, 39, 40, 34, 39, 24, 
	24, 1, 41, 41, 1, 42, 42, 1, 
	34, 34, 1, 1, 0
]

class << self
	attr_accessor :_probe_end_trans_targs
	private :_probe_end_trans_targs, :_probe_end_trans_targs=
end
self._probe_end_trans_targs = [
	2, 0, 3, 4, 5, 14, 16, 41, 
	37, 38, 6, 13, 19, 27, 7, 8, 
	10, 9, 11, 12, 15, 17, 18, 20, 
	21, 22, 24, 41, 23, 25, 26, 28, 
	29, 30, 31, 32, 34, 41, 33, 35, 
	36, 39, 40
]

class << self
	attr_accessor :_probe_end_trans_actions
	private :_probe_end_trans_actions, :_probe_end_trans_actions=
end
self._probe_end_trans_actions = [
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 5, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 3, 0, 0, 
	0, 0, 0
]

class << self
	attr_accessor :probe_end_start
end
self.probe_end_start = 1;
class << self
	attr_accessor :probe_end_first_final
end
self.probe_end_first_final = 41;
class << self
	attr_accessor :probe_end_error
end
self.probe_end_error = 0;

class << self
	attr_accessor :probe_end_en_main
end
self.probe_end_en_main = 1;


# line 34 "lib/vorax/parser/grammars/probe_end.rl"
					
# line 198 "lib/vorax/parser/grammars/probe_end.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = probe_end_start
end

# line 35 "lib/vorax/parser/grammars/probe_end.rl"
					
# line 207 "lib/vorax/parser/grammars/probe_end.rb"
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
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _probe_end_key_offsets[cs]
	_trans = _probe_end_index_offsets[cs]
	_klen = _probe_end_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _probe_end_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _probe_end_trans_keys[_mid]
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
	  _klen = _probe_end_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _probe_end_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _probe_end_trans_keys[_mid+1]
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
	_trans = _probe_end_indicies[_trans]
	cs = _probe_end_trans_targs[_trans]
	if _probe_end_trans_actions[_trans] != 0
		_acts = _probe_end_trans_actions[_trans]
		_nacts = _probe_end_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _probe_end_actions[_acts - 1]
when 0 then
# line 8 "lib/vorax/parser/grammars/probe_end.rl"
		begin
@kind = :end; @pointer = p		end
when 1 then
# line 9 "lib/vorax/parser/grammars/probe_end.rl"
		begin
@kind = :end_loop; @pointer = p		end
when 2 then
# line 10 "lib/vorax/parser/grammars/probe_end.rl"
		begin
@kind = :end_if; @pointer = p		end
# line 300 "lib/vorax/parser/grammars/probe_end.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 36 "lib/vorax/parser/grammars/probe_end.rl"
				end
				{:kind => @kind, :pointer => @pointer}
			end

    end

  end

end
