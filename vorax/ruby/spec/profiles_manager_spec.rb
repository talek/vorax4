# encoding: UTF-8

include Vorax

describe 'profiles_manager' do

  before(:all) do# {{{
    @pm = dummy_pm
  end# }}}

  after(:all) do# {{{
    clear_pm
  end# }}}

  it 'should list profiles' do# {{{
    # all profiles
    @pm.profiles.should =~ ['scott@db', 'admin@proddb1', 'admin@pdb2', 'test@tdb']

    # just the Prod profiles
    @pm.profiles('Prod').should =~ ['admin@proddb1', 'admin@pdb2']

    # all profiles not assigned to any category
    @pm.profiles('').should =~ ['test@tdb']
  end# }}}

  it 'should get the password of a profile' do# {{{
    @pm = dummy_pm
    @pm.password('admin@proddb1').should == 'secret'
  end# }}}

  it 'should get the categories' do# {{{
    @pm.categories.should == ['Prod', 'Test']
  end# }}}

  it 'should edit the repository' do# {{{
    pmtemp = dummy_pm
  
    # remove a profile
    pmtemp.remove('scott@db')
    pmtemp.profiles.should =~ ['admin@proddb1', 'admin@pdb2', 'test@tdb']

    # edit the id of a profile
    pmtemp.edit('admin@pdb2', 'id', 'ADMIN@PDB2')
    pmtemp.profiles.should =~ ['admin@proddb1', 'ADMIN@PDB2', 'test@tdb']

    # unset the important flag
    pmtemp.attribute('ADMIN@PDB2', 'important').should == "true"
    pmtemp.edit('ADMIN@PDB2', 'important', false)
    pmtemp.attribute('ADMIN@PDB2', 'important').should == "false"
  end# }}}

  def dummy_pm# {{{
    # create keys
    ProfilesManager.create('spec/pm', 'xxx')

    # init pm
    pm = ProfilesManager.new('spec/pm')
    
    # set the master password
    pm.master_password = 'xxx'

    # add some profiles
    pm.add('scott@db', :category => 'Test')
    pm.add('admin@proddb1', :password => 'secret', 
                            :category => 'Prod', 
                            :important => true)
    pm.add('admin@pdb2', :password => 'xxx', 
                         :category => 'Prod', 
                         :important => true)
    pm.add('test@tdb', :password => 'abc')

    pm
  end# }}}

  def clear_pm# {{{
    files = Dir.glob('spec/pm/*').each { |f| File.delete(f) if File.file?(f) }
  end# }}}

end

