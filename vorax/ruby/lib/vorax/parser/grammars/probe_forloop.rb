
# line 1 "lib/vorax/parser/grammars/probe_forloop.rl"

# line 23 "lib/vorax/parser/grammars/probe_forloop.rl"


module Vorax

  module Parser

		class ForRegion < Region

			def self.probe(data)
				@pointer, @variable, @cursor_var,  @expr, @variable = nil
				if data
					eof = data.length
					
# line 19 "lib/vorax/parser/grammars/probe_forloop.rb"
class << self
	attr_accessor :_probe_forloop_actions
	private :_probe_forloop_actions, :_probe_forloop_actions=
end
self._probe_forloop_actions = [
	0, 1, 0, 1, 1, 1, 3, 1, 
	4, 1, 6, 2, 2, 5
]

class << self
	attr_accessor :_probe_forloop_key_offsets
	private :_probe_forloop_key_offsets, :_probe_forloop_key_offsets=
end
self._probe_forloop_key_offsets = [
	0, 0, 2, 4, 6, 11, 32, 33, 
	38, 45, 46, 47, 48, 49, 51, 53, 
	59, 77, 78, 84, 91, 92, 93, 94, 
	95, 97, 99, 101, 103, 108, 109, 110, 
	111, 112, 114, 122, 123, 129, 137, 138, 
	143, 157, 172, 187, 188, 189, 190, 191, 
	193, 201, 207, 208, 209, 210, 217, 218, 
	219, 220, 221, 223, 230, 231, 232, 234, 
	251, 268, 285, 302, 319, 336, 351, 358, 
	359, 360, 361, 362, 364, 378, 379, 380, 
	381, 382, 384, 400, 416, 425, 441, 457, 
	473, 489, 505, 521, 537, 553, 569, 585
]

class << self
	attr_accessor :_probe_forloop_trans_keys
	private :_probe_forloop_trans_keys, :_probe_forloop_trans_keys=
end
self._probe_forloop_trans_keys = [
	70, 102, 79, 111, 82, 114, 32, 45, 
	47, 9, 13, 32, 34, 45, 47, 70, 
	73, 76, 82, 95, 102, 105, 108, 114, 
	9, 13, 35, 36, 65, 90, 97, 122, 
	34, 32, 45, 47, 9, 13, 32, 45, 
	47, 73, 105, 9, 13, 45, 10, 42, 
	42, 42, 47, 78, 110, 32, 40, 45, 
	47, 9, 13, 32, 34, 40, 45, 47, 
	82, 95, 114, 9, 13, 35, 36, 48, 
	57, 65, 90, 97, 122, 34, 32, 45, 
	46, 47, 9, 13, 32, 45, 47, 76, 
	108, 9, 13, 45, 10, 42, 42, 42, 
	47, 79, 111, 79, 111, 80, 112, 32, 
	45, 47, 9, 13, 45, 10, 42, 42, 
	42, 47, 34, 95, 35, 36, 65, 90, 
	97, 122, 34, 32, 45, 46, 47, 9, 
	13, 34, 95, 35, 36, 65, 90, 97, 
	122, 34, 32, 45, 47, 9, 13, 32, 
	45, 47, 95, 9, 13, 35, 36, 48, 
	57, 65, 90, 97, 122, 32, 45, 46, 
	47, 95, 9, 13, 35, 36, 48, 57, 
	65, 90, 97, 122, 32, 45, 46, 47, 
	95, 9, 13, 35, 36, 48, 57, 65, 
	90, 97, 122, 45, 10, 42, 42, 42, 
	47, 32, 45, 46, 47, 9, 13, 48, 
	57, 32, 45, 46, 47, 9, 13, 45, 
	10, 46, 32, 45, 47, 9, 13, 48, 
	57, 45, 10, 42, 42, 42, 47, 32, 
	45, 47, 9, 13, 48, 57, 42, 42, 
	42, 47, 32, 45, 46, 47, 69, 95, 
	101, 9, 13, 35, 36, 48, 57, 65, 
	90, 97, 122, 32, 45, 46, 47, 86, 
	95, 118, 9, 13, 35, 36, 48, 57, 
	65, 90, 97, 122, 32, 45, 46, 47, 
	69, 95, 101, 9, 13, 35, 36, 48, 
	57, 65, 90, 97, 122, 32, 45, 46, 
	47, 82, 95, 114, 9, 13, 35, 36, 
	48, 57, 65, 90, 97, 122, 32, 45, 
	46, 47, 83, 95, 115, 9, 13, 35, 
	36, 48, 57, 65, 90, 97, 122, 32, 
	45, 46, 47, 69, 95, 101, 9, 13, 
	35, 36, 48, 57, 65, 90, 97, 122, 
	32, 45, 46, 47, 95, 9, 13, 35, 
	36, 48, 57, 65, 90, 97, 122, 32, 
	45, 47, 9, 13, 48, 57, 45, 10, 
	42, 42, 42, 47, 32, 45, 47, 95, 
	9, 13, 35, 36, 48, 57, 65, 90, 
	97, 122, 45, 10, 42, 42, 42, 47, 
	32, 45, 47, 79, 95, 111, 9, 13, 
	35, 36, 48, 57, 65, 90, 97, 122, 
	32, 45, 47, 82, 95, 114, 9, 13, 
	35, 36, 48, 57, 65, 90, 97, 122, 
	95, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 78, 95, 110, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 79, 95, 111, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 79, 95, 111, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 80, 95, 112, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 69, 95, 101, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 86, 95, 118, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 69, 95, 101, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 82, 95, 114, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 83, 95, 115, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 69, 95, 101, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 32, 45, 47, 9, 13, 0
]

