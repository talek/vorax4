# encoding: UTF-8

include Vorax

describe 'plsql structure' do

  it 'should work with package code' do# {{{
    text = File.open('spec/sql/test.pkg', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    structure.dump.should == '[Level: 0] 
  [Level: 1] PackageSpecRegion: {:start_pos=>19, :end_pos=>154, :name=>"test", :name_pos=>27, :signature_end_pos=>34, :declare_end_pos=>141}
  [Level: 1] PackageBodyRegion: {:start_pos=>174, :end_pos=>1666, :name=>"test", :name_pos=>187, :signature_end_pos=>194, :declare_end_pos=>1653}
    [Level: 2] SubprogRegion: {:start_pos=>233, :end_pos=>1368, :name=>"private_proc", :name_pos=>243, :body_start_pos=>455}
      [Level: 3] SubprogRegion: {:start_pos=>326, :end_pos=>393, :name=>"abc", :name_pos=>335, :body_start_pos=>361}
      [Level: 3] SubprogRegion: {:start_pos=>404, :end_pos=>450, :name=>"xyz", :name_pos=>414, :body_start_pos=>425}
      [Level: 3] ForRegion: {:start_pos=>485, :end_pos=>1037, :variable=>"x", :domain=>"(select * from v$session)", :domain_type=>:expr, :variable_position=>489}
        [Level: 4] IfRegion: {:start_pos=>563, :end_pos=>631}
        [Level: 4] IfRegion: {:start_pos=>639, :end_pos=>1011}
          [Level: 5] IfRegion: {:start_pos=>661, :end_pos=>919}
            [Level: 6] ForRegion: {:start_pos=>685, :end_pos=>853, :variable=>"y", :domain=>"(select * from cat)", :domain_type=>:expr, :variable_position=>689}
          [Level: 5] IfRegion: {:start_pos=>929, :end_pos=>997}
      [Level: 3] IfRegion: {:start_pos=>1082, :end_pos=>1162}
      [Level: 3] LoopRegion: {:start_pos=>1217, :end_pos=>1313}
    [Level: 2] SubprogRegion: {:start_pos=>1373, :end_pos=>1539, :name=>"test", :name_pos=>1383, :body_start_pos=>1405}
      [Level: 3] AnonymousRegion: {:start_pos=>1456, :end_pos=>1532}
    [Level: 2] SubprogRegion: {:start_pos=>1544, :end_pos=>1627, :name=>"muci", :name_pos=>1553, :body_start_pos=>1598}
'
  end# }}}

  it 'should get the region_at' do# {{{
    text = File.open('spec/sql/test.pkg', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    structure.region_at(566).should == Parser::IfRegion.new(structure, 
                                                            :start_pos => 563, 
                                                            :end_pos => 631)
    structure.region_at(566, Parser::SubprogRegion).name.should == 'private_proc'
  end# }}}

  it 'should work for a function' do# {{{
    text = File.open('spec/sql/test.fnc', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    structure.dump.should == '[Level: 0] 
  [Level: 1] SubprogRegion: {:start_pos=>19, :end_pos=>135, :name=>"test", :name_pos=>28, :body_start_pos=>119}
    [Level: 2] SubprogRegion: {:start_pos=>79, :end_pos=>116, :name=>"muci", :name_pos=>89, :body_start_pos=>98}
'
  end# }}}

  it 'should work for a type body' do# {{{
    text = File.open('spec/sql/person_type.bdy', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    structure.dump.should == '[Level: 0] 
  [Level: 1] TypeBodyRegion: {:start_pos=>8, :end_pos=>1385, :name=>"person_typ", :name_pos=>18, :signature_end_pos=>31, :declare_end_pos=>1377}
    [Level: 2] SubprogRegion: {:start_pos=>34, :end_pos=>359, :name=>"person_typ", :name_pos=>55, :body_start_pos=>297}
      [Level: 3] SubprogRegion: {:start_pos=>176, :end_pos=>274, :name=>"my_func", :name_pos=>185, :body_start_pos=>246}
    [Level: 2] SubprogRegion: {:start_pos=>365, :end_pos=>441, :name=>"get_idno", :name_pos=>385, :body_start_pos=>413}
    [Level: 2] SubprogRegion: {:start_pos=>446, :end_pos=>687, :name=>"display_details", :name_pos=>463, :body_start_pos=>518}
    [Level: 2] SubprogRegion: {:start_pos=>691, :end_pos=>1015, :name=>"match", :name_pos=>713, :body_start_pos=>757}
      [Level: 3] IfRegion: {:start_pos=>768, :end_pos=>1008}
    [Level: 2] SubprogRegion: {:start_pos=>1020, :end_pos=>1186, :name=>"show_super", :name_pos=>1036, :body_start_pos=>1095}
    [Level: 2] SubprogRegion: {:start_pos=>1191, :end_pos=>1375, :name=>"show", :name_pos=>1218, :body_start_pos=>1244}
'
  end# }}}

  it 'should work for declare blocks' do# {{{
    text = "declare
              l_kkt varchar2(100);
            begin
              null;
            end;
            /
            begin
              null;
            end;
            /
            declare
              l_status boolean;
            begin
              l_status := false;
            end;
            /"
    structure = Parser::PlsqlStructure.new(text)
    structure.dump.should == '[Level: 0] 
  [Level: 1] DeclareRegion: {:start_pos=>1, :end_pos=>112, :body_start_pos=>56}
  [Level: 1] AnonymousRegion: {:start_pos=>125, :end_pos=>181}
  [Level: 1] DeclareRegion: {:start_pos=>194, :end_pos=>300, :body_start_pos=>246}
'
  end# }}}

  it 'should work for composite types' do# {{{
    text = File.open('spec/sql/abstract_alert_plugin.typ', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    structure.dump.should == '[Level: 0] 
  [Level: 1] TypeSpecRegion: {:start_pos=>19, :end_pos=>1364, :name=>"\"XXX\".\"ABSTRACT_ALERT_PLUGIN\"", :name_pos=>24, :signature_end_pos=>nil, :declare_end_pos=>nil}
  [Level: 1] TypeBodyRegion: {:start_pos=>1383, :end_pos=>2185, :name=>"\"XXX\".\"ABSTRACT_ALERT_PLUGIN\"", :name_pos=>1393, :signature_end_pos=>1425, :declare_end_pos=>2177}
    [Level: 2] SubprogRegion: {:start_pos=>1429, :end_pos=>2176, :name=>"get", :name_pos=>1445, :body_start_pos=>1571}
      [Level: 3] ForRegion: {:start_pos=>1581, :end_pos=>1962, :variable=>"x", :domain=>"(select * from alert_plugin where id = pi_plugin_id)", :domain_type=>:expr, :variable_position=>1585}
'
  end# }}}

end

