# encoding: UTF-8

include Vorax

describe 'sqlplus' do

  before(:all) do# {{{
    @cstr = Parser::ConnString.new
  end# }}}

  it 'should parse a connection string containing just the user' do# {{{
    @cstr.parse('scott')[:user].should eq('scott')
  end# }}}

  it 'should parse a connection string containing the user and the password' do# {{{
    @cstr.parse('scott/tiger')[:user].should eq('scott')
  end# }}}

  it 'should parse a connection string containing the user and the database' do# {{{
    @cstr.parse('scott@db')[:user].should eq('scott')
  end# }}}

  it 'should parse a connection string containing the user with special chars' do# {{{
    @cstr.parse('"scott@man"@db')[:user].should eq('scott@man')
    @cstr.parse('"scott/man"@db')[:user].should eq('scott/man')
  end# }}}

  it 'should parse a connection string containing an empty user' do# {{{
    @cstr.parse('/')[:user].should eq('')
  end# }}}

  it 'should extract the role' do# {{{
    @cstr.parse('talek/muci as sysdba').should eq({:prompt_for => nil, :user =>'talek', :password => 'muci', :db => '', :role => 'sysdba'})
    @cstr.parse('talek/"muciBuci123" as  SYSASM').should eq({:prompt_for => nil, :user =>'talek', :password => 'muciBuci123', :db => '', :role => 'sysasm'})
    @cstr.parse('scott/tiger@//fox:1521/fd.fox.ro as sysoper').should eq({:prompt_for => nil, :user =>'scott', :password => 'tiger', :db => '//fox:1521/fd.fox.ro', :role => 'sysoper'})
    @cstr.parse('scott@//fox:1521/fd.fox.ro as sysoper').should eq({:prompt_for => :password, :user =>'scott', :password => '', :db => '//fox:1521/fd.fox.ro', :role => 'sysoper'})
  end# }}}

  it 'should work with OS auth' do# {{{
    @cstr.parse('/').should eq({:user =>'', :password => '', :db => '', :role => '', :prompt_for => nil})
    @cstr.parse('/ as sysdba').should eq({:prompt_for => nil, :user =>'', :password => '', :db => '', :role => 'sysdba'})
    @cstr.parse('/@db').should eq({:prompt_for => nil, :user =>'', :password => '', :db => 'db', :role => ''})
  end# }}}

  it 'should prompt for password when just the user is given' do# {{{
    @cstr.parse('scott').should eq({:user =>'scott', :password => '', :db => '', :role => '', :prompt_for => :password})
  end# }}}

  it 'should prompt for user when nothing is given' do# {{{
    @cstr.parse('').should eq({:user =>'', :password => '', :db => '', :role => '', :prompt_for => :user})
  end# }}}

end
