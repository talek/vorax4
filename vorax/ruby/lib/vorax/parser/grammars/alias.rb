
# line 1 "lib/vorax/parser/grammars/alias.rl"

# line 72 "lib/vorax/parser/grammars/alias.rl"


module Vorax

  module Parser

    # An abstraction for an alias within a SQL statement.
    class Alias

      def initialize        
        @not_alias = ['ON', 'WHERE', 'FROM', 'CONNECT', 'START', 
                      'GROUP', 'HAVING', 'MODEL']
      end

      # Walks the provided statement searching for alias references.
      #
      # @param data the statement
      def walk(data)
        @refs = [];
        @start_columns = 0
        @columns = nil;
        data << "\n"
        eof = data.length
        
# line 30 "lib/vorax/parser/grammars/alias.rb"
class << self
	attr_accessor :_alias_actions
	private :_alias_actions, :_alias_actions=
end
self._alias_actions = [
	0, 1, 1, 1, 2, 1, 3, 1, 
	6, 1, 8, 1, 9, 1, 10, 1, 
	15, 1, 16, 1, 17, 1, 18, 1, 
	19, 1, 21, 1, 22, 1, 23, 1, 
	24, 1, 25, 1, 26, 1, 27, 2, 
	1, 19, 2, 1, 21, 2, 3, 19, 
	2, 3, 21, 2, 5, 2, 2, 6, 
	20, 2, 7, 0, 2, 10, 2, 2, 
	10, 4, 2, 10, 11, 2, 10, 12, 
	2, 10, 13, 2, 10, 14, 3, 10, 
	7, 0, 3, 10, 7, 4
]

class << self
	attr_accessor :_alias_key_offsets
	private :_alias_key_offsets, :_alias_key_offsets=
end
self._alias_key_offsets = [
	0, 9, 10, 11, 12, 13, 15, 17, 
	19, 21, 26, 40, 41, 55, 56, 62, 
	76, 77, 78, 79, 87, 88, 89, 90, 
	92, 100, 101, 102, 103, 104, 105, 107, 
	108, 109, 110, 111, 113, 114, 115, 116, 
	117, 119, 121, 123, 125, 130, 144, 145, 
	158, 159, 160, 161, 162, 163, 165, 173, 
	174, 182, 183, 184, 185, 186, 187, 189, 
	190, 191, 192, 193, 195, 197, 199, 201, 
	203, 208, 209, 210, 211, 212, 214, 216, 
	218, 223, 236, 237, 242, 249, 250, 251, 
	252, 253, 255, 257, 263, 269, 282, 283, 
	288, 295, 296, 297, 298, 299, 301, 303, 
	309, 310, 311, 312, 313, 315, 329, 330, 
	331, 332, 333, 335, 336, 337, 338, 339, 
	341, 342, 343, 344, 345, 347, 361, 362, 
	363, 364, 365, 367, 378, 387, 395, 401, 
	418, 425, 431, 446, 462, 468, 483, 490, 
	490, 499, 505, 510, 524, 539, 555, 560, 
	561, 562, 563, 564, 565, 567, 572, 574
]

class << self
	attr_accessor :_alias_trans_keys
	private :_alias_trans_keys, :_alias_trans_keys=
