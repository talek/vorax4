# encoding: UTF-8

include Vorax

describe 'probe_pks' do

  it 'should probe a valid spec' do
    text = 'create or replace package scott.text as g_var integer; end;'
    Parser::SpecRegion.probe(text).should == {:name=>"scott.text", :kind=>:package_spec, :pointer=>39, :name_pos=>26}

    text = 'create or replace package test authid current_user as g_var integer; end;'
    Parser::SpecRegion.probe(text).should == {:name=>"test", :kind=>:package_spec, :pointer=>53, :name_pos=>26}

    text = 'create package test authid definer as g_var integer; end;'
    Parser::SpecRegion.probe(text).should == {:name=>"test", :kind=>:package_spec, :pointer=>37, :name_pos=>15}

    text = 'package test as g_var integer; end;'
    Parser::SpecRegion.probe(text).should == {:name=>"test", :kind=>:package_spec, :pointer=>15, :name_pos=>8}

    text = 'create or replace type muci as'
    Parser::SpecRegion.probe(text).should == {:name=>"muci", :kind=>:type_spec, :pointer=>nil, :name_pos=>23}
    
    test = "CREATE OR REPLACE TYPE \"XXX\".\"ABSTRACT_ALERT_PLUGIN\"\n"
    Parser::SpecRegion.probe(text).should == {:name=>"muci", :kind=>:type_spec, :pointer=>nil, :name_pos=>23}
  end

  it 'should get a nil pointer for an invalid package spec' do
    text = 'create package  as g_var integer; end;'
    Parser::SpecRegion.probe(text)[:pointer].should be_nil

    text = 'package muci declare g_var integer; end;'
    Parser::SpecRegion.probe(text)[:pointer].should be_nil
  end

end


