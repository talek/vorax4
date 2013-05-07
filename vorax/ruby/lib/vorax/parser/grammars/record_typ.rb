
# line 1 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"

# line 34 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"


module Vorax

	module Parser

		def Parser.describe_record(data)
		  @attributes = []
		  if data
			  eof = data.length
        
# line 17 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rb"
class << self
	attr_accessor :_record_typ_actions
	private :_record_typ_actions, :_record_typ_actions=
end
self._record_typ_actions = [
	0, 1, 1, 1, 2, 1, 3, 1, 
	4, 1, 5, 1, 6, 1, 11, 1, 
	12, 1, 14, 1, 15, 1, 16, 1, 
	17, 1, 18, 1, 19, 2, 0, 13, 
	2, 2, 3, 2, 6, 7, 2, 6, 
	8, 2, 6, 9, 2, 6, 10, 4, 
	6, 2, 3, 9
]

class << self
	attr_accessor :_record_typ_key_offsets
	private :_record_typ_key_offsets, :_record_typ_key_offsets=
end
self._record_typ_key_offsets = [
	0, 9, 10, 11, 12, 13, 15, 17, 
	19, 21, 23, 25, 27, 32, 46, 47, 
	54, 60, 61, 62, 63, 64, 66, 74, 
	75, 82, 90, 91, 106, 122, 138, 139, 
	140, 141, 142, 144, 146, 151, 158, 159, 
	160, 161, 162, 164, 166, 168, 170, 172, 
	174, 180, 193, 194, 207, 220, 221, 222, 
	223, 224, 225, 227, 242, 243, 244, 245, 
	246, 248, 249, 250, 251, 252, 254, 255, 
	256, 269, 270, 271, 272, 273, 275, 276, 
	277, 279, 288, 297, 306, 321, 322, 323, 
	324, 337, 338, 339
]

class << self
	attr_accessor :_record_typ_trans_keys
	private :_record_typ_trans_keys, :_record_typ_trans_keys=
end
self._record_typ_trans_keys = [
	32, 45, 47, 68, 73, 100, 105, 9, 
	13, 45, 10, 42, 42, 42, 47, 69, 
	101, 70, 102, 65, 97, 85, 117, 76, 
	108, 84, 116, 32, 45, 47, 9, 13, 
	32, 34, 40, 45, 47, 95, 9, 13, 
	35, 36, 65, 90, 97, 122, 34, 32, 
	40, 45, 46, 47, 9, 13, 32, 40, 
	45, 47, 9, 13, 45, 10, 42, 42, 
	42, 47, 34, 95, 35, 36, 65, 90, 
	97, 122, 34, 32, 40, 45, 46, 47, 
	9, 13, 34, 95, 35, 36, 65, 90, 
	97, 122, 34, 32, 40, 45, 47, 95, 
	9, 13, 35, 36, 48, 57, 65, 90, 
	97, 122, 32, 40, 45, 46, 47, 95, 
	9, 13, 35, 36, 48, 57, 65, 90, 
	97, 122, 32, 40, 45, 46, 47, 95, 
	9, 13, 35, 36, 48, 57, 65, 90, 
	97, 122, 45, 10, 42, 42, 42, 47, 
	83, 115, 32, 45, 47, 9, 13, 32, 
	45, 47, 82, 114, 9, 13, 45, 10, 
	42, 42, 42, 47, 69, 101, 67, 99, 
	79, 111, 82, 114, 68, 100, 32, 40, 
	45, 47, 9, 13, 32, 34, 45, 47, 
	95, 9, 13, 35, 36, 65, 90, 97, 
	122, 34, 32, 34, 45, 47, 95, 9, 
	13, 35, 36, 65, 90, 97, 122, 32, 
	34, 45, 47, 95, 9, 13, 35, 36, 
	65, 90, 97, 122, 34, 45, 10, 42, 
	42, 42, 47, 32, 34, 45, 47, 95, 
	9, 13, 35, 36, 48, 57, 65, 90, 
	97, 122, 45, 10, 42, 42, 42, 47, 
	45, 10, 42, 42, 42, 47, 34, 39, 
	32, 34, 45, 47, 95, 9, 13, 35, 
	36, 65, 90, 97, 122, 45, 10, 42, 
	42, 42, 47, 10, 42, 42, 47, 32, 
	34, 39, 44, 45, 47, 58, 9, 13, 
	32, 45, 47, 68, 73, 100, 105, 9, 
	13, 95, 35, 36, 48, 57, 65, 90, 
	97, 122, 32, 34, 45, 47, 95, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 34, 39, 39, 32, 34, 45, 47, 
	95, 9, 13, 35, 36, 65, 90, 97, 
	122, 45, 42, 61, 0
]