end
self._alias_trans_keys = [
	32, 45, 47, 70, 74, 102, 106, 9, 
	13, 45, 10, 42, 42, 42, 47, 82, 
	114, 79, 111, 77, 109, 32, 45, 47, 
	9, 13, 32, 34, 40, 45, 47, 95, 
	9, 13, 35, 36, 65, 90, 97, 122, 
	34, 32, 34, 44, 45, 47, 95, 9, 
	13, 35, 36, 65, 90, 97, 122, 34, 
	32, 44, 45, 47, 9, 13, 32, 34, 
	40, 45, 47, 95, 9, 13, 35, 36, 
	65, 90, 97, 122, 34, 45, 10, 34, 
	95, 35, 36, 65, 90, 97, 122, 34, 
	42, 42, 42, 47, 34, 95, 35, 36, 
	65, 90, 97, 122, 34, 45, 10, 42, 
	42, 42, 47, 45, 10, 42, 42, 42, 
	47, 45, 10, 42, 42, 42, 47, 79, 
	111, 73, 105, 78, 110, 32, 45, 47, 
	9, 13, 32, 34, 40, 45, 47, 95, 
	9, 13, 35, 36, 65, 90, 97, 122, 
	34, 32, 34, 45, 47, 95, 9, 13, 
	35, 36, 65, 90, 97, 122, 34, 45, 
	10, 42, 42, 42, 47, 34, 95, 35, 
	36, 65, 90, 97, 122, 34, 34, 95, 
	35, 36, 65, 90, 97, 122, 34, 45, 
	10, 42, 42, 42, 47, 34, 39, 10, 
	42, 42, 47, 76, 108, 69, 101, 67, 
	99, 84, 116, 32, 45, 47, 9, 13, 
	45, 10, 42, 42, 42, 47, 84, 116, 
	72, 104, 32, 45, 47, 9, 13, 32, 
	34, 45, 47, 95, 9, 13, 35, 36, 
	65, 90, 97, 122, 34, 32, 45, 47, 
	9, 13, 32, 45, 47, 65, 97, 9, 
	13, 45, 10, 42, 42, 42, 47, 83, 
	115, 32, 40, 45, 47, 9, 13, 32, 
	44, 45, 47, 9, 13, 32, 34, 45, 
	47, 95, 9, 13, 35, 36, 65, 90, 
	97, 122, 34, 32, 45, 47, 9, 13, 
	32, 45, 47, 65, 97, 9, 13, 45, 
	10, 42, 42, 42, 47, 83, 115, 32, 
	40, 45, 47, 9, 13, 45, 10, 42, 
	42, 42, 47, 32, 45, 47, 95, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 45, 10, 42, 42, 42, 47, 45, 
	10, 42, 42, 42, 47, 45, 10, 42, 
	42, 42, 47, 32, 45, 47, 95, 9, 
	13, 35, 36, 48, 57, 65, 90, 97, 
	122, 45, 10, 42, 42, 42, 47, 32, 
	34, 39, 45, 47, 83, 87, 115, 119, 
	9, 13, 32, 45, 47, 70, 74, 102, 
	106, 9, 13, 32, 44, 45, 46, 47, 
	64, 9, 13, 32, 44, 45, 47, 9, 
	13, 32, 44, 45, 46, 47, 64, 95, 
	9, 13, 35, 36, 48, 57, 65, 90, 
	97, 122, 32, 44, 45, 47, 64, 9, 
	13, 32, 44, 45, 47, 9, 13, 32, 
	44, 45, 47, 95, 9, 13, 35, 36, 
	48, 57, 65, 90, 97, 122, 32, 44, 
	45, 47, 64, 95, 9, 13, 35, 36, 
	48, 57, 65, 90, 97, 122, 32, 44, 
	45, 47, 9, 13, 32, 44, 45, 47, 
	95, 9, 13, 35, 36, 48, 57, 65, 
	90, 97, 122, 32, 45, 46, 47, 64, 
	9, 13, 95, 35, 36, 48, 57, 65, 
	90, 97, 122, 32, 45, 47, 64, 9, 
	13, 32, 45, 47, 9, 13, 32, 45, 
	47, 95, 9, 13, 35, 36, 48, 57, 
	65, 90, 97, 122, 32, 45, 47, 64, 
	95, 9, 13, 35, 36, 48, 57, 65, 
	90, 97, 122, 32, 45, 46, 47, 64, 
	95, 9, 13, 35, 36, 48, 57, 65, 
	90, 97, 122, 32, 45, 47, 9, 13, 
	34, 39, 39, 45, 42, 69, 101, 32, 
	45, 47, 9, 13, 73, 105, 32, 44, 
	45, 47, 9, 13, 0
]

