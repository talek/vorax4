
# line 1 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"

# line 15 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"


module Vorax

	module Parser

		def self.identifier_at(data, curpos)
			text = ''
			@ids = []
			if data
				eof = data.length
				
# line 18 "vorax/ruby/lib/vorax/parser/grammars/ids.rb"
class << self
	attr_accessor :_ids_actions
	private :_ids_actions, :_ids_actions=
end
self._ids_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	5, 1, 6, 1, 7, 1, 8, 1, 
	9, 1, 10, 1, 11, 1, 12, 1, 
	13, 2, 2, 3, 2, 2, 4
]

class << self
	attr_accessor :_ids_key_offsets
	private :_ids_key_offsets, :_ids_key_offsets=
end
self._ids_key_offsets = [
	0, 1, 9, 10, 18, 19, 20, 21, 
	22, 24, 35, 36, 37, 38, 47, 57, 
	67, 68, 69, 70
]

class << self
	attr_accessor :_ids_trans_keys
	private :_ids_trans_keys, :_ids_trans_keys=
end
self._ids_trans_keys = [
	34, 34, 95, 35, 36, 65, 90, 97, 
	122, 34, 34, 95, 35, 36, 65, 90, 
	97, 122, 34, 39, 10, 42, 42, 47, 
	34, 39, 45, 47, 95, 35, 36, 65, 
	90, 97, 122, 34, 46, 46, 95, 35, 
	36, 48, 57, 65, 90, 97, 122, 46, 
	95, 35, 36, 48, 57, 65, 90, 97, 
	122, 46, 95, 35, 36, 48, 57, 65, 
	90, 97, 122, 39, 39, 45, 42, 0
]

class << self
	attr_accessor :_ids_single_lengths
	private :_ids_single_lengths, :_ids_single_lengths=
end
self._ids_single_lengths = [
	1, 2, 1, 2, 1, 1, 1, 1, 
	2, 5, 1, 1, 1, 1, 2, 2, 
	1, 1, 1, 1
]

class << self
	attr_accessor :_ids_range_lengths
	private :_ids_range_lengths, :_ids_range_lengths=
end
self._ids_range_lengths = [
	0, 3, 0, 3, 0, 0, 0, 0, 
	0, 3, 0, 0, 0, 4, 4, 4, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_ids_index_offsets
	private :_ids_index_offsets, :_ids_index_offsets=
end
self._ids_index_offsets = [
	0, 2, 8, 10, 16, 18, 20, 22, 
	24, 27, 36, 38, 40, 42, 48, 55, 
	62, 64, 66, 68
]

class << self
	attr_accessor :_ids_indicies
	private :_ids_indicies, :_ids_indicies=
end
self._ids_indicies = [
	2, 1, 4, 5, 5, 5, 5, 3, 
	6, 4, 7, 8, 8, 8, 8, 3, 
	9, 7, 12, 11, 14, 13, 16, 15, 
	16, 14, 15, 18, 20, 21, 22, 19, 
	19, 19, 19, 17, 2, 1, 25, 24, 
	26, 24, 8, 8, 8, 8, 8, 24, 
	26, 5, 5, 5, 5, 5, 24, 25, 
	19, 19, 19, 19, 19, 24, 12, 11, 
	11, 27, 13, 23, 15, 23, 0
]

class << self
	attr_accessor :_ids_trans_targs
	private :_ids_trans_targs, :_ids_trans_targs=
end
self._ids_trans_targs = [
	9, 0, 11, 9, 2, 14, 12, 4, 
	13, 9, 9, 5, 17, 6, 9, 7, 
	8, 9, 10, 15, 16, 18, 19, 9, 
	9, 1, 3, 9
]

class << self
	attr_accessor :_ids_trans_actions
	private :_ids_trans_actions, :_ids_trans_actions=
end
self._ids_trans_actions = [
	21, 0, 5, 19, 0, 5, 5, 0, 
	0, 7, 23, 0, 25, 0, 9, 0, 
	0, 11, 5, 5, 28, 5, 5, 17, 
	15, 0, 0, 13
]

class << self
	attr_accessor :_ids_to_state_actions
	private :_ids_to_state_actions, :_ids_to_state_actions=
end
self._ids_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_ids_from_state_actions
	private :_ids_from_state_actions, :_ids_from_state_actions=
end
self._ids_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 3, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0
]