class << self
	attr_accessor :_record_typ_single_lengths
	private :_record_typ_single_lengths, :_record_typ_single_lengths=
end
self._record_typ_single_lengths = [
	7, 1, 1, 1, 1, 2, 2, 2, 
	2, 2, 2, 2, 3, 6, 1, 5, 
	4, 1, 1, 1, 1, 2, 2, 1, 
	5, 2, 1, 5, 6, 6, 1, 1, 
	1, 1, 2, 2, 3, 5, 1, 1, 
	1, 1, 2, 2, 2, 2, 2, 2, 
	4, 5, 1, 5, 5, 1, 1, 1, 
	1, 1, 2, 5, 1, 1, 1, 1, 
	2, 1, 1, 1, 1, 2, 1, 1, 
	5, 1, 1, 1, 1, 2, 1, 1, 
	2, 7, 7, 1, 5, 1, 1, 1, 
	5, 1, 1, 1
]

class << self
	attr_accessor :_record_typ_range_lengths
	private :_record_typ_range_lengths, :_record_typ_range_lengths=
end
self._record_typ_range_lengths = [
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 4, 0, 1, 
	1, 0, 0, 0, 0, 0, 3, 0, 
	1, 3, 0, 5, 5, 5, 0, 0, 
	0, 0, 0, 0, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 4, 0, 4, 4, 0, 0, 0, 
	0, 0, 0, 5, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	4, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 4, 5, 0, 0, 0, 
	4, 0, 0, 0
]

class << self
	attr_accessor :_record_typ_index_offsets
	private :_record_typ_index_offsets, :_record_typ_index_offsets=
end
self._record_typ_index_offsets = [
	0, 9, 11, 13, 15, 17, 20, 23, 
	26, 29, 32, 35, 38, 43, 54, 56, 
	63, 69, 71, 73, 75, 77, 80, 86, 
	88, 95, 101, 103, 114, 126, 138, 140, 
	142, 144, 146, 149, 152, 157, 164, 166, 
	168, 170, 172, 175, 178, 181, 184, 187, 
	190, 196, 206, 208, 218, 228, 230, 232, 
	234, 236, 238, 241, 252, 254, 256, 258, 
	260, 263, 265, 267, 269, 271, 274, 276, 
	278, 288, 290, 292, 294, 296, 299, 301, 
	303, 306, 315, 324, 330, 341, 343, 345, 
	347, 357, 359, 361
]

class << self
	attr_accessor :_record_typ_indicies
	private :_record_typ_indicies, :_record_typ_indicies=