class << self
	attr_accessor :_alias_single_lengths
	private :_alias_single_lengths, :_alias_single_lengths=
end
self._alias_single_lengths = [
	7, 1, 1, 1, 1, 2, 2, 2, 
	2, 3, 6, 1, 6, 1, 4, 6, 
	1, 1, 1, 2, 1, 1, 1, 2, 
	2, 1, 1, 1, 1, 1, 2, 1, 
	1, 1, 1, 2, 1, 1, 1, 1, 
	2, 2, 2, 2, 3, 6, 1, 5, 
	1, 1, 1, 1, 1, 2, 2, 1, 
	2, 1, 1, 1, 1, 1, 2, 1, 
	1, 1, 1, 2, 2, 2, 2, 2, 
	3, 1, 1, 1, 1, 2, 2, 2, 
	3, 5, 1, 3, 5, 1, 1, 1, 
	1, 2, 2, 4, 4, 5, 1, 3, 
	5, 1, 1, 1, 1, 2, 2, 4, 
	1, 1, 1, 1, 2, 4, 1, 1, 
	1, 1, 2, 1, 1, 1, 1, 2, 
	1, 1, 1, 1, 2, 4, 1, 1, 
	1, 1, 2, 9, 7, 6, 4, 7, 
	5, 4, 5, 6, 4, 5, 5, 0, 
	1, 4, 3, 4, 5, 6, 3, 1, 
	1, 1, 1, 1, 2, 3, 2, 4
]

class << self
	attr_accessor :_alias_range_lengths
	private :_alias_range_lengths, :_alias_range_lengths=
end
self._alias_range_lengths = [
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 4, 0, 4, 0, 1, 4, 
	0, 0, 0, 3, 0, 0, 0, 0, 
	3, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 4, 0, 4, 
	0, 0, 0, 0, 0, 0, 3, 0, 
	3, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	1, 4, 0, 1, 1, 0, 0, 0, 
	0, 0, 0, 1, 1, 4, 0, 1, 
	1, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 5, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 5, 0, 0, 
	0, 0, 0, 1, 1, 1, 1, 5, 
	1, 1, 5, 5, 1, 5, 1, 0, 
	4, 1, 1, 5, 5, 5, 1, 0, 
	0, 0, 0, 0, 0, 1, 0, 1
]

class << self
	attr_accessor :_alias_index_offsets
	private :_alias_index_offsets, :_alias_index_offsets=
end
self._alias_index_offsets = [
	0, 9, 11, 13, 15, 17, 20, 23, 
	26, 29, 34, 45, 47, 58, 60, 66, 
	77, 79, 81, 83, 89, 91, 93, 95, 
	98, 104, 106, 108, 110, 112, 114, 117, 
	119, 121, 123, 125, 128, 130, 132, 134, 
	136, 139, 142, 145, 148, 153, 164, 166, 
	176, 178, 180, 182, 184, 186, 189, 195, 
	197, 203, 205, 207, 209, 211, 213, 216, 
	218, 220, 222, 224, 227, 230, 233, 236, 
	239, 244, 246, 248, 250, 252, 255, 258, 
	261, 266, 276, 278, 283, 290, 292, 294, 
	296, 298, 301, 304, 310, 316, 326, 328, 
	333, 340, 342, 344, 346, 348, 351, 354, 
	360, 362, 364, 366, 368, 371, 381, 383, 
	385, 387, 389, 392, 394, 396, 398, 400, 
	403, 405, 407, 409, 411, 414, 424, 426, 
	428, 430, 432, 435, 446, 455, 463, 469, 
	482, 489, 495, 506, 518, 524, 535, 542, 
	543, 549, 555, 560, 570, 581, 593, 598, 
	600, 602, 604, 606, 608, 611, 616, 619
]

class << self
	attr_accessor :_alias_trans_targs
	private :_alias_trans_targs, :_alias_trans_targs=