class << self
	attr_accessor :_ids_eof_trans
	private :_ids_eof_trans, :_ids_eof_trans=
end
self._ids_eof_trans = [
	1, 4, 4, 4, 4, 11, 1, 1, 
	1, 0, 24, 25, 25, 25, 25, 25, 
	24, 28, 24, 24
]

class << self
	attr_accessor :ids_start
end
self.ids_start = 9;
class << self
	attr_accessor :ids_first_final
end
self.ids_first_final = 9;
class << self
	attr_accessor :ids_error
end
self.ids_error = -1;

class << self
	attr_accessor :ids_en_main
end
self.ids_en_main = 9;


# line 27 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
				
# line 175 "vorax/ruby/lib/vorax/parser/grammars/ids.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = ids_start
	ts = nil
	te = nil
	act = 0
end

# line 28 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
				
# line 187 "vorax/ruby/lib/vorax/parser/grammars/ids.rb"
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
	_acts = _ids_from_state_actions[cs]
	_nacts = _ids_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _ids_actions[_acts - 1]
			when 1 then
# line 1 "NONE"
		begin
ts = p
		end
# line 217 "vorax/ruby/lib/vorax/parser/grammars/ids.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _ids_key_offsets[cs]
	_trans = _ids_index_offsets[cs]
	_klen = _ids_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _ids_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _ids_trans_keys[_mid]
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
	  _klen = _ids_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _ids_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _ids_trans_keys[_mid+1]
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
	_trans = _ids_indicies[_trans]
	end
	if _goto_level <= _eof_trans
	cs = _ids_trans_targs[_trans]
	if _ids_trans_actions[_trans] != 0
		_acts = _ids_trans_actions[_trans]
		_nacts = _ids_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _ids_actions[_acts - 1]
when 2 then
# line 1 "NONE"
		begin
te = p+1
		end
when 3 then
# line 8 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
act = 1;		end
when 4 then
# line 12 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
act = 5;		end
when 5 then
# line 9 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
te = p+1
 begin  @ids << [ts, te, data[(ts...te)]]  end
		end
when 6 then
# line 11 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
te = p+1
		end
when 7 then
# line 12 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
te = p+1
		end
when 8 then
# line 8 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
te = p
p = p - 1;		end
when 9 then
# line 9 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
te = p
p = p - 1; begin  @ids << [ts, te, data[(ts...te)]]  end
		end
when 10 then
# line 12 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
te = p
p = p - 1;		end
when 11 then
# line 9 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
 begin p = ((te))-1; end
 begin  @ids << [ts, te, data[(ts...te)]]  end
		end
when 12 then
# line 12 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
		begin
 begin p = ((te))-1; end
		end
when 13 then
# line 1 "NONE"
		begin
	case act
	when 5 then
	begin begin p = ((te))-1; end
end
	else
	begin begin p = ((te))-1; end
end
end 
			end
# line 352 "vorax/ruby/lib/vorax/parser/grammars/ids.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _ids_to_state_actions[cs]
	_nacts = _ids_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _ids_actions[_acts - 1]
when 0 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 372 "vorax/ruby/lib/vorax/parser/grammars/ids.rb"
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
	if _ids_eof_trans[cs] > 0
		_trans = _ids_eof_trans[cs] - 1;
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

# line 29 "vorax/ruby/lib/vorax/parser/grammars/ids.rl"
			end
		  @ids.each do |rec|
		    text = rec[2] if (rec[0]...rec[1]).include?(curpos)
			end
			return text
		end

	end

end
