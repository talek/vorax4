%%{

machine statement;

action parse_start {
  eof = pe
}

action parse_error {
}

action mark_as_anonymous {
  stmt_type = 'ANONYMOUS'
}

action mark_as_sqlplus_command {
  stmt_type = 'SQLPLUS'
}

action mark_as_sql {
  stmt_type = nil
}

action mark_type {
  tail = data[(0...p)]
  type = tail[/\w+\Z/]
  stmt_type = type.upcase if type
}

action mark_body {
  stmt_type << ' BODY'
}

include common "common.rl";

# parsing rules baby
anonymous_block = ((K_BEGIN | K_DECLARE) ws+) @mark_as_anonymous;
simple_module = (K_TRIGGER | K_FUNCTION | K_PROCEDURE) %mark_type;
package_module = (K_PACKAGE %mark_type) (ws+ K_BODY %mark_body)?;
type_module = (K_TYPE %mark_type) (ws+ K_BODY %mark_body)?;
java_module = ((K_AND ws+ (K_RESOLVE | K_COMPILE) ws+ K_NOFORCE ws+) |
                (K_AND ws+ (K_RESOLVE | K_COMPILE) ws+) |
                (K_NOFORCE ws+))? (K_JAVA %mark_type);
plsql_module = K_CREATE ws+ (K_OR ws+ K_REPLACE ws+)? 
               (simple_module | 
                package_module | 
                type_module | 
                java_module) ws+;
set_transaction = (K_SET ws+ K_TRANSACTION ws+) @ mark_as_sql;
sqlplus_command = (((K_ACCEPT | K_ARCHIVE | K_ATTRIBUTE | K_BREAK | K_BTITLE | K_CLEAR | K_COLUMN |
                  K_COMPUTE | K_CONNECT | K_COPY | K_DEFINE | K_DESCRIBE | K_DISCONNECT | K_EXECUTE |
                  K_EXIT | K_HELP | K_HOST | K_PASSWORD | K_PAUSE | K_PRINT | K_PROMPT |
                  K_RECOVER | K_REMARK | K_REPFOOTER | K_REPHEADER | K_RUN | K_SAVE | K_SET | K_SHOW | K_SHUTDOWN |
                  K_SPOOL | K_START | K_STARTUP | K_STORE | K_TIMING | K_TITLE | K_UNDEFINE | K_VARIABLE | K_WHENEVER |
                  K_XQUERY) ws+) | ('@@' | '@' | '/' | '!')) @ mark_as_sqlplus_command;
 
main := ws* (anonymous_block | set_transaction | sqlplus_command | plsql_module) >parse_start $err(parse_error);

}%%

module Vorax

  module Parser

    # Gets the type of the provided statement.
    # 
    # @param data [String] the statement
    # @return [String] 'SQLPLUS' for an sqlplus statement, 'FUNCTION|PROCEDURE|PACKAGE|TYPE...' for
    #   a PL/SQL block, 'ANONYMOUS' for an anonymous plsql block
    def self.statement_type(data)
      stmt_type = nil
      data << "\n"
      %% write data;
      %% write init;
      %% write exec;
      data.chop!
      return stmt_type
    end

end

end