end
self._alias_trans_targs = [
	0, 1, 3, 6, 41, 6, 41, 0, 
	131, 2, 131, 0, 2, 4, 131, 5, 
	4, 5, 0, 4, 7, 7, 131, 8, 
	8, 131, 9, 9, 131, 10, 36, 38, 
	10, 131, 10, 11, 140, 36, 38, 135, 
	10, 135, 135, 135, 131, 133, 11, 12, 
	13, 15, 17, 21, 141, 12, 141, 141, 
	141, 131, 134, 13, 14, 15, 31, 33, 
	14, 131, 15, 16, 140, 26, 28, 135, 
	15, 135, 135, 135, 131, 133, 16, 18, 
	131, 12, 18, 20, 139, 139, 139, 139, 
	131, 136, 20, 22, 131, 23, 22, 23, 
	12, 22, 25, 138, 138, 138, 138, 131, 
	137, 25, 27, 131, 15, 27, 29, 131, 
	30, 29, 30, 15, 29, 32, 131, 14, 
	32, 34, 131, 35, 34, 35, 14, 34, 
	37, 131, 10, 37, 39, 131, 40, 39, 
	40, 10, 39, 42, 42, 131, 43, 43, 
	131, 44, 44, 131, 45, 58, 60, 45, 
	131, 45, 46, 150, 58, 60, 149, 45, 
	149, 149, 149, 131, 142, 46, 47, 48, 
	49, 51, 144, 47, 144, 144, 144, 131, 
	143, 48, 50, 131, 47, 50, 52, 131, 
	53, 52, 53, 47, 52, 55, 148, 148, 
	148, 148, 131, 145, 55, 57, 147, 147, 
	147, 147, 131, 146, 57, 59, 131, 45, 
	59, 61, 131, 62, 61, 62, 45, 61, 
	131, 63, 153, 64, 132, 65, 67, 66, 
	67, 132, 66, 69, 69, 131, 70, 70, 
	131, 71, 71, 131, 72, 72, 131, 157, 
	73, 75, 157, 131, 74, 131, 157, 74, 
	76, 131, 77, 76, 77, 157, 76, 79, 
	79, 131, 80, 80, 131, 81, 126, 128, 
	81, 131, 81, 82, 126, 128, 125, 81, 
	125, 125, 125, 131, 83, 82, 84, 85, 
	87, 84, 131, 84, 85, 87, 90, 90, 
	84, 131, 86, 131, 84, 86, 88, 131, 
	89, 88, 89, 84, 88, 91, 91, 131, 
	91, 159, 120, 122, 91, 131, 92, 93, 
	115, 117, 92, 131, 93, 94, 110, 112, 
	109, 93, 109, 109, 109, 131, 95, 94, 
	96, 97, 99, 96, 131, 96, 97, 99, 
	102, 102, 96, 131, 98, 131, 96, 98, 
	100, 131, 101, 100, 101, 96, 100, 103, 
	103, 131, 103, 159, 104, 106, 103, 131, 
	105, 131, 103, 105, 107, 131, 108, 107, 
	108, 103, 107, 96, 97, 99, 109, 96, 
	109, 109, 109, 109, 131, 111, 131, 93, 
	111, 113, 131, 114, 113, 114, 93, 113, 
	116, 131, 92, 116, 118, 131, 119, 118, 
	119, 92, 118, 121, 131, 91, 121, 123, 
	131, 124, 123, 124, 91, 123, 84, 85, 
	87, 125, 84, 125, 125, 125, 125, 131, 
	127, 131, 81, 127, 129, 131, 130, 129, 
	130, 81, 129, 132, 151, 152, 154, 155, 
	156, 158, 156, 158, 132, 131, 0, 1, 
	3, 6, 41, 6, 41, 0, 131, 12, 
	15, 17, 19, 21, 24, 12, 131, 14, 
	15, 31, 33, 14, 131, 12, 15, 17, 
	19, 21, 24, 135, 12, 135, 135, 135, 
	135, 131, 12, 15, 17, 21, 24, 12, 
	131, 12, 15, 17, 21, 12, 131, 12, 
	15, 17, 21, 138, 12, 138, 138, 138, 
	138, 131, 12, 15, 17, 21, 24, 139, 
	12, 139, 139, 139, 139, 131, 12, 15, 
	17, 21, 12, 131, 14, 15, 31, 33, 
	141, 14, 141, 141, 141, 141, 131, 47, 
	49, 54, 51, 56, 47, 131, 131, 144, 
	144, 144, 144, 144, 131, 47, 49, 51, 
	56, 47, 131, 47, 49, 51, 47, 131, 
	47, 49, 51, 147, 47, 147, 147, 147, 
	147, 131, 47, 49, 51, 56, 148, 47, 
	148, 148, 148, 148, 131, 47, 49, 54, 
	51, 56, 149, 47, 149, 149, 149, 149, 
	131, 47, 49, 51, 47, 131, 131, 63, 
	153, 64, 64, 131, 65, 131, 66, 131, 
	68, 68, 131, 157, 73, 75, 157, 131, 
	78, 78, 131, 92, 93, 115, 117, 92, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	131, 131, 131, 131, 131, 131, 131, 131, 
	0
]

