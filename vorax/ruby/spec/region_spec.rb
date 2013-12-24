# encoding: UTF-8

include Vorax

describe 'region' do

  it 'should detect a package spec' do# {{{
    text = 'create or replace package scott.text as g_var integer; end;'
    Parser::CompositeRegion.probe(text).should == {:name => "scott.text", 
                                                   :kind => :package_spec, 
                                                   :name_pos => 26,
                                                   :pointer => 39}

    text = 'create or replace package test authid current_user as g_var integer; end;'
    Parser::SpecRegion.probe(text).should == {:name => 'test', 
                                              :kind => :package_spec,
                                              :name_pos => 26,
                                              :pointer => 53}

    text = 'create package test authid definer as g_var integer; end;'
    Parser::SpecRegion.probe(text).should == {:name => 'test', 
                                              :kind => :package_spec,
                                              :name_pos => 15,
                                              :pointer => 37}

    text = 'package test as g_var integer; end;'
    Parser::SpecRegion.probe(text).should == {:name => 'test', 
                                              :kind => :package_spec,
                                              :name_pos => 8,
                                              :pointer => 15}
  end# }}}

  it 'should get a nil "kind" for an invalid package spec' do# {{{
    text = 'create package  as g_var integer; end;'
    Parser::SpecRegion.probe(text)[:kind].should be_nil

    text = 'package muci declare g_var integer; end;'
    Parser::SpecRegion.probe(text)[:kind].should be_nil
  end# }}}

  it 'should detect a package body' do# {{{
    text = 'create or replace package body scott.text as g_var integer; end;'
    Parser::PackageBodyRegion.probe(text).should == {:name => 'scott.text', 
                                                     :kind => :package_body,
                                                     :name_pos => 31,
                                                     :pointer => 44}

    text = 'create or replace package body test as g_var integer; end;'
    Parser::PackageBodyRegion.probe(text).should == {:name => 'test', 
                                                     :kind => :package_body,
                                                     :name_pos => 31,
                                                     :pointer => 38}

    text = 'create package body test as g_var integer; end;'
    Parser::PackageBodyRegion.probe(text).should == {:name => 'test', 
                                                     :kind => :package_body,
                                                     :name_pos => 20,
                                                     :pointer => 27}

    text = 'package body test as g_var integer; end;'
    Parser::PackageBodyRegion.probe(text).should == {:name => 'test', 
                                                     :kind => :package_body,
                                                     :name_pos => 13,
                                                     :pointer => 20}
  end# }}}

  it 'should get a nil "kind" for an invalid package body' do# {{{
    text = 'create package body  as g_var integer; end;'
    Parser::PackageBodyRegion.probe(text)[:kind].should be_nil

    text = 'package body muci declare g_var integer; end;'
    Parser::PackageBodyRegion.probe(text)[:kind].should be_nil
  end# }}}

  it 'should probe a valid type body' do# {{{
    text = 'create or replace type body scott.text as g_var integer; end;'
    Parser::TypeBodyRegion.probe(text).should == {:name => 'scott.text', 
                                                  :kind => :type_body,
                                                  :name_pos => 28,
                                                  :pointer => 41}

    text = 'create or replace type body test as g_var integer; end;'
    Parser::TypeBodyRegion.probe(text).should == {:name => 'test', 
                                                  :kind => :type_body,
                                                  :name_pos => 28,
                                                  :pointer => 35}

    text = 'create type body test as g_var integer; end;'
    Parser::TypeBodyRegion.probe(text).should == {:name => 'test', 
                                                  :kind => :type_body,
                                                  :name_pos => 17,
                                                  :pointer => 24}

    text = 'type body test as g_var integer; end;'
    Parser::TypeBodyRegion.probe(text).should == {:name => 'test', 
                                                  :kind => :type_body,
                                                  :name_pos => 10,
                                                  :pointer => 17}
  end# }}}

  it 'should get a nil "kind" for an invalid type spec' do# {{{
    text = 'create type as g_var integer; end;'
    Parser::TypeBodyRegion.probe(text)[:kind].should be_nil

    text = 'type body muci declare g_var integer; end;'
    Parser::TypeBodyRegion.probe(text)[:kind].should be_nil
  end# }}}

  it 'should get the name of the function/procedure' do# {{{
    text = 'create function /* comment */ muci as begin null; end;'
    Parser::SubprogRegion.probe(text).should == {:name => 'muci', 
                                                 :kind => :function, 
                                                 :name_pos => 30}

    text = 'create or replace procedure test(p1 boolean) as begin null; end;'
    Parser::SubprogRegion.probe(text).should == {:name => 'test', 
                                                 :kind => :procedure, 
                                                 :name_pos => 28}

    text = 'function test(p1 boolean) return boolean;'
    Parser::SubprogRegion.probe(text).should == {:name => 'test', 
                                                 :kind => :function, 
                                                 :name_pos => 9}
  end# }}}

  it 'should know how to handle type body members' do# {{{
    text = 'CONSTRUCTOR FUNCTION PartyConvertor RETURN SELF AS RESULT AS BEGIN self.setUpCommonFoo; RETURN; END;'
    Parser::SubprogRegion.probe(text).should == {:name => "PartyConvertor", 
                                                 :kind => :function, 
                                                 :name_pos => 21}

    text = "member procedure setUpCommonFoo is begin SELF.someAttrib:='Some Common Default Value'; end;"
    Parser::SubprogRegion.probe(text).should == {:name => "setUpCommonFoo", 
                                                 :kind => :procedure, 
                                                 :name_pos=>17}

    text = "MAP MEMBER FUNCTION area RETURN NUMBER IS BEGIN RETURN len * wid; END area;"
    Parser::SubprogRegion.probe(text).should == {:name => "area", 
                                                 :kind => :function, 
                                                 :name_pos => 20}

    text = "STATIC FUNCTION show_super (person_obj in person_typ) RETURN VARCHAR2 IS BEGIN RETURN 'Id: ' || TO_CHAR(person_obj.idno) || ', Name: ' || person_obj.name; END;"
    Parser::SubprogRegion.probe(text).should == {:name => "show_super", 
                                                 :kind => :function, 
                                                 :name_pos => 16}

    text = "ORDER MEMBER FUNCTION match (l location_typ) RETURN INTEGER IS BEGIN null; end;"
    Parser::SubprogRegion.probe(text).should == {:name => "match", 
                                                 :kind => :function, 
                                                 :name_pos => 22}

    text = "OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 is begin null; end;"
    Parser::SubprogRegion.probe(text).should == {:name => "to_string", 
                                                 :kind => :function, 
                                                 :name_pos=>27}
  end# }}}

  it 'should get a null subprog name for an invalid function or procedure' do# {{{
    text = 'create function /* comment */  as begin null; end;'
    Parser::SubprogRegion.probe(text)[:name].should be_nil

    text = 'create function /* comment */  begin null; end;'
    Parser::SubprogRegion.probe(text)[:name].should be_nil
  end# }}}

  it 'should detect a for..loop' do# {{{
    text = 'for i in (select * from dual) loop nil end loop;'
    Parser::ForRegion.probe(text).should == {:variable => "i", 
                                             :domain_type => :expr, 
                                             :variable_position => 4,
                                             :domain => "(select * from dual)", 
                                             :pointer => 34}

    text = 'for l_rec in package.g_cursor loop nil end loop;'
    Parser::ForRegion.probe(text).should == {:variable => "l_rec", 
                                             :domain_type => :cursor_var, 
                                             :variable_position => 4,
                                             :domain => "package.g_cursor", 
                                             :pointer=>34}

    text = 'for l_rec in 1..100 loop nil end loop;'
    Parser::ForRegion.probe(text).should == {:variable => "l_rec", 
                                             :domain_type => :counter, 
                                             :variable_position => 4,
                                             :domain => nil, 
                                             :pointer=>24} 
  end# }}}

  it 'should get a null pointer for an invalid for..loop statement' do# {{{
    text = 'for in 1..100 loop nil end loop;'
    Parser::ForRegion.probe(text)[:pointer].should be_nil

    text = 'for x in (select * from dual loop nil end loop;'
    Parser::ForRegion.probe(text)[:pointer].should be_nil
  end# }}}

  it 'should detect the end marker' do# {{{
    text = 'end "abc";'
    Parser::Region.probe_end(text).should == {:kind => :end, :pointer => 9}

    text = 'end abc;'
    Parser::Region.probe_end(text).should == {:kind => :end, :pointer => 7}

    text = 'end;'
    Parser::Region.probe_end(text).should == {:kind => :end, :pointer => 3}

    text = 'end /*muci*/ if;'
    Parser::Region.probe_end(text).should == {:kind => :end_if, :pointer => 15}

    text = 'end loop/*test*/;'
    Parser::Region.probe_end(text).should == {:kind => :end_loop, :pointer => 16}
  end# }}}

  it 'should get a nil pointer for an invalid "end" definition' do# {{{
    text = 'en d /*test*/;'
    Parser::Region.probe_end(text)[:pointer].should be_nil

    text = 'end i f;'
    Parser::Region.probe_end(text)[:pointer].should be_nil
  end# }}}

  it 'should compute the items of a spec region' do# {{{
    text = File.open('spec/sql/dbms_crypto.spc', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children.first.content
    expected = [Parser::ConstantItem.new(1364, "HASH_MD4", "PLS_INTEGER"),
                Parser::ConstantItem.new(1430, "HASH_MD5", "PLS_INTEGER"),
                Parser::ConstantItem.new(1496, "HASH_SH1", "PLS_INTEGER"),
                Parser::ConstantItem.new(1586, "HMAC_MD5", "PLS_INTEGER"),
                Parser::ConstantItem.new(1652, "HMAC_SH1", "PLS_INTEGER"),
                Parser::ConstantItem.new(1752, "ENCRYPT_DES", "PLS_INTEGER"),
                Parser::ConstantItem.new(1829, "ENCRYPT_3DES_2KEY", "PLS_INTEGER"),
                Parser::ConstantItem.new(1906, "ENCRYPT_3DES", "PLS_INTEGER"),
                Parser::ConstantItem.new(1983, "ENCRYPT_AES", "PLS_INTEGER"),
                Parser::ConstantItem.new(2060, "ENCRYPT_PBE_MD5DES", "PLS_INTEGER"),
                Parser::ConstantItem.new(2137, "ENCRYPT_AES128", "PLS_INTEGER"),
                Parser::ConstantItem.new(2214, "ENCRYPT_AES192", "PLS_INTEGER"),
                Parser::ConstantItem.new(2291, "ENCRYPT_AES256", "PLS_INTEGER"),
                Parser::ConstantItem.new(2410, "CHAIN_CBC", "PLS_INTEGER"),
                Parser::ConstantItem.new(2487, "CHAIN_CFB", "PLS_INTEGER"),
                Parser::ConstantItem.new(2564, "CHAIN_ECB", "PLS_INTEGER"),
                Parser::ConstantItem.new(2641, "CHAIN_OFB", "PLS_INTEGER"),
                Parser::ConstantItem.new(2759, "PAD_PKCS5", "PLS_INTEGER"),
                Parser::ConstantItem.new(2836, "PAD_NONE", "PLS_INTEGER"),
                Parser::ConstantItem.new(2913, "PAD_ZERO", "PLS_INTEGER"),
                Parser::ConstantItem.new(2990, "PAD_ORCL", "PLS_INTEGER"),
                Parser::ConstantItem.new(3102, "ENCRYPT_RC4", "PLS_INTEGER"),
                Parser::ConstantItem.new(3231, "DES_CBC_PKCS5", "PLS_INTEGER"),
                Parser::ConstantItem.new(3447, "DES3_CBC_PKCS5", "PLS_INTEGER"),
                Parser::ConstantItem.new(3664, "AES_CBC_PKCS5", "PLS_INTEGER"),
                Parser::ExceptionItem.new(3992, "CipherSuiteInvalid"),
                Parser::ExceptionItem.new(4111, "CipherSuiteNull"),
                Parser::ExceptionItem.new(4218, "KeyNull"),
                Parser::ExceptionItem.new(4321, "KeyBadSize"),
                Parser::ExceptionItem.new(4432, "DoubleEncryption"),
                Parser::FunctionItem.new(6490, "FUNCTION  Encrypt (src IN            RAW,\r\n                       typ IN            PLS_INTEGER,\r\n                       key IN            RAW,\r\n                       iv  IN            RAW          DEFAULT NULL)\r\n      RETURN RAW; "),
                Parser::ProcedureItem.new(6729, "PROCEDURE Encrypt (dst IN OUT NOCOPY BLOB,\r\n                       src IN            BLOB,\r\n                       typ IN            PLS_INTEGER,\r\n                       key IN            RAW,\r\n                       iv  IN            RAW          DEFAULT NULL); "),
                Parser::ProcedureItem.new(6999, "PROCEDURE Encrypt (dst IN OUT NOCOPY BLOB,\r\n                       src IN            CLOB         CHARACTER SET ANY_CS,\r\n                       typ IN            PLS_INTEGER,\r\n                       key IN            RAW,\r\n                       iv  IN            RAW          DEFAULT NULL); "),
                Parser::FunctionItem.new(8291, "FUNCTION  Decrypt (src IN            RAW,\r\n                       typ IN            PLS_INTEGER,\r\n                       key IN            RAW,\r\n                       iv  IN            RAW          DEFAULT NULL)\r\n       RETURN RAW; "),
                Parser::ProcedureItem.new(8531, "PROCEDURE Decrypt (dst IN OUT NOCOPY BLOB,\r\n                       src IN            BLOB,\r\n                       typ IN            PLS_INTEGER,\r\n                       key IN            RAW,\r\n                       iv  IN            RAW          DEFAULT NULL); "),
                Parser::ProcedureItem.new(8801, "PROCEDURE Decrypt (dst IN OUT NOCOPY CLOB         CHARACTER SET ANY_CS,\r\n                       src IN            BLOB,\r\n                       typ IN            PLS_INTEGER,\r\n                       key IN            RAW,\r\n                       iv  IN            RAW          DEFAULT NULL); "),
                Parser::FunctionItem.new(9673, "FUNCTION Hash (src IN RAW,\r\n                   typ IN PLS_INTEGER)\r\n      RETURN RAW DETERMINISTIC; "),
                Parser::FunctionItem.new(9780, "FUNCTION Hash (src IN BLOB,\r\n                   typ IN PLS_INTEGER)\r\n      RETURN RAW DETERMINISTIC; "),
                Parser::FunctionItem.new(9888, "FUNCTION Hash (src IN CLOB        CHARACTER SET ANY_CS,\r\n                   typ IN PLS_INTEGER)\r\n      RETURN RAW DETERMINISTIC; "),
                Parser::FunctionItem.new(10654, "FUNCTION Mac (src IN RAW,\r\n                  typ IN PLS_INTEGER,\r\n                  key IN RAW)\r\n      RETURN RAW; "),
                Parser::FunctionItem.new(10776, "FUNCTION Mac (src IN BLOB,\r\n                  typ IN PLS_INTEGER,\r\n                  key IN RAW)\r\n      RETURN RAW; "),
                Parser::FunctionItem.new(10899, "FUNCTION Mac (src IN CLOB         CHARACTER SET ANY_CS,\r\n                  typ IN PLS_INTEGER,\r\n                  key IN RAW)\r\n      RETURN RAW; "),
                Parser::FunctionItem.new(11572, "FUNCTION RandomBytes (number_bytes IN PLS_INTEGER)\r\n      RETURN RAW; "),
                Parser::FunctionItem.new(11980, "FUNCTION RandomNumber\r\n      RETURN NUMBER; "),
                Parser::FunctionItem.new(12364, "FUNCTION RandomInteger\r\n      RETURN BINARY_INTEGER; ")
    ]
    region.declared_items.should == expected
  end# }}}

  it 'should get all items types from a package spec' do# {{{
    text = File.open('spec/sql/muci.spc', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children.first.content
    expected = [Parser::ConstantItem.new(40, "MY_CONSTANT1", "varchar2"),
                Parser::ConstantItem.new(88, "MY_CONSTANT2", "integer"),
                Parser::ExceptionItem.new(128, "ex_no_data_found"),
                Parser::ExceptionItem.new(210, "ex_custom"),
                Parser::CursorItem.new(285, "my_cursor", "cursor my_cursor is\n    select * from user_tables;"),
                Parser::TypeItem.new(337, "population_type", "table", "type population_type is table of varchar2(100);"),
                Parser::VariableItem.new(383, "g_var1", "integer"),
                Parser::VariableItem.new(401, "g_var2", "varchar2"),
                Parser::VariableItem.new(434, "g_var3", "dual.dummy%type"),
                Parser::VariableItem.new(460, "g_var4", "all_objects%rowtype"),
                Parser::ProcedureItem.new(501, "procedure my_proc(p1 integer); "),
                Parser::FunctionItem.new(533, "function my_func(param1 varchar2, param2 boolean := true) return boolean; "),
                Parser::TypeItem.new(609, "id", "varchar2", "subtype id is varchar2(10);")]
    region.declared_items.should == expected
  end# }}}

  it 'should work with a big package spec' do# {{{
    text = File.open('spec/sql/dbms_stats.spc', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children.first.content
    region.declared_items.include?(Parser::TypeItem.new(9280, "numarray", "varray", "type numarray is varray(256) of number;")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(9321, "datearray", "varray", "type datearray is varray(256) of date;")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(9361, "chararray", "varray", "type chararray is varray(256) of varchar2(4000);")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(9411, "rawarray",  "varray", "type rawarray is varray(256) of raw(2000);")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(9455, "fltarray",  "varray", "type fltarray is varray(256) of binary_float;")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(9502, "dblarray",  "varray", "type dblarray is varray(256) of binary_double;")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(9552, "StatRec",  "record", "type StatRec is record (\r\n  epc    number,\r\n  minval raw(2000),\r\n  maxval raw(2000),\r\n  bkvals numarray,\r\n  novals numarray,\r\n  chvals chararray,\r\n  eavs   number);")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(9855, "ObjectElem",  "record", "type ObjectElem is record (\r\n  ownname     varchar2(32),        objtype     varchar2(6),         objname     varchar2(32),        partname    varchar2(32),        subpartname varchar2(32)       );")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(10128, "ObjectTab",  "table", "type ObjectTab is table of ObjectElem;")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(10220, "DiffRepElem",  "record", "type DiffRepElem is record (\r\n  report     clob,                 maxdiffpct number);")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(10380, "DiffRepTab",  "table", "type DiffRepTab is table of DiffRepElem;")).should be_true
    region.declared_items.include?(Parser::TypeItem.new(10481, "CContext",  "varray", "type CContext is varray(10) of varchar2(100);")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(10588, "AUTO_CASCADE",  "BOOLEAN")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(10686, "AUTO_INVALIDATE",  "BOOLEAN")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(10809, "AUTO_SAMPLE_SIZE",  "NUMBER")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(10986, "DEFAULT_DEGREE",  "NUMBER")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11159, "AUTO_DEGREE",  "NUMBER")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11427, "DEFAULT_CASCADE",  "BOOLEAN")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11480, "DEFAULT_DEGREE_VALUE",  "NUMBER")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11534, "DEFAULT_ESTIMATE_PERCENT",  "NUMBER")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11586, "DEFAULT_METHOD_OPT",  "VARCHAR2")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11641, "DEFAULT_NO_INVALIDATE",  "BOOLEAN")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11697, "DEFAULT_GRANULARITY",  "VARCHAR2")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11752, "DEFAULT_PUBLISH",  "BOOLEAN")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11808, "DEFAULT_INCREMENTAL",  "BOOLEAN")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11865, "DEFAULT_STALE_PERCENT",  "NUMBER")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11919, "DEFAULT_AUTOSTATS_TARGET",  "VARCHAR2")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(11974, "DEFAULT_STAT_CATEGORY",  "VARCHAR2")).should be_true
    region.declared_items.include?(Parser::ConstantItem.new(12173, "PURGE_ALL",  "TIMESTAMP")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(12939, "procedure prepare_column_values(\r\n        srec in out StatRec, charvals chararray);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(13104, "procedure prepare_column_values(\r\n        srec in out StatRec, datevals datearray);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(13269, "procedure prepare_column_values(\r\n        srec in out StatRec, numvals numarray);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(13432, "procedure prepare_column_values(\r\n        srec in out StatRec, fltvals fltarray);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(13595, "procedure prepare_column_values(\r\n        srec in out StatRec, dblvals dblarray);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(13758, "procedure prepare_column_values(\r\n        srec in out StatRec, rawvals rawarray);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(13921, "procedure prepare_column_values_nvarchar(\r\n        srec in out StatRec, nvmin nvarchar2, nvmax nvarchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(14109, "procedure prepare_column_values_rowid(\r\n        srec in out StatRec, rwmin rowid, rwmax rowid);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(17277, "procedure set_param(\r\n    pname in varchar2,\r\n    pval  in varchar2);")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(19598, "function get_param(\r\n    pname   in varchar2)\r\n  return varchar2;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(20025, "procedure reset_param_defaults;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(20345, "procedure reset_global_pref_defaults;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(20466, "procedure set_global_prefs(\r\n    pname   varchar2,\r\n    pvalue  varchar2);")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(25627, "function get_prefs(\r\n    pname   in varchar2,\r\n    ownname in varchar2 default null,\r\n    tabname in varchar2 default null)\r\n  return varchar2;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(26689, "procedure set_table_prefs(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    pname   varchar2,\r\n    pvalue  varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(28158, "procedure delete_table_prefs(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    pname   varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(29325, "procedure export_table_prefs(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    stattab varchar2,\r\n    statid  varchar2 default null,\r\n    statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(30383, "procedure import_table_prefs(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    stattab varchar2,\r\n    statid  varchar2 default null,\r\n    statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(31460, "procedure set_schema_prefs(\r\n    ownname varchar2,\r\n    pname   varchar2,\r\n    pvalue  varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(32921, "procedure delete_schema_prefs(\r\n    ownname varchar2,\r\n    pname   varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(34159, "procedure export_schema_prefs(\r\n    ownname varchar2,\r\n    stattab varchar2,\r\n    statid  varchar2 default null,\r\n    statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(35162, "procedure import_schema_prefs(\r\n    ownname varchar2,\r\n    stattab varchar2,\r\n    statid  varchar2 default null,\r\n    statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(36202, "procedure set_database_prefs(\r\n    pname   varchar2,\r\n    pvalue  varchar2,\r\n    add_sys boolean default false);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(37701, "procedure delete_database_prefs(\r\n    pname   varchar2,\r\n    add_sys boolean default false);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(38967, "procedure export_database_prefs(\r\n    stattab varchar2,\r\n    statid  varchar2 default null,\r\n    statown varchar2 default null,\r\n    add_sys boolean  default false);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(39974, "procedure import_database_prefs(\r\n    stattab varchar2,\r\n    statid  varchar2 default null,\r\n    statown varchar2 default null,\r\n    add_sys boolean  default false);")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(41041, "function to_cascade_type(cascade varchar2) return boolean;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(41103, "function to_estimate_percent_type(estimate_percent varchar2) return number;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(41182, "function to_degree_type(degree varchar2) return number;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(41241, "function to_no_invalidate_type(no_invalidate varchar2) return boolean;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(41315, "function to_publish_type(publish varchar2) return boolean;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(41378, "procedure init_package;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(41461, "procedure publish_pending_stats(\r\n    ownname varchar2 default USER,\r\n    tabname varchar2,\r\n    no_invalidate boolean default\r\n      to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n    force   boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(42826, "procedure export_pending_stats(\r\n    ownname varchar2 default USER,\r\n    tabname varchar2,\r\n    stattab varchar2,\r\n    statid  varchar2 default null,\r\n    statown varchar2 default USER);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(43985, "procedure delete_pending_stats(\r\n    ownname varchar2 default USER,\r\n    tabname varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(44849, "procedure resume_gather_stats;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(45381, "procedure set_column_stats(\r\n        ownname varchar2, tabname varchar2, colname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        distcnt number default null, density number default null,\r\n        nullcnt number default null, srec StatRec default null,\r\n        avgclen number default null, flags number default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(45965, "procedure set_column_stats(\r\n        ownname varchar2, tabname varchar2, colname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        ext_stats raw,\r\n        stattypown varchar2 default null,\r\n        stattypname varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(48682, "procedure set_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        numrows number default null, numlblks number default null,\r\n        numdist number default null, avglblk number default null,\r\n        avgdblk number default null, clstfct number default null,\r\n        indlevel number default null, flags number default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        guessq number default null,\r\n        cachedblk number default null,\r\n        cachehit number default null,\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(49434, "procedure set_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        ext_stats raw,\r\n        stattypown varchar2 default null,\r\n        stattypname varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(52538, "procedure set_table_stats(\r\n        ownname varchar2,\r\n        tabname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null,\r\n        statid varchar2 default null,\r\n        numrows number default null,\r\n        numblks number default null,\r\n        avgrlen number default null,\r\n        flags number default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        cachedblk number default null,\r\n        cachehit number default null,\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(54834, "procedure convert_raw_value(\r\n        rawval raw, resval out varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(54983, "procedure convert_raw_value(\r\n        rawval raw, resval out date);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(55128, "procedure convert_raw_value(\r\n        rawval raw, resval out number);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(55275, "procedure convert_raw_value(\r\n        rawval raw, resval out binary_float);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(55428, "procedure convert_raw_value(\r\n        rawval raw, resval out binary_double);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(55582, "procedure convert_raw_value_nvarchar(\r\n        rawval raw, resval out nvarchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(55780, "procedure convert_raw_value_rowid(\r\n        rawval raw, resval out rowid);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(56428, "procedure get_column_stats(\r\n        ownname varchar2, tabname varchar2, colname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        distcnt out number, density out number,\r\n        nullcnt out number, srec out StatRec,\r\n        avgclen out number,\r\n        statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(56801, "procedure get_column_stats(\r\n        ownname varchar2, tabname varchar2, colname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        ext_stats out raw,\r\n        stattypown out varchar2, stattypname out varchar2,\r\n        statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(58796, "procedure get_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        numrows out number, numlblks out number,\r\n        numdist out number, avglblk out number,\r\n        avgdblk out number, clstfct out number,\r\n        indlevel out number,\r\n        statown varchar2 default null,\r\n        guessq out number,\r\n        cachedblk out number,\r\n        cachehit out number);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(59292, "procedure get_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        numrows out number, numlblks out number,\r\n        numdist out number, avglblk out number,\r\n        avgdblk out number, clstfct out number,\r\n        indlevel out number,\r\n        statown varchar2 default null,\r\n        guessq out number);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(59727, "procedure get_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        numrows out number, numlblks out number,\r\n        numdist out number, avglblk out number,\r\n        avgdblk out number, clstfct out number,\r\n        indlevel out number,\r\n        statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(60134, "procedure get_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        ext_stats out raw,\r\n        stattypown out varchar2, stattypname out varchar2,\r\n        statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(62363, "procedure get_table_stats(\r\n        ownname varchar2, tabname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        numrows out number, numblks out number,\r\n        avgrlen out number,\r\n        statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(62670, "procedure get_table_stats(\r\n        ownname varchar2,\r\n        tabname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null,\r\n        statid varchar2 default null,\r\n        numrows out number,\r\n        numblks out number,\r\n        avgrlen out number,\r\n        statown varchar2 default null,\r\n        cachedblk out number,\r\n        cachehit out number);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(64316, "procedure delete_column_stats(\r\n        ownname varchar2, tabname varchar2, colname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        cascade_parts boolean default true,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE,\r\n        col_stat_type varchar2 default 'ALL');")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(66718, "procedure delete_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        cascade_parts boolean default true,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        stattype varchar2 default 'ALL',\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(68766, "procedure delete_table_stats(\r\n        ownname varchar2, tabname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        cascade_parts boolean default true,\r\n        cascade_columns boolean default true,\r\n        cascade_indexes boolean default true,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        stattype varchar2 default 'ALL',\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(71275, "procedure delete_schema_stats(\r\n        ownname varchar2,\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        stattype varchar2 default 'ALL',\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(72953, "procedure delete_database_stats(\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        stattype varchar2 default 'ALL',\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(75567, "procedure create_stat_table(\r\n        ownname varchar2, stattab varchar2,\r\n        tblspace varchar2 default null,\r\n        global_temporary boolean default false);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(76697, "procedure drop_stat_table(\r\n        ownname varchar2, stattab varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(77072, "procedure upgrade_stat_table(\r\n        ownname varchar2, stattab varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(77387, "procedure export_column_stats(\r\n        ownname varchar2, tabname varchar2, colname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(78534, "procedure export_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(79579, "procedure export_table_stats(\r\n        ownname varchar2, tabname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2, statid varchar2 default null,\r\n        cascade boolean default true,\r\n        statown varchar2 default null,\r\n        stat_category varchar2 default DEFAULT_STAT_CATEGORY\r\n);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(81160, "procedure export_schema_stats(\r\n        ownname varchar2,\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        stat_category varchar2 default DEFAULT_STAT_CATEGORY);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(82269, "procedure export_database_stats(\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        stat_category varchar2 default DEFAULT_STAT_CATEGORY);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(83418, "procedure import_column_stats(\r\n        ownname varchar2, tabname varchar2, colname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(85266, "procedure import_index_stats(\r\n        ownname varchar2, indname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(87020, "procedure import_table_stats(\r\n        ownname varchar2, tabname varchar2,\r\n        partname varchar2 default null,\r\n        stattab varchar2, statid varchar2 default null,\r\n        cascade boolean default true,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE,\r\n        stat_category varchar2 default DEFAULT_STAT_CATEGORY);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(89428, "procedure import_schema_stats(\r\n        ownname varchar2,\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE,\r\n        stat_category varchar2 default DEFAULT_STAT_CATEGORY);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(91980, "procedure import_database_stats(\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE,\r\n        stat_category varchar2 default DEFAULT_STAT_CATEGORY\r\n        );")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(85129, "procedure gather_index_stats\r\n    (ownname varchar2, indname varchar2, partname varchar2 default null,\r\n     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,\r\n     stattab varchar2 default null, statid varchar2 default null,\r\n     statown varchar2 default null,\r\n     degree number default to_degree_type(get_param('DEGREE')),\r\n     granularity varchar2 default DEFAULT_GRANULARITY,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n     stattype varchar2 default 'DATA',\r\n     force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(98534, "procedure gather_table_stats\r\n    (ownname varchar2, tabname varchar2, partname varchar2 default null,\r\n     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,\r\n     block_sample boolean default FALSE,\r\n     method_opt varchar2 default DEFAULT_METHOD_OPT,\r\n     degree number default to_degree_type(get_param('DEGREE')),\r\n     granularity varchar2 default  DEFAULT_GRANULARITY,\r\n     cascade boolean default DEFAULT_CASCADE,\r\n     stattab varchar2 default null, statid varchar2 default null,\r\n     statown varchar2 default null,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n     stattype varchar2 default 'DATA',\r\n     force boolean default FALSE,\r\n     -- the context is intended for internal use only.\r\n     context dbms_stats.CContext default null); ")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(105865, "procedure gather_schema_stats\r\n    (ownname varchar2,\r\n     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,\r\n     block_sample boolean default FALSE,\r\n     method_opt varchar2 default  DEFAULT_METHOD_OPT,\r\n     degree number default to_degree_type(get_param('DEGREE')),\r\n     granularity varchar2 default DEFAULT_GRANULARITY,\r\n     cascade boolean default DEFAULT_CASCADE,\r\n     stattab varchar2 default null, statid varchar2 default null,\r\n     options varchar2 default 'GATHER', objlist out ObjectTab,\r\n     statown varchar2 default null,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n     gather_temp boolean default FALSE,\r\n     gather_fixed boolean default FALSE,\r\n     stattype varchar2 default 'DATA',\r\n     force boolean default FALSE,\r\n     obj_filter_list ObjectTab default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(106719, "procedure gather_schema_stats\r\n    (ownname varchar2,\r\n     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,\r\n     block_sample boolean default FALSE,\r\n     method_opt varchar2 default DEFAULT_METHOD_OPT,\r\n     degree number default to_degree_type(get_param('DEGREE')),\r\n     granularity varchar2 default DEFAULT_GRANULARITY,\r\n     cascade boolean default DEFAULT_CASCADE,\r\n     stattab varchar2 default null, statid varchar2 default null,\r\n     options varchar2 default 'GATHER', statown varchar2 default null,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n     gather_temp boolean default FALSE,\r\n     gather_fixed boolean default FALSE,\r\n     stattype varchar2 default 'DATA',\r\n     force boolean default FALSE,\r\n     obj_filter_list ObjectTab default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(113698, "procedure gather_database_stats\r\n    (estimate_percent number default DEFAULT_ESTIMATE_PERCENT,\r\n     block_sample boolean default FALSE,\r\n     method_opt varchar2 default DEFAULT_METHOD_OPT,\r\n     degree number default to_degree_type(get_param('DEGREE')),\r\n     granularity varchar2 default DEFAULT_GRANULARITY,\r\n     cascade boolean default DEFAULT_CASCADE,\r\n     stattab varchar2 default null, statid varchar2 default null,\r\n     options varchar2 default 'GATHER', objlist out ObjectTab,\r\n     statown varchar2 default null,\r\n     gather_sys boolean default TRUE,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n     gather_temp boolean default FALSE,\r\n     gather_fixed boolean default FALSE,\r\n     stattype varchar2 default 'DATA',\r\n     obj_filter_list ObjectTab default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(114533, "procedure gather_database_stats\r\n    (estimate_percent number default DEFAULT_ESTIMATE_PERCENT,\r\n     block_sample boolean default FALSE,\r\n     method_opt varchar2 default DEFAULT_METHOD_OPT,\r\n     degree number default to_degree_type(get_param('DEGREE')),\r\n     granularity varchar2 default DEFAULT_GRANULARITY,\r\n     cascade boolean default DEFAULT_CASCADE,\r\n     stattab varchar2 default null, statid varchar2 default null,\r\n     options varchar2 default 'GATHER', statown varchar2 default null,\r\n     gather_sys boolean default TRUE,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n     gather_temp boolean default FALSE,\r\n     gather_fixed boolean default FALSE,\r\n     stattype varchar2 default 'DATA',\r\n     obj_filter_list ObjectTab default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(122691, "procedure generate_stats\r\n    (ownname varchar2, objname varchar2,\r\n     organized number default 7,\r\n     force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(124835, "procedure flush_database_monitoring_info;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(125030, "procedure alter_schema_tab_monitoring\r\n  (ownname varchar2 default NULL, monitoring boolean default TRUE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(125138, "procedure alter_database_tab_monitoring\r\n  (monitoring boolean default TRUE, sysobjs boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(125254, "procedure gather_system_stats (\r\n  gathering_mode  varchar2 default 'NOWORKLOAD',\r\n  interval  integer  default 60,\r\n  stattab   varchar2 default null,\r\n  statid    varchar2 default null,\r\n  statown   varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(126869, "procedure get_system_stats (\r\n   status     out   varchar2,\r\n   dstart     out   date,\r\n   dstop      out   date,\r\n   pname            varchar2,\r\n   pvalue     out   number,\r\n   stattab          varchar2 default null,\r\n   statid           varchar2 default null,\r\n   statown          varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(128384, "procedure set_system_stats (\r\n   pname            varchar2,\r\n   pvalue           number,\r\n   stattab          varchar2 default null,\r\n   statid           varchar2 default null,\r\n   statown          varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(129383, "procedure delete_system_stats (\r\n   stattab         varchar2  default nulL,\r\n   statid          varchar2  default nulL,\r\n   statown         varchar2  default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(130179, "procedure import_system_stats (\r\n   stattab  varchar2,\r\n   statid   varchar2 default null,\r\n   statown  varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(131306, "procedure export_system_stats (\r\n   stattab  varchar2,\r\n   statid   varchar2 default null,\r\n   statown  varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(132049, "procedure gather_fixed_objects_stats\r\n    (stattab varchar2 default null, statid varchar2 default null,\r\n     statown varchar2 default null,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')));")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(133267, "procedure delete_fixed_objects_stats(\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n        to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(134742, "procedure export_fixed_objects_stats(\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(135526, "procedure import_fixed_objects_stats(\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n           to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(137500, "procedure gather_dictionary_stats\r\n    (comp_id varchar2 default null,\r\n     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,\r\n     block_sample boolean default FALSE,\r\n     method_opt varchar2 default DEFAULT_METHOD_OPT,\r\n     degree number default to_degree_type(get_param('DEGREE')),\r\n     granularity varchar2 default DEFAULT_GRANULARITY,\r\n     cascade boolean default DEFAULT_CASCADE,\r\n     stattab varchar2 default null, statid varchar2 default null,\r\n     options varchar2 default 'GATHER AUTO', objlist out ObjectTab,\r\n     statown varchar2 default null,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n     stattype varchar2 default 'DATA',\r\n     obj_filter_list ObjectTab default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(138257, "procedure gather_dictionary_stats\r\n    (comp_id varchar2 default null,\r\n     estimate_percent number default DEFAULT_ESTIMATE_PERCENT,\r\n     block_sample boolean default FALSE,\r\n     method_opt varchar2 default DEFAULT_METHOD_OPT,\r\n     degree number default to_degree_type(get_param('DEGREE')),\r\n     granularity varchar2 default DEFAULT_GRANULARITY,\r\n     cascade boolean default DEFAULT_CASCADE,\r\n     stattab varchar2 default null, statid varchar2 default null,\r\n     options varchar2 default 'GATHER AUTO', statown varchar2 default null,\r\n     no_invalidate boolean default\r\n       to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n     stattype varchar2 default 'DATA',\r\n     obj_filter_list ObjectTab default null);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(144713, "procedure delete_dictionary_stats(\r\n        stattab varchar2 default null, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        stattype varchar2 default 'ALL',\r\n        force boolean default FALSE);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(146515, "procedure export_dictionary_stats(\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        stat_category varchar2 default DEFAULT_STAT_CATEGORY);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(147711, "procedure import_dictionary_stats(\r\n        stattab varchar2, statid varchar2 default null,\r\n        statown varchar2 default null,\r\n        no_invalidate boolean default\r\n          to_no_invalidate_type(get_param('NO_INVALIDATE')),\r\n        force boolean default FALSE,\r\n        stat_category varchar2 default DEFAULT_STAT_CATEGORY);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(150318, "procedure lock_table_stats(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    stattype varchar2 default 'ALL');")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(150835, "procedure lock_partition_stats(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    partname varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(151173, "procedure lock_schema_stats(\r\n    ownname varchar2,\r\n    stattype varchar2 default 'ALL');")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(151653, "procedure unlock_table_stats(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    stattype varchar2 default 'ALL');")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(152184, "procedure unlock_partition_stats(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    partname varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(152524, "procedure unlock_schema_stats(\r\n    ownname varchar2,\r\n    stattype varchar2 default 'ALL');")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(153014, "procedure restore_table_stats(\r\n    ownname varchar2,\r\n    tabname varchar2,\r\n    as_of_timestamp timestamp with time zone,\r\n    restore_cluster_index boolean default FALSE,\r\n    force boolean default FALSE,\r\n    no_invalidate boolean default\r\n      to_no_invalidate_type(get_param('NO_INVALIDATE')));")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(155390, "procedure restore_schema_stats(\r\n    ownname varchar2,\r\n    as_of_timestamp timestamp with time zone,\r\n    force boolean default FALSE,\r\n    no_invalidate boolean default\r\n      to_no_invalidate_type(get_param('NO_INVALIDATE')));")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(156590, "procedure restore_database_stats(\r\n    as_of_timestamp timestamp with time zone,\r\n    force boolean default FALSE,\r\n    no_invalidate boolean default\r\n      to_no_invalidate_type(get_param('NO_INVALIDATE')));")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(157678, "procedure restore_fixed_objects_stats(\r\n    as_of_timestamp timestamp with time zone,\r\n    force boolean default FALSE,\r\n    no_invalidate boolean default\r\n      to_no_invalidate_type(get_param('NO_INVALIDATE')));")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(158863, "procedure restore_dictionary_stats(\r\n    as_of_timestamp timestamp with time zone,\r\n    force boolean default FALSE,\r\n    no_invalidate boolean default\r\n      to_no_invalidate_type(get_param('NO_INVALIDATE')));")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(160135, "procedure restore_system_stats(\r\n    as_of_timestamp timestamp with time zone);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(160629, "procedure purge_stats(\r\n    before_timestamp timestamp with time zone);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(161937, "procedure alter_stats_history_retention(\r\n    retention in number);")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(162887, "function get_stats_history_retention return number;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(163001, "function get_stats_history_availability\r\n             return timestamp with time zone;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(163249, "procedure copy_table_stats(\r\n        ownname varchar2,\r\n        tabname varchar2,\r\n        srcpartname varchar2,\r\n        dstpartname varchar2,\r\n        scale_factor number DEFAULT 1,\r\n        flags number DEFAULT null,\r\n        force boolean DEFAULT FALSE);")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(164679, "function diff_table_stats_in_stattab(\r\n      ownname      varchar2,\r\n      tabname      varchar2,\r\n      stattab1     varchar2,\r\n      stattab2     varchar2 default null,\r\n      pctthreshold number   default 10,\r\n      statid1      varchar2 default null,\r\n      statid2      varchar2 default null,\r\n      stattab1own  varchar2 default null,\r\n      stattab2own  varchar2 default null)\r\n   return DiffRepTab pipelined;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(166052, "function diff_table_stats_in_history(\r\n      ownname      varchar2,\r\n      tabname      varchar2,\r\n      time1        timestamp with time zone,\r\n      time2        timestamp with time zone default null,\r\n      pctthreshold number   default 10)\r\n    return DiffRepTab pipelined;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(166875, "function diff_table_stats_in_pending(\r\n      ownname      varchar2,\r\n      tabname      varchar2,\r\n      time_stamp   timestamp with time zone default null,\r\n      pctthreshold number   default 10)\r\n    return DiffRepTab pipelined;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(167673, "function create_extended_stats(\r\n      ownname    varchar2,\r\n      tabname    varchar2,\r\n      extension  varchar2)\r\n    return varchar2;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(169815, "function create_extended_stats(\r\n      ownname    varchar2,\r\n      tabname    varchar2)\r\n    return clob;")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(170417, "function show_extended_stats_name(\r\n      ownname    varchar2,\r\n      tabname    varchar2,\r\n      extension  varchar2)\r\n    return varchar2;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(171115, "procedure drop_extended_stats(\r\n      ownname    varchar2,\r\n      tabname    varchar2,\r\n      extension  varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(171988, "procedure merge_col_usage(\r\n      dblink varchar2);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(172869, "procedure seed_col_usage(\r\n      sqlset_name IN         VARCHAR2,\r\n      owner_name  IN         VARCHAR2,\r\n      time_limit  IN         POSITIVE DEFAULT NULL);")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(173877, "procedure reset_col_usage(\r\n      ownname      varchar2,\r\n      tabname      varchar2);")).should be_true
    region.declared_items.include?(Parser::FunctionItem.new(174969, "function report_col_usage(\r\n      ownname      varchar2,\r\n      tabname      varchar2)  return clob;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(176871, "procedure gather_database_stats_job_proc;")).should be_true
    region.declared_items.include?(Parser::ProcedureItem.new(176916, "procedure cleanup_stats_job_proc(\r\n      ctx number, job_owner varchar2, job_name varchar2,\r\n      sesid number, sesser number);")).should be_true
  end# }}}

  it 'should get all items for a package body' do# {{{
    text = File.open('spec/sql/test.pkg', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children[1].content
    expected = [Parser::ProcedureItem.new(243, "procedure private_proc(p integer) as\n\n    l_var varchar2(100);\n\n    /* local function */\n    function abc return boolean as\n    begin\n      return true;\n    end;\n    \n    procedure xyz as\n    begin\n      null;\n    end;\n\n  begin\n    l_var := 'abc';\n    for x in (select * from v$session) loop\n      dbms_output.put_line(x.);\n      if x = 'X' then\n        dbms_output.put_line('Great!');\n      end if;\n      if 1 = 0 then\n        if 1 = 1 then\n          for y in (select * from cat) loop\n            dbms_output.put_line(y.table_name);\n            dbms_output.put_line('------------------------------');\n          end loop;\n          dbms_output.put_line('not here ever!');\n        end if;\n        if 1 = 0 then\n          dbms_output.put_line('OMG!');\n        end if;\n      end if;\n      null;\n    end loop;\n    select dummy into l_var from dual;\n    if l_var is not null then\n      dbms_output.put_line('yessss baby!');\n    end if;\n    dbms_output.put_line('a loop is following');\n    loop\n      exit when l_var = 'X';\n      dbms_output.put_line('should not be here');\n    end loop;\n    dbms_output.put_line('that''s all folks!');\n  end;\n ", false).tap { |i| i.name = "private_proc" },
                Parser::VariableItem.new(198, "lg_var_private", "varchar2"),
                Parser::ProcedureItem.new(1383, "procedure test(p1 integer) as\n  begin\n    dbms_output.put_line('just a test');\n    begin\n      null;\n    exception\n      when others then\n        null;\n    end;\n  end;\n ", false).tap { |i| i.name = "test" },
                Parser::FunctionItem.new(1553, "function muci(x varchar2, y clob) return boolean as\n  begin\n    return false;\n  end;\n ", false).tap {|i| i.name="muci"}]
    region.declared_items.should == expected
  end# }}}

  it 'should get all items for a function' do# {{{
    text = File.open('spec/sql/person_type.bdy', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children.first.children.first.content
    expected = [Parser::FunctionItem.new(185, "function my_func(p1 boolean, p2 integer := (1+2)) return boolean as\n\t\tbegin\n\t\t\treturn false;\n\t\tend;\n ", false).tap {|i| i.name="my_func"},
                Parser::VariableItem.new(150, "l_local", "varchar2"),
                Parser::VariableItem.new(279, "l_muci", "integer"),
                Parser::ArgumentItem.new(66, "SELF", :direction=>:inout, :has_default=>false, :data_type=>"shape"),
                Parser::ArgumentItem.new(92, "name", :direction=>:in, :has_default=>false, :data_type=>"VARCHAR2")]
    region.declared_items.should == expected
  end# }}}

  it 'should get all items for a package body' do# {{{
    text = File.open('spec/sql/inter_global.pkg', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children[1].content
    expected = [Parser::ProcedureItem.new(243, "procedure private_proc(p integer) as\n\n    l_var varchar2(100);\n\n    /* local function */\n    function abc return boolean as\n    begin\n      return true;\n    end;\n    \n    procedure xyz as\n    begin\n      null;\n    end;\n\n  begin\n    l_var := 'abc';\n    for x in (select * from v$session) loop\n      dbms_output.put_line(x.);\n      if x = 'X' then\n        dbms_output.put_line('Great!');\n      end if;\n      if 1 = 0 then\n        if 1 = 1 then\n          for y in (select * from cat) loop\n            dbms_output.put_line(y.table_name);\n            dbms_output.put_line('------------------------------');\n          end loop;\n          dbms_output.put_line('not here ever!');\n        end if;\n        if 1 = 0 then\n          dbms_output.put_line('OMG!');\n        end if;\n      end if;\n      null;\n    end loop;\n    select dummy into l_var from dual;\n    if l_var is not null then\n      dbms_output.put_line('yessss baby!');\n    end if;\n    dbms_output.put_line('a loop is following');\n    loop\n      exit when l_var = 'X';\n      dbms_output.put_line('should not be here');\n    end loop;\n    dbms_output.put_line('that''s all folks!');\n  end;\n", false).tap {|i| i.name="private_proc"},
                Parser::VariableItem.new(198, "lg_var_private", "varchar2"),
                Parser::ProcedureItem.new(1409, "procedure test(p1 integer) as\n  begin\n    dbms_output.put_line('just a test');\n    begin\n      null;\n    exception\n      when others then\n        null;\n    end;\n  end;\n", false).tap {|i| i.name="test"},
                Parser::VariableItem.new(1373, "lg_muci", "varchar2"),
                Parser::FunctionItem.new(1605, "function muci(x varchar2, y clob) return boolean as\n  begin\n    return false;\n  end;\n", false).tap {|i| i.name="muci"},
                Parser::VariableItem.new(1570, "lg_buci", "varchar2"),
                Parser::VariableItem.new(1684, "lg_whatever", "boolean")]
    region.declared_items.should == expected
  end# }}}

  it 'should get all items for a function' do# {{{
    text = File.open('spec/sql/inter_var.fnc', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children.first.content
    expected = [Parser::ProcedureItem.new(89, "procedure muci as\n\tbegin\n\t\tnull;\n\tend;\n", false).tap { |i| i.name = "muci"},
                Parser::VariableItem.new(54, "l_local", "varchar2"),
                Parser::ProcedureItem.new(148, "procedure xyz as\n\tbegin\n\t\tnull;\n\tend;\n", false).tap { |i| i.name = "xyz"},
                Parser::VariableItem.new(121, "l_bla", "integer"),
                Parser::VariableItem.new(179, "l_bubu", "boolean")]
    region.declared_items.should == expected
  end# }}}

  it 'should get all items for an incomplete function' do# {{{
    text = File.open('spec/sql/incomplete1.fnc', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children.first.content
    expected = [Parser::ProcedureItem.new(89, "procedure muci as\n\tbegin\n\t\tnull;\n\tend;\n", false).tap { |i| i.name = "muci"},
                Parser::VariableItem.new(54, "l_local", "varchar2"),
                Parser::ProcedureItem.new(148, "procedure xyz as\n\tbegin\n\t\tnull;\n\tend;\n", false).tap { |i| i.name = "xyz"},
                Parser::VariableItem.new(121, "l_bla", "integer"),
                Parser::VariableItem.new(179, "l_bubu", "boolean")]
    region.declared_items.should == expected
  end# }}}

  it 'should work with an incomplete package' do# {{{
    text = File.open('spec/sql/admin_tk_incomplete.pkg', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children[1].content
    expected = [Parser::FunctionItem.new(27984, "function is_AdminBasket(pi_itmidn in integer) return integer is\n    l_result integer;\n  begin\n    l_re\n", false).tap { |i| i.name = 'is_AdminBasket' },
                Parser::ConstantItem.new(27259, "INVALID_UNKNOWN", "integer"),
                Parser::ConstantItem.new(27302, "TREKAGNST", "integer"),
                Parser::ConstantItem.new(27345, "TRECTD", "integer"),
                Parser::ConstantItem.new(27388, "TREASSFIX", "integer"),
                Parser::ConstantItem.new(27426, "TRETRDBOK", "integer"),
                Parser::ConstantItem.new(27464, "TREASSFLA", "integer"),
                Parser::ConstantItem.new(27502, "TREPRVEQU", "integer"),
                Parser::ConstantItem.new(27539, "TREFSP", "integer"),
                Parser::ConstantItem.new(27576, "TREFNDSPE", "integer"),
                Parser::ConstantItem.new(27614, "TREFNDPUB", "integer"),
                Parser::ConstantItem.new(27652, "TREFNDADM", "integer"),
                Parser::ConstantItem.new(27689, "TRECTDACC", "integer"),
                Parser::ConstantItem.new(27727, "TREBNKNSTACC", "integer"),
                Parser::ConstantItem.new(27768, "TREBNKNST", "integer"),
                Parser::VariableItem.new(27805, "ErrMsgNo", "integer")]
    region.declared_items.should == expected
  end# }}}

  it 'should get items from declare blocks' do# {{{
    text = "declare\n\tl_kkt varchar2(100);\nbegin\n\tl_k"
    structure = Parser::PlsqlStructure.new(text)
    region = structure.regions.children.first.content
    region.declared_items.should == [Parser::VariableItem.new(10, "l_kkt", "varchar2")]
  end# }}}

end