class << self
	attr_accessor :_probe_forloop_single_lengths
	private :_probe_forloop_single_lengths, :_probe_forloop_single_lengths=
end
self._probe_forloop_single_lengths = [
	0, 2, 2, 2, 3, 13, 1, 3, 
	5, 1, 1, 1, 1, 2, 2, 4, 
	8, 1, 4, 5, 1, 1, 1, 1, 
	2, 2, 2, 2, 3, 1, 1, 1, 
	1, 2, 2, 1, 4, 2, 1, 3, 
	4, 5, 5, 1, 1, 1, 1, 2, 
	4, 4, 1, 1, 1, 3, 1, 1, 
	1, 1, 2, 3, 1, 1, 2, 7, 
	7, 7, 7, 7, 7, 5, 3, 1, 
	1, 1, 1, 2, 4, 1, 1, 1, 
	1, 2, 6, 6, 1, 6, 6, 6, 
	6, 6, 6, 6, 6, 6, 6, 3
]

class << self
	attr_accessor :_probe_forloop_range_lengths
	private :_probe_forloop_range_lengths, :_probe_forloop_range_lengths=
end
self._probe_forloop_range_lengths = [
	0, 0, 0, 0, 1, 4, 0, 1, 
	1, 0, 0, 0, 0, 0, 0, 1, 
	5, 0, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 3, 0, 1, 3, 0, 1, 
	5, 5, 5, 0, 0, 0, 0, 0, 
	2, 1, 0, 0, 0, 2, 0, 0, 
	0, 0, 0, 2, 0, 0, 0, 5, 
	5, 5, 5, 5, 5, 5, 2, 0, 
	0, 0, 0, 0, 5, 0, 0, 0, 
	0, 0, 5, 5, 4, 5, 5, 5, 
	5, 5, 5, 5, 5, 5, 5, 1
]

class << self
	attr_accessor :_probe_forloop_index_offsets
	private :_probe_forloop_index_offsets, :_probe_forloop_index_offsets=
end
self._probe_forloop_index_offsets = [
	0, 0, 3, 6, 9, 14, 32, 34, 
	39, 46, 48, 50, 52, 54, 57, 60, 
	66, 80, 82, 88, 95, 97, 99, 101, 
	103, 106, 109, 112, 115, 120, 122, 124, 
	126, 128, 131, 137, 139, 145, 151, 153, 
	158, 168, 179, 190, 192, 194, 196, 198, 
	201, 208, 214, 216, 218, 220, 226, 228, 
	230, 232, 234, 237, 243, 245, 247, 250, 
	263, 276, 289, 302, 315, 328, 339, 345, 
	347, 349, 351, 353, 356, 366, 368, 370, 
	372, 374, 377, 389, 401, 407, 419, 431, 
	443, 455, 467, 479, 491, 503, 515, 527
]

class << self
	attr_accessor :_probe_forloop_indicies
	private :_probe_forloop_indicies, :_probe_forloop_indicies=
