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

  it 'should work with complex code' do# {{{
    text = File.open('spec/sql/notif.pkg', 'rb') { |file| file.read }
    structure = Parser::PlsqlStructure.new(text)
    structure.dump.should == %q([Level: 0] 
  [Level: 1] PackageSpecRegion: {:start_pos=>19, :end_pos=>10479, :name=>"\"MUCI_REPOSITORY\".\"NOTIFICATIONS_TOOLKIT\"", :name_pos=>27, :signature_end_pos=>266, :declare_end_pos=>10448}
  [Level: 1] PackageBodyRegion: {:start_pos=>10498, :end_pos=>42353, :name=>"\"MUCI_REPOSITORY\".\"NOTIFICATIONS_TOOLKIT\"", :name_pos=>10511, :signature_end_pos=>10555, :declare_end_pos=>42322}
    [Level: 2] SubprogRegion: {:start_pos=>10715, :end_pos=>11496, :name=>"send_txn_notification", :name_pos=>10725, :body_start_pos=>11205}
      [Level: 3] ForRegion: {:start_pos=>11215, :end_pos=>11489, :variable=>"x", :domain=>"(select *\n                from table(misc_utils.split(pi_misc_params, pi_delimitator)))", :domain_type=>:expr, :variable_position=>11219}
    [Level: 2] SubprogRegion: {:start_pos=>11501, :end_pos=>12799, :name=>"send_aut_notification", :name_pos=>11511, :body_start_pos=>12026}
      [Level: 3] ForRegion: {:start_pos=>12338, :end_pos=>12470, :variable=>"x", :domain=>"(select *\n                from table(misc_utils.split(pi_text_params, pi_delimitator)))", :domain_type=>:expr, :variable_position=>12342}
      [Level: 3] ForRegion: {:start_pos=>12488, :end_pos=>12761, :variable=>"x", :domain=>"(select *\n                from table(misc_utils.split(pi_lnc_params, pi_delimitator)))", :domain_type=>:expr, :variable_position=>12492}
    [Level: 2] SubprogRegion: {:start_pos=>12804, :end_pos=>13938, :name=>"push_notification", :name_pos=>12814, :body_start_pos=>13211}
      [Level: 3] IfRegion: {:start_pos=>13322, :end_pos=>13931}
    [Level: 2] SubprogRegion: {:start_pos=>13942, :end_pos=>15876, :name=>"get_xml_notification_for_AS", :name_pos=>13951, :body_start_pos=>14572}
      [Level: 3] ForRegion: {:start_pos=>15355, :end_pos=>15686, :variable=>"z", :domain=>"(select ntfprmval, ntfprmidx\n                from ntflogautprm\n               where ntflogidn = pi_ntfrec.ntflogidn\n                 and ntfprmtyp = 'M'\n               order by ntfprmidx)", :domain_type=>:expr, :variable_position=>15359}
      [Level: 3] IfRegion: {:start_pos=>15692, :end_pos=>15784}
    [Level: 2] SubprogRegion: {:start_pos=>15881, :end_pos=>23616, :name=>"dispatch_notifications", :name_pos=>15891, :body_start_pos=>16232}
      [Level: 3] CaseRegion: {:start_pos=>16377, :end_pos=>16502}
      [Level: 3] ForRegion: {:start_pos=>18056, :end_pos=>19873, :variable=>"z", :domain=>"(select l.ntflogidn, p.ntfprmval\n                from ntflogauttbl l, ntfmda m, ntflogautprm p\n               where l.ntfidn = m.ntfidn\n                 and p.ntfprmtyp = 'M'\n                 and l.ntflogidn = p.ntflogidn\n                 and m.ntftyp = 'REPO'\n                 and l.ntfdon = '0')", :domain_type=>:expr, :variable_position=>18060}
        [Level: 4] IfRegion: {:start_pos=>18995, :end_pos=>19859}
          [Level: 5] IfRegion: {:start_pos=>19353, :end_pos=>19827}
      [Level: 3] LoopRegion: {:start_pos=>20252, :end_pos=>22382}
        [Level: 4] AnonymousRegion: {:start_pos=>21265, :end_pos=>22349}
          [Level: 5] IfRegion: {:start_pos=>21279, :end_pos=>22281}
      [Level: 3] LoopRegion: {:start_pos=>22462, :end_pos=>23325}
      [Level: 3] IfRegion: {:start_pos=>23389, :end_pos=>23453}
      [Level: 3] IfRegion: {:start_pos=>23461, :end_pos=>23531}
    [Level: 2] SubprogRegion: {:start_pos=>23621, :end_pos=>25093, :name=>"dispatch_notif_AnsFrmAss", :name_pos=>23631, :body_start_pos=>23722}
      [Level: 3] ForRegion: {:start_pos=>23939, :end_pos=>24862, :variable=>"z", :domain=>"(select l.ntflogidn\n                from ntflogauttbl l, ntfmda m\n               where l.ntfidn = m.ntfidn\n                 and m.ntftyp = 'ANSWERASS'\n                 and l.ntfdon = '0')", :domain_type=>:expr, :variable_position=>23943}
        [Level: 4] IfRegion: {:start_pos=>24680, :end_pos=>24848}
    [Level: 2] SubprogRegion: {:start_pos=>25098, :end_pos=>25652, :name=>"assamble_message", :name_pos=>25107, :body_start_pos=>25219}
      [Level: 3] ForRegion: {:start_pos=>25254, :end_pos=>25627, :variable=>"x", :domain=>"(select *\n                from (select *\n                        from ntflogtxnprm\n                      union all\n                      select * from ntflogautprm)\n               where ntflogidn = pi_ntflog_idn\n                 and ntfprmtyp = 'T'\n               order by ntfprmidx)", :domain_type=>:expr, :variable_position=>25258}
    [Level: 2] SubprogRegion: {:start_pos=>25657, :end_pos=>27145, :name=>"get_encrypted_string", :name_pos=>25666, :body_start_pos=>26083}
      [Level: 3] LoopRegion: {:start_pos=>26599, :end_pos=>27107}
    [Level: 2] SubprogRegion: {:start_pos=>27150, :end_pos=>27281, :name=>"hash_string", :name_pos=>27159, :body_start_pos=>27208}
    [Level: 2] SubprogRegion: {:start_pos=>27286, :end_pos=>27500, :name=>"push_to_socket", :name_pos=>27295, :body_start_pos=>42354}
    [Level: 2] SubprogRegion: {:start_pos=>27505, :end_pos=>28149, :name=>"get_dtd_header", :name_pos=>27514, :body_start_pos=>27550}
    [Level: 2] SubprogRegion: {:start_pos=>28154, :end_pos=>32306, :name=>"get_notification_packet", :name_pos=>28163, :body_start_pos=>28483}
      [Level: 3] ForRegion: {:start_pos=>29266, :end_pos=>31256, :variable=>"y", :domain=>"(select *\n                from ntflnc t1\n               inner join oprmda t2 on t1.ntflncopr = t2.opridn\n               where t1.ntfidn = pi_ntfrec.ntfidn\n                 and t1.ntflnclan = pi_ntfrec.usrlan)", :domain_type=>:expr, :variable_position=>29270}
        [Level: 4] ForRegion: {:start_pos=>30063, :end_pos=>30872, :variable=>"z", :domain=>"(select ntfprmval\n                  from (select ntfprmval, ntfprmidx\n                          from ntflogtxnprm t1\n                         where ntflogidn = pi_ntfrec.ntflogidn\n                           and ntfprmtyp = 'L'\n                           and ntfprmval like i || '/%'\n                        union all\n                        select ntfprmval, ntfprmidx\n                          from ntflogautprm t1\n                         where ntflogidn = pi_ntfrec.ntflogidn\n                           and ntfprmtyp = 'L'\n                           and ntfprmval like i || '/%'\n                         order by ntfprmidx))", :domain_type=>:expr, :variable_position=>30067}
        [Level: 4] IfRegion: {:start_pos=>31054, :end_pos=>31146}
      [Level: 3] IfRegion: {:start_pos=>31262, :end_pos=>31364}
      [Level: 3] ForRegion: {:start_pos=>31407, :end_pos=>31561, :variable=>"x", :domain=>"(select * from table(misc_utils.split(pi_ntfrec.usrlst, ',')))", :domain_type=>:expr, :variable_position=>31411}
      [Level: 3] ForRegion: {:start_pos=>31621, :end_pos=>32142, :variable=>"z", :domain=>"(select ntfprmval, ntfprmidx\n                from ntflogtxnprm\n               where ntflogidn = pi_ntfrec.ntflogidn\n                 and ntfprmtyp = 'M'\n              union all\n              select ntfprmval, ntfprmidx\n                from ntflogautprm\n               where ntflogidn = pi_ntfrec.ntflogidn\n                 and ntfprmtyp = 'M'\n               order by ntfprmidx)", :domain_type=>:expr, :variable_position=>31625}
      [Level: 3] IfRegion: {:start_pos=>32148, :end_pos=>32240}
    [Level: 2] SubprogRegion: {:start_pos=>32311, :end_pos=>35462, :name=>"automatic_report_xml", :name_pos=>32320, :body_start_pos=>32502}
      [Level: 3] ForRegion: {:start_pos=>32512, :end_pos=>35356, :variable=>"x", :domain=>"(select c.*,\n                     force_automreports.f_getBegDat(trunc(sysdate),c.rptcrefrq,c.rptcreper) as CalcBegDat,\n                     force_automreports.f_getEndDat(trunc(sysdate),c.rptcrefrq,c.rptcreper) as CalcEndDat\n                from pcrcfgtbl c\n               where c.pcrcfgsukidn = pi_pcrcfgsukidn)", :domain_type=>:expr, :variable_position=>32516}
    [Level: 2] SubprogRegion: {:start_pos=>35466, :end_pos=>36083, :name=>"notify_for_auto_reports", :name_pos=>35476, :body_start_pos=>35523}
      [Level: 3] ForRegion: {:start_pos=>35533, :end_pos=>36076, :variable=>"x", :domain=>"(select t.pcrcfgsukidn\n                from pcrcfgtbl t\n               where t.rptcrefrq = pi_freq)", :domain_type=>:expr, :variable_position=>35537}
    [Level: 2] SubprogRegion: {:start_pos=>36087, :end_pos=>36267, :name=>"lock_subscription", :name_pos=>36097, :body_start_pos=>36144}
    [Level: 2] SubprogRegion: {:start_pos=>36272, :end_pos=>36878, :name=>"save_subscription", :name_pos=>36282, :body_start_pos=>36545}
    [Level: 2] SubprogRegion: {:start_pos=>36883, :end_pos=>37171, :name=>"get_assigned_subscriptions", :name_pos=>36893, :body_start_pos=>37021}
    [Level: 2] SubprogRegion: {:start_pos=>37176, :end_pos=>37881, :name=>"get_subscriptions", :name_pos=>37186, :body_start_pos=>37238}
    [Level: 2] SubprogRegion: {:start_pos=>37886, :end_pos=>38272, :name=>"mark_as_read", :name_pos=>37896, :body_start_pos=>37958}
    [Level: 2] SubprogRegion: {:start_pos=>38277, :end_pos=>39490, :name=>"force_startup_notifications", :name_pos=>38287, :body_start_pos=>38465}
      [Level: 3] ForRegion: {:start_pos=>38475, :end_pos=>39455, :variable=>"x", :domain=>"(select ntflogidn,\n                     max(ntfidn) ntfidn,\n                     max(ntfisstim) ntftim,\n                     max(ntftit) ntftit,\n                     ntfmsg ntfmsg,\n                     max(ntfcat) ntfcat,\n                     max(ntftyp) ntftyp,\n                     max(ntfsrc) ntfsrc,\n                     usrnam usrlst,\n                     ntflanidn usrlan\n                from ntfusrinb\n               where ntfpnlflg = '1'\n                 and ntfredflg = '0'\n                 and ntfisstim > sysdate - 1\n                 and usrnam = pi_username\n               group by ntflogidn, usrnam, ntflanidn, ntfmsg)", :domain_type=>:expr, :variable_position=>38479}
        [Level: 4] IfRegion: {:start_pos=>39330, :end_pos=>39441}
    [Level: 2] SubprogRegion: {:start_pos=>39493, :end_pos=>41836, :name=>"collect_notif_auto_rep", :name_pos=>39503, :body_start_pos=>39688}
      [Level: 3] ForRegion: {:start_pos=>39865, :end_pos=>41831, :variable=>"x", :domain=>"(select distinct t.RptCreFrq\n              from pcrcfgtbl t\n             where t.RptCreFrq <> 1\n             order by to_number(t.RptCreFrq))", :domain_type=>:expr, :variable_position=>39869}
        [Level: 4] IfRegion: {:start_pos=>40191, :end_pos=>41819}
          [Level: 5] IfRegion: {:start_pos=>40221, :end_pos=>40380}
          [Level: 5] IfRegion: {:start_pos=>40543, :end_pos=>40621}
          [Level: 5] IfRegion: {:start_pos=>40841, :end_pos=>41067}
            [Level: 6] IfRegion: {:start_pos=>40971, :end_pos=>41053}
          [Level: 5] IfRegion: {:start_pos=>41290, :end_pos=>41453}
            [Level: 6] IfRegion: {:start_pos=>41357, :end_pos=>41439}
          [Level: 5] IfRegion: {:start_pos=>41671, :end_pos=>41807}
            [Level: 6] IfRegion: {:start_pos=>41711, :end_pos=>41793}
)
  end# }}}

end