class << self
	attr_accessor :_alias_trans_actions
	private :_alias_trans_actions, :_alias_trans_actions=
end
self._alias_trans_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	37, 0, 37, 0, 0, 0, 37, 0, 
	0, 0, 0, 0, 0, 0, 37, 0, 
	0, 37, 0, 0, 37, 0, 0, 0, 
	0, 37, 0, 57, 82, 0, 0, 78, 
	0, 78, 78, 78, 37, 13, 0, 0, 
	3, 0, 0, 0, 60, 0, 60, 60, 
	60, 29, 13, 0, 0, 0, 0, 0, 
	0, 29, 0, 57, 82, 0, 0, 78, 
	0, 78, 78, 78, 29, 13, 0, 0, 
	29, 0, 0, 0, 13, 13, 13, 13, 
	29, 13, 0, 0, 29, 0, 0, 0, 
	0, 0, 0, 13, 13, 13, 13, 29, 
	13, 0, 0, 29, 0, 0, 0, 29, 
	0, 0, 0, 0, 0, 0, 29, 0, 
	0, 0, 29, 0, 0, 0, 0, 0, 
	0, 37, 0, 0, 0, 37, 0, 0, 
	0, 0, 0, 0, 0, 37, 0, 0, 
	37, 0, 0, 37, 0, 0, 0, 0, 
	37, 0, 57, 82, 0, 0, 78, 0, 
	78, 78, 78, 37, 13, 0, 0, 3, 
	0, 0, 3, 0, 3, 3, 3, 33, 
	0, 0, 0, 33, 0, 0, 0, 33, 
	0, 0, 0, 0, 0, 0, 13, 13, 
	13, 13, 33, 13, 0, 0, 13, 13, 
	13, 13, 33, 13, 0, 0, 37, 0, 
	0, 0, 37, 0, 0, 0, 0, 0, 
	15, 0, 66, 0, 69, 0, 0, 0, 
	0, 69, 0, 0, 0, 35, 0, 0, 
	35, 0, 0, 35, 0, 0, 35, 72, 
	0, 0, 72, 35, 0, 37, 72, 0, 
	0, 37, 0, 0, 0, 72, 0, 0, 
	0, 35, 0, 0, 35, 0, 0, 0, 
	0, 35, 0, 51, 0, 0, 51, 0, 
	51, 51, 51, 35, 0, 0, 5, 5, 
	5, 5, 35, 0, 0, 0, 0, 0, 
	0, 35, 0, 35, 0, 0, 0, 35, 
	0, 0, 0, 0, 0, 0, 0, 35, 
	0, 63, 0, 0, 0, 35, 0, 0, 
	0, 0, 0, 31, 0, 51, 0, 0, 
	51, 0, 51, 51, 51, 31, 0, 0, 
	5, 5, 5, 5, 31, 0, 0, 0, 
	0, 0, 0, 31, 0, 31, 0, 0, 
	0, 31, 0, 0, 0, 0, 0, 0, 
	0, 31, 0, 63, 0, 0, 0, 31, 
	0, 31, 0, 0, 0, 31, 0, 0, 
	0, 0, 0, 5, 5, 5, 0, 5, 
	0, 0, 0, 0, 31, 0, 31, 0, 
	0, 0, 31, 0, 0, 0, 0, 0, 
	0, 31, 0, 0, 0, 31, 0, 0, 
	0, 0, 0, 0, 35, 0, 0, 0, 
	35, 0, 0, 0, 0, 0, 5, 5, 
	5, 0, 5, 0, 0, 0, 0, 35, 
	0, 35, 0, 0, 0, 35, 0, 0, 
	0, 0, 0, 75, 13, 75, 13, 13, 
	75, 13, 75, 13, 75, 17, 0, 0, 
	0, 0, 0, 0, 0, 0, 37, 1, 
	1, 1, 0, 1, 0, 1, 39, 5, 
	5, 5, 5, 5, 45, 1, 1, 1, 
	0, 1, 0, 13, 1, 13, 13, 13, 
	13, 39, 1, 1, 1, 1, 0, 1, 
	39, 1, 1, 1, 1, 1, 39, 1, 
	1, 1, 1, 13, 1, 13, 13, 13, 
	13, 39, 1, 1, 1, 1, 0, 13, 
	1, 13, 13, 13, 13, 39, 0, 0, 
	0, 0, 0, 23, 5, 5, 5, 5, 
	13, 5, 13, 13, 13, 13, 45, 1, 
	1, 0, 1, 0, 1, 42, 48, 0, 
	0, 0, 0, 0, 48, 1, 1, 1, 
	0, 1, 42, 1, 1, 1, 1, 42, 
	1, 1, 1, 13, 1, 13, 13, 13, 
	13, 42, 1, 1, 1, 0, 13, 1, 
	13, 13, 13, 13, 42, 1, 1, 0, 
	1, 0, 13, 1, 13, 13, 13, 13, 
	42, 0, 0, 0, 0, 25, 15, 0, 
	66, 0, 0, 19, 0, 27, 0, 27, 
	0, 0, 27, 72, 0, 0, 72, 21, 
	0, 0, 27, 7, 7, 7, 7, 7, 
	54, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 29, 29, 29, 
	29, 29, 29, 29, 29, 29, 29, 29, 
	29, 29, 29, 29, 29, 29, 29, 29, 
	29, 29, 29, 29, 29, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	33, 33, 33, 33, 33, 33, 33, 33, 
	33, 33, 33, 37, 37, 37, 37, 37, 
	35, 37, 35, 35, 35, 35, 35, 35, 
	35, 35, 37, 37, 37, 37, 37, 35, 
	35, 35, 35, 35, 35, 35, 35, 35, 
	35, 35, 35, 35, 35, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 35, 35, 35, 35, 35, 35, 35, 
	35, 35, 35, 35, 37, 39, 45, 39, 
	39, 39, 39, 39, 23, 45, 42, 48, 
	48, 42, 42, 42, 42, 42, 25, 27, 
	27, 19, 27, 27, 27, 21, 27, 54, 
	0
]