end
self._probe_forloop_indicies = [
	0, 0, 1, 2, 2, 1, 3, 3, 
	1, 4, 5, 6, 4, 1, 4, 7, 
	5, 6, 9, 10, 11, 12, 8, 9, 
	10, 11, 12, 4, 8, 8, 8, 1, 
	14, 13, 15, 16, 17, 15, 1, 18, 
	19, 20, 21, 21, 18, 1, 22, 1, 
	18, 22, 23, 1, 24, 23, 24, 18, 
	23, 25, 25, 1, 26, 27, 28, 29, 
	26, 1, 26, 30, 27, 28, 29, 33, 
	31, 33, 26, 31, 32, 31, 31, 1, 
	35, 34, 36, 37, 38, 39, 36, 1, 
	40, 41, 42, 43, 43, 40, 1, 44, 
	1, 40, 44, 45, 1, 46, 45, 46, 
	40, 45, 47, 47, 1, 48, 48, 1, 
	49, 49, 1, 50, 51, 52, 50, 1, 
	53, 1, 50, 53, 54, 1, 55, 54, 
	55, 50, 54, 56, 57, 57, 57, 57, 
	1, 58, 56, 36, 37, 59, 39, 36, 
	1, 60, 61, 61, 61, 61, 1, 62, 
	60, 36, 37, 39, 36, 1, 36, 37, 
	39, 61, 36, 61, 61, 61, 61, 1, 
	36, 37, 59, 39, 57, 36, 57, 57, 
	57, 57, 1, 36, 37, 38, 39, 63, 
	36, 63, 63, 63, 63, 1, 64, 1, 
	26, 64, 65, 1, 66, 65, 66, 26, 
	65, 67, 68, 69, 70, 67, 32, 1, 
	67, 68, 69, 70, 67, 1, 71, 1, 
	67, 71, 72, 1, 72, 73, 74, 72, 
	75, 1, 76, 1, 72, 76, 77, 1, 
	78, 77, 78, 72, 77, 40, 41, 42, 
	40, 75, 1, 79, 1, 80, 79, 80, 
	67, 79, 36, 37, 38, 39, 81, 63, 
	81, 36, 63, 63, 63, 63, 1, 36, 
	37, 38, 39, 82, 63, 82, 36, 63, 
	63, 63, 63, 1, 36, 37, 38, 39, 
	83, 63, 83, 36, 63, 63, 63, 63, 
	1, 36, 37, 38, 39, 84, 63, 84, 
	36, 63, 63, 63, 63, 1, 36, 37, 
	38, 39, 85, 63, 85, 36, 63, 63, 
	63, 63, 1, 36, 37, 38, 39, 86, 
	63, 86, 36, 63, 63, 63, 63, 1, 
	87, 88, 38, 89, 63, 87, 63, 63, 
	63, 63, 1, 87, 88, 89, 87, 32, 
	1, 90, 1, 87, 90, 91, 1, 92, 
	91, 92, 87, 91, 15, 16, 17, 93, 
	15, 93, 93, 93, 93, 1, 94, 1, 
	4, 94, 95, 1, 96, 95, 96, 4, 
	95, 15, 16, 17, 97, 93, 97, 15, 
	93, 93, 93, 93, 1, 15, 16, 17, 
	98, 93, 98, 15, 93, 93, 93, 93, 
	1, 93, 93, 93, 93, 93, 1, 15, 
	16, 17, 98, 93, 98, 15, 93, 93, 
	93, 93, 1, 15, 16, 17, 99, 93, 
	99, 15, 93, 93, 93, 93, 1, 15, 
	16, 17, 100, 93, 100, 15, 93, 93, 
	93, 93, 1, 15, 16, 17, 98, 93, 
	98, 15, 93, 93, 93, 93, 1, 15, 
	16, 17, 101, 93, 101, 15, 93, 93, 
	93, 93, 1, 15, 16, 17, 102, 93, 
	102, 15, 93, 93, 93, 93, 1, 15, 
	16, 17, 103, 93, 103, 15, 93, 93, 
	93, 93, 1, 15, 16, 17, 104, 93, 
	104, 15, 93, 93, 93, 93, 1, 15, 
	16, 17, 105, 93, 105, 15, 93, 93, 
	93, 93, 1, 15, 16, 17, 98, 93, 
	98, 15, 93, 93, 93, 93, 1, 50, 
	51, 52, 50, 1, 0
]

class << self
	attr_accessor :_probe_forloop_trans_targs
	private :_probe_forloop_trans_targs, :_probe_forloop_trans_targs=