end
self._record_typ_indicies = [
	1, 2, 3, 4, 5, 4, 5, 1, 
	0, 6, 0, 1, 6, 7, 0, 8, 
	7, 8, 1, 7, 9, 9, 0, 10, 
	10, 0, 11, 11, 0, 12, 12, 0, 
	13, 13, 0, 14, 14, 0, 15, 16, 
	17, 15, 0, 15, 18, 20, 16, 17, 
	19, 15, 19, 19, 19, 0, 21, 18, 
	22, 20, 23, 24, 25, 22, 0, 22, 
	20, 23, 25, 22, 0, 26, 0, 22, 
	26, 27, 0, 28, 27, 28, 22, 27, 
	29, 30, 30, 30, 30, 0, 31, 29, 
	22, 20, 23, 32, 25, 22, 0, 33, 
	34, 34, 34, 34, 0, 22, 33, 22, 
	20, 23, 25, 34, 22, 34, 34, 34, 
	34, 0, 22, 20, 23, 32, 25, 30, 
	22, 30, 30, 30, 30, 0, 22, 20, 
	23, 24, 25, 19, 22, 19, 19, 19, 
	19, 0, 35, 0, 15, 35, 36, 0, 
	37, 36, 37, 15, 36, 38, 38, 0, 
	39, 40, 41, 39, 0, 39, 40, 41, 
	42, 42, 39, 0, 43, 0, 39, 43, 
	44, 0, 45, 44, 45, 39, 44, 46, 
	46, 0, 47, 47, 0, 48, 48, 0, 
	49, 49, 0, 50, 50, 0, 50, 51, 
	52, 53, 50, 0, 51, 54, 56, 57, 
	55, 51, 55, 55, 55, 0, 59, 58, 
	60, 61, 63, 64, 62, 60, 62, 62, 
	62, 0, 65, 66, 68, 69, 67, 65, 
	67, 67, 67, 0, 71, 70, 72, 0, 
	65, 72, 73, 0, 74, 73, 74, 65, 
	73, 60, 61, 63, 64, 75, 60, 75, 
	76, 75, 75, 0, 77, 0, 51, 77, 
	78, 0, 79, 78, 79, 51, 78, 80, 
	0, 50, 80, 81, 0, 82, 81, 82, 
	50, 81, 85, 84, 87, 86, 88, 54, 
	89, 90, 55, 88, 55, 55, 55, 83, 
	91, 83, 88, 91, 92, 83, 93, 92, 
	93, 88, 92, 95, 94, 97, 96, 97, 
	95, 96, 99, 100, 101, 102, 103, 104, 
	105, 99, 98, 1, 2, 3, 4, 5, 
	4, 5, 1, 0, 107, 107, 107, 107, 
	107, 106, 60, 61, 63, 64, 75, 60, 
	75, 108, 75, 75, 106, 85, 84, 87, 
	86, 86, 110, 88, 54, 89, 90, 55, 
	88, 55, 55, 55, 109, 94, 109, 96, 
	109, 15, 109, 0
]

class << self
	attr_accessor :_record_typ_trans_targs
	private :_record_typ_trans_targs, :_record_typ_trans_targs=
end
self._record_typ_trans_targs = [
	81, 0, 1, 3, 6, 35, 2, 4, 
	5, 7, 8, 9, 10, 11, 12, 13, 
	30, 32, 14, 29, 81, 15, 16, 17, 
	22, 19, 18, 20, 21, 23, 28, 24, 
	25, 26, 27, 31, 33, 34, 36, 37, 
	38, 40, 43, 39, 41, 42, 44, 45, 
	46, 47, 48, 49, 65, 67, 50, 59, 
	60, 62, 50, 51, 52, 53, 83, 54, 
	56, 52, 53, 83, 54, 56, 53, 81, 
	55, 57, 58, 84, 59, 61, 63, 64, 
	66, 68, 69, 81, 70, 81, 71, 87, 
	72, 73, 75, 74, 76, 77, 78, 82, 
	79, 80, 81, 82, 85, 86, 88, 89, 
	90, 91, 81, 83, 84, 81, 81
]

class << self
	attr_accessor :_record_typ_trans_actions
	private :_record_typ_trans_actions, :_record_typ_trans_actions=
end
self._record_typ_trans_actions = [
	27, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 29, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	0, 0, 0, 0, 3, 32, 32, 3, 
	3, 0, 5, 5, 0, 0, 0, 15, 
	0, 0, 0, 47, 0, 0, 0, 0, 
	0, 0, 0, 25, 0, 13, 0, 35, 
	0, 0, 0, 0, 0, 0, 0, 38, 
	0, 0, 17, 44, 11, 44, 44, 11, 
	11, 44, 21, 0, 41, 23, 19
]

class << self
	attr_accessor :_record_typ_to_state_actions
	private :_record_typ_to_state_actions, :_record_typ_to_state_actions=