class << self
	attr_accessor :_alias_to_state_actions
	private :_alias_to_state_actions, :_alias_to_state_actions=
end
self._alias_to_state_actions = [
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 9, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_alias_from_state_actions
	private :_alias_from_state_actions, :_alias_from_state_actions=
end
self._alias_from_state_actions = [
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 11, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_alias_eof_trans
	private :_alias_eof_trans, :_alias_eof_trans=
end
self._alias_eof_trans = [
	757, 757, 757, 757, 757, 757, 757, 757, 
	757, 757, 757, 757, 661, 661, 661, 661, 
	661, 661, 661, 661, 661, 661, 661, 661, 
	661, 661, 661, 661, 661, 661, 661, 661, 
	661, 661, 661, 661, 757, 757, 757, 757, 
	757, 757, 757, 757, 757, 757, 757, 683, 
	683, 683, 683, 683, 683, 683, 683, 683, 
	683, 683, 757, 757, 757, 757, 757, 756, 
	757, 756, 756, 756, 756, 756, 756, 756, 
	756, 757, 757, 757, 757, 757, 756, 756, 
	756, 756, 756, 756, 756, 756, 756, 756, 
	756, 756, 756, 756, 745, 745, 745, 745, 
	745, 745, 745, 745, 745, 745, 745, 745, 
	745, 745, 745, 745, 745, 745, 745, 745, 
	745, 745, 745, 745, 745, 745, 745, 745, 
	756, 756, 756, 756, 756, 756, 756, 756, 
	756, 756, 756, 0, 757, 764, 766, 764, 
	764, 764, 764, 764, 765, 766, 774, 769, 
	769, 774, 774, 774, 774, 774, 775, 783, 
	783, 778, 783, 783, 783, 782, 783, 784
]

class << self
	attr_accessor :alias_start
end
self.alias_start = 131;
class << self
	attr_accessor :alias_first_final
end
self.alias_first_final = 131;
class << self
	attr_accessor :alias_error
end
self.alias_error = -1;

class << self
	attr_accessor :alias_en_main
end
self.alias_en_main = 131;


# line 96 "lib/vorax/parser/grammars/alias.rl"
        
# line 551 "lib/vorax/parser/grammars/alias.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = alias_start
	ts = nil
	te = nil
	act = 0
end

# line 97 "lib/vorax/parser/grammars/alias.rl"
        
# line 563 "lib/vorax/parser/grammars/alias.rb"
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
	_acts = _alias_from_state_actions[cs]
	_nacts = _alias_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _alias_actions[_acts - 1]
			when 9 then
# line 1 "NONE"
		begin
ts = p
		end
# line 593 "lib/vorax/parser/grammars/alias.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _alias_key_offsets[cs]
	_trans = _alias_index_offsets[cs]
	_klen = _alias_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _alias_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _alias_trans_keys[_mid]
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
	  _klen = _alias_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _alias_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _alias_trans_keys[_mid+1]
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
	end
	if _goto_level <= _eof_trans
	cs = _alias_trans_targs[_trans]
	if _alias_trans_actions[_trans] != 0
		_acts = _alias_trans_actions[_trans]
		_nacts = _alias_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _alias_actions[_acts - 1]
when 0 then
# line 5 "lib/vorax/parser/grammars/alias.rl"
		begin

  @t_start = p
		end
when 1 then
# line 9 "lib/vorax/parser/grammars/alias.rl"
		begin

  @table_ref = data[(@t_start..p-1)]
		end
when 2 then
# line 13 "lib/vorax/parser/grammars/alias.rl"
		begin

  @a_start = p
  @alias_value = nil
		end
when 3 then
# line 18 "lib/vorax/parser/grammars/alias.rl"
		begin

  text = data[(@a_start..p-1)]
  @alias_value = text unless @not_alias.include?(text.upcase)
		end
when 4 then
# line 23 "lib/vorax/parser/grammars/alias.rl"
		begin

  @subquery_text = Parser.walk_balanced_paren(data[(p..-1)]).gsub(/^\(|\)$/, '')
  p += 1
  @subquery_range = (p..p+@subquery_text.length-1)
  p += @subquery_text.length
  te = p
		end
when 5 then
# line 31 "lib/vorax/parser/grammars/alias.rl"
		begin

  @alias_value = nil
  @subquery_range = nil
  @subquery_text = nil
		end
when 6 then
# line 37 "lib/vorax/parser/grammars/alias.rl"
		begin

  @refs << ExprRef.new(@subquery_text, @subquery_range, @alias_value)
  @alias_value = nil
  @subquery_range = nil
  @subquery_text = nil
		end
when 7 then
# line 44 "lib/vorax/parser/grammars/alias.rl"
		begin

  add_tableref
		end
when 10 then
# line 1 "NONE"
		begin
te = p+1
		end
when 11 then
# line 62 "lib/vorax/parser/grammars/alias.rl"
		begin
act = 1;		end
when 12 then
# line 64 "lib/vorax/parser/grammars/alias.rl"
		begin
act = 3;		end
when 13 then
# line 65 "lib/vorax/parser/grammars/alias.rl"
		begin
act = 4;		end
when 14 then
# line 69 "lib/vorax/parser/grammars/alias.rl"
		begin
act = 8;		end
when 15 then
# line 63 "lib/vorax/parser/grammars/alias.rl"
		begin
te = p+1
		end
when 16 then
# line 69 "lib/vorax/parser/grammars/alias.rl"
		begin
te = p+1
		end
when 17 then
# line 62 "lib/vorax/parser/grammars/alias.rl"
		begin
te = p
p = p - 1;		end
when 18 then
# line 65 "lib/vorax/parser/grammars/alias.rl"
		begin
te = p
p = p - 1; begin  @start_columns = te  end
		end
when 19 then
# line 66 "lib/vorax/parser/grammars/alias.rl"
		begin
te = p
p = p - 1; begin  @columns = data[(@start_columns..ts)] unless @columns  end
		end
when 20 then
# line 67 "lib/vorax/parser/grammars/alias.rl"
		begin
te = p
p = p - 1;		end
when 21 then
# line 68 "lib/vorax/parser/grammars/alias.rl"
		begin
te = p
p = p - 1;		end
when 22 then
# line 69 "lib/vorax/parser/grammars/alias.rl"
		begin
te = p
p = p - 1;		end
when 23 then
# line 66 "lib/vorax/parser/grammars/alias.rl"
		begin
 begin p = ((te))-1; end
 begin  @columns = data[(@start_columns..ts)] unless @columns  end
		end
when 24 then
# line 67 "lib/vorax/parser/grammars/alias.rl"
		begin
 begin p = ((te))-1; end
		end
when 25 then
# line 68 "lib/vorax/parser/grammars/alias.rl"
		begin
 begin p = ((te))-1; end
		end
when 26 then
# line 69 "lib/vorax/parser/grammars/alias.rl"
		begin
 begin p = ((te))-1; end
		end
when 27 then
# line 1 "NONE"
		begin
	case act
	when 4 then
	begin begin p = ((te))-1; end
 @start_columns = te end
	when 8 then
	begin begin p = ((te))-1; end
end
	else
	begin begin p = ((te))-1; end
end
end 
			end
# line 817 "lib/vorax/parser/grammars/alias.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _alias_to_state_actions[cs]
	_nacts = _alias_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _alias_actions[_acts - 1]
when 8 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 837 "lib/vorax/parser/grammars/alias.rb"
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
	if _alias_eof_trans[cs] > 0
		_trans = _alias_eof_trans[cs] - 1;
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

# line 98 "lib/vorax/parser/grammars/alias.rl"
        data.chop!

        # needed to finalize the last pending tableref
        add_tableref
      end

      # Get all identified tableref/exprref references. This method
      # should be called after walk.
      #
      # @return an array of references
      def refs
        @refs
      end

      # A string containing the column list, if there's any.
      #
      # @return a string with all defined columns
      def query_fields
        @columns
      end

      private 
      
      def add_tableref
        if (not @table_ref.nil?)
          @refs << TableRef.new(@table_ref, @alias_value)
        elsif (not @subquery_text.nil?)
          @refs << ExprRef.new(@subquery_text, 
                               @subquery_range, 
                               @alias_value)
        end
        @alias_value = nil
        @table_ref = nil
      end

    end

  end

end

