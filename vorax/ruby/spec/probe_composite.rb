# encoding: UTF-8

include Vorax

describe 'probe_pks' do

	it 'should probe a valid spec' do
		text = 'create or replace package scott.text as g_var integer; end;'
		Parser::SpecRegion.probe(text).should == {:name => 'scott.text', :pointer => 39}

		text = 'create or replace package test authid current_user as g_var integer; end;'
		Parser::SpecRegion.probe(text).should == {:name => 'test', :pointer => 53}

		text = 'create package test authid definer as g_var integer; end;'
		Parser::SpecRegion.probe(text).should == {:name => 'test', :pointer => 37}

		text = 'package test as g_var integer; end;'
		Parser::SpecRegion.probe(text).should == {:name => 'test', :pointer => 15}
	end

	it 'should get a nil pointer for an invalid package spec' do
		text = 'create package  as g_var integer; end;'
		Parser::SpecRegion.probe(text)[:pointer].should be_nil

		text = 'package muci declare g_var integer; end;'
		Parser::SpecRegion.probe(text)[:pointer].should be_nil
	end

end