end
self._record_typ_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 7, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_record_typ_from_state_actions
	private :_record_typ_from_state_actions, :_record_typ_from_state_actions=
end
self._record_typ_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 9, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_record_typ_eof_trans
	private :_record_typ_eof_trans, :_record_typ_eof_trans=
end
self._record_typ_eof_trans = [
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 84, 1, 
	84, 84, 84, 84, 84, 84, 84, 84, 
	84, 0, 1, 107, 107, 110, 110, 111, 
	110, 110, 110, 110
]

class << self
	attr_accessor :record_typ_start
end
self.record_typ_start = 81;
class << self
	attr_accessor :record_typ_first_final
end
self.record_typ_first_final = 81;
class << self
	attr_accessor :record_typ_error
end
self.record_typ_error = -1;

class << self
	attr_accessor :record_typ_en_main
end
self.record_typ_en_main = 81;


# line 45 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
        
# line 331 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = record_typ_start
	ts = nil
	te = nil
	act = 0
end

# line 46 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
        
# line 343 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rb"
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
	_acts = _record_typ_from_state_actions[cs]
	_nacts = _record_typ_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _record_typ_actions[_acts - 1]
			when 5 then
# line 1 "NONE"
		begin
ts = p
		end
# line 373 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _record_typ_key_offsets[cs]
	_trans = _record_typ_index_offsets[cs]
	_klen = _record_typ_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _record_typ_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _record_typ_trans_keys[_mid]
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
	  _klen = _record_typ_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _record_typ_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _record_typ_trans_keys[_mid+1]
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
	_trans = _record_typ_indicies[_trans]
	end
	if _goto_level <= _eof_trans
	cs = _record_typ_trans_targs[_trans]
	if _record_typ_trans_actions[_trans] != 0
		_acts = _record_typ_trans_actions[_trans]
		_nacts = _record_typ_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _record_typ_actions[_acts - 1]
when 0 then
# line 7 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin

  expr = Parser.walk_balanced_paren(data[(p..-1)])
  p += expr.length - 1
  te = p
		end
when 1 then
# line 22 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
 @start_attr = p 		end
when 2 then
# line 22 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
 @end_attr = p 		end
when 3 then
# line 23 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
 @start_typ = p 		end
when 6 then
# line 1 "NONE"
		begin
te = p+1
		end
when 7 then
# line 26 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
act = 1;		end
when 8 then
# line 28 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
act = 3;		end
when 9 then
# line 29 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
act = 4;		end
when 10 then
# line 31 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
act = 6;		end
when 11 then
# line 27 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
te = p+1
		end
when 12 then
# line 29 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
te = p+1
 begin  @attributes << { :name => data[(@start_attr..@end_attr-1)], :type => data[(@start_typ..te-1)] }  end
		end
when 13 then
# line 30 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
te = p+1
		end
when 14 then
# line 31 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
te = p+1
		end
when 15 then
# line 26 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
te = p
p = p - 1;		end
when 16 then
# line 29 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
te = p
p = p - 1; begin  @attributes << { :name => data[(@start_attr..@end_attr-1)], :type => data[(@start_typ..te-1)] }  end
		end
when 17 then
# line 31 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
te = p
p = p - 1;		end
when 18 then
# line 31 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		begin
 begin p = ((te))-1; end
		end
when 19 then
# line 1 "NONE"
		begin
	case act
	when 4 then
	begin begin p = ((te))-1; end
 @attributes << { :name => data[(@start_attr..@end_attr-1)], :type => data[(@start_typ..te-1)] } end
	when 6 then
	begin begin p = ((te))-1; end
end
	else
	begin begin p = ((te))-1; end
end
end 
			end
# line 538 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _record_typ_to_state_actions[cs]
	_nacts = _record_typ_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _record_typ_actions[_acts - 1]
when 4 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 558 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rb"
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
	if _record_typ_eof_trans[cs] > 0
		_trans = _record_typ_eof_trans[cs] - 1;
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

# line 47 "/home/talek/gitrepos/vorax-rb/lib/vorax/parser/grammars/record_typ.rl"
		  end
		  return @attributes
		end

	end

end