end
self._probe_forloop_trans_targs = [
	2, 0, 3, 4, 5, 77, 79, 6, 
	76, 82, 85, 86, 89, 6, 7, 8, 
	9, 11, 8, 9, 11, 14, 10, 12, 
	13, 15, 16, 19, 43, 45, 17, 42, 
	48, 63, 17, 18, 19, 20, 34, 22, 
	19, 20, 22, 25, 21, 23, 24, 26, 
	27, 28, 95, 29, 31, 30, 32, 33, 
	35, 41, 36, 37, 38, 40, 39, 42, 
	44, 46, 47, 49, 50, 52, 60, 51, 
	53, 54, 56, 59, 55, 57, 58, 61, 
	62, 64, 65, 66, 67, 68, 69, 70, 
	71, 73, 72, 74, 75, 76, 78, 80, 
	81, 83, 84, 87, 88, 90, 91, 92, 
	93, 94
]

class << self
	attr_accessor :_probe_forloop_trans_actions
	private :_probe_forloop_trans_actions, :_probe_forloop_trans_actions=
end
self._probe_forloop_trans_actions = [
	0, 0, 0, 0, 0, 0, 0, 3, 
	3, 3, 3, 3, 3, 0, 0, 11, 
	11, 11, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 5, 5, 
	0, 5, 0, 0, 7, 7, 0, 7, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 9, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0
]

class << self
	attr_accessor :probe_forloop_start
end
self.probe_forloop_start = 1;
class << self
	attr_accessor :probe_forloop_first_final
end
self.probe_forloop_first_final = 95;
class << self
	attr_accessor :probe_forloop_error
end
self.probe_forloop_error = 0;

class << self
	attr_accessor :probe_forloop_en_for_stmt
end
self.probe_forloop_en_for_stmt = 1;


# line 36 "lib/vorax/parser/grammars/probe_forloop.rl"
					
# line 323 "lib/vorax/parser/grammars/probe_forloop.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = probe_forloop_start
end

# line 37 "lib/vorax/parser/grammars/probe_forloop.rl"
					
# line 332 "lib/vorax/parser/grammars/probe_forloop.rb"
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
	_keys = _probe_forloop_key_offsets[cs]
	_trans = _probe_forloop_index_offsets[cs]
	_klen = _probe_forloop_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _probe_forloop_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _probe_forloop_trans_keys[_mid]
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
	  _klen = _probe_forloop_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _probe_forloop_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _probe_forloop_trans_keys[_mid+1]
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
	_trans = _probe_forloop_indicies[_trans]
	cs = _probe_forloop_trans_targs[_trans]
	if _probe_forloop_trans_actions[_trans] != 0
		_acts = _probe_forloop_trans_actions[_trans]
		_nacts = _probe_forloop_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _probe_forloop_actions[_acts - 1]
when 0 then
# line 7 "lib/vorax/parser/grammars/probe_forloop.rl"
		begin

  @expr = Parser.walk_balanced_paren(data[(p..-1)])
  p += @expr.length - 1
		end
when 1 then
# line 14 "lib/vorax/parser/grammars/probe_forloop.rl"
		begin
@start = p; @var_pos = p		end
when 2 then
# line 14 "lib/vorax/parser/grammars/probe_forloop.rl"
		begin
@end = p - 1		end
when 3 then
# line 20 "lib/vorax/parser/grammars/probe_forloop.rl"
		begin
@start = p		end
when 4 then
# line 20 "lib/vorax/parser/grammars/probe_forloop.rl"
		begin
@cursor_var = data[@start..p-1]		end
when 5 then
# line 21 "lib/vorax/parser/grammars/probe_forloop.rl"
		begin
@variable = data[@start..@end]		end
when 6 then
# line 21 "lib/vorax/parser/grammars/probe_forloop.rl"
		begin
@pointer = p		end
# line 444 "lib/vorax/parser/grammars/probe_forloop.rb"
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

# line 38 "lib/vorax/parser/grammars/probe_forloop.rl"
				end
				if @pointer
					return {:variable => @variable,
					        :variable_position => @var_pos,
									:domain_type => (@expr ? :expr : (@cursor_var ? :cursor_var : :counter)),
									:domain => (@expr ? @expr : (@cursor_var ? @cursor_var : nil)),
									:pointer => @pointer}
			  else
					return {:variable => nil, :domain_type => nil, :domain => nil, :pointer => nil, :variable_position => nil}
			 	end
			end

		end

  end

end
