%%{

machine ids;

include common "common.rl";

main := |*
  squoted_string;
  qualified_identifier => { @ids << [ts, te, data[(ts...te)]] };
  dquoted_string;
  comment;
  any => {};
*|;

}%%

module Vorax

	module Parser

		def self.identifier_at(data, curpos)
			text = ''
			@ids = []
			if data
				eof = data.length
				%% write data;
				%% write init;
				%% write exec;
			end
		  @ids.each do |rec|
		    text = rec[2] if (rec[0]...rec[1]).include?(curpos)
			end
			return text
		end

	end

end
