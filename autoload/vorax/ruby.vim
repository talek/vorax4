" File:        voraxlib/ruby.vim
" Author:      Alexandru Tică
" Description: Implements the bridge between VimL and Ruby, as far as the
"              Vorax code is concerned. Every function which needs to invoke 
"              ruby code is defined here.
" License:     see LICENSE.txt

" Initialization {{{

if exists('g:vorax_ruby_loaded')
  finish
endif
let g:vorax_ruby_loaded = 1

let s:ruby_ver = ''
if has('ruby')
  ruby $LOAD_PATH << File.expand_path('../../../vorax/ruby/lib', VIM::evaluate("expand('<sfile>')"))
  ruby VIM::command("let s:ruby_ver=#{RUBY_VERSION.inspect}")
endif

if has('ruby') && (s:ruby_ver =~ '\m^1\.9.*$' || s:ruby_ver =~ '\m^2\.')
  " only ruby 1.9 or above are supported
  try
    ruby require 'vorax'
  catch /.*LoadError.*/
    let g:vorax_ruby_loaded = 0
    echom "Vorax cannot load its ruby buddy code!"
    echom v:exception
    echom ""
    echom "Maybe you need to install the vorax gem using:"
    echom "   gem install vorax"
    finish
  endtry
else
  let g:vorax_ruby_loaded = 0
  echom("Vorax needs that your VIM to be compiled with ruby 1.9 support!")
  finish
endif
" }}}

" Logging Facility {{{

function! vorax#ruby#InitLogging(file)
  ruby <<ERC
# encoding: UTF-8
  if Vorax::logger.nil?
    require 'logger'
    Vorax::logger = Logger.new(VIM::evaluate("a:file"), "daily")
    Vorax::logger.level = Logger::DEBUG
    Vorax::logger.formatter = proc do |severity, datetime, progname, msg|
      "\n#{datetime.strftime('%Y-%m-%d %H:%M:%S.%3N')} [#{progname}] - #{msg}\n"
    end
  end
ERC
endfunction

function! vorax#ruby#Log(level, message)
  ruby Vorax::logger.add(VIM::evaluate("a:level"), nil, 'vim') { VIM::evaluate("a:message") }
endfunction

" }}}

" Parsing {{{

function! vorax#ruby#ParseConnectionString(cstr) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  parts = Vorax::Parser::ConnString.new.parse(VIM::evaluate("a:cstr"))
  vim_hash = "{" + parts.inject([]) do |a, (k, v)| 
    a << "#{k.to_s.inspect} : #{(v.nil? ? "" : v).to_s.inspect}" 
  end.join(",") + "}"
  VIM::command("return #{vim_hash}")
ERC
endfunction"}}}

function! vorax#ruby#CurrentStatement(sql_script, position, plsql_blocks, sqlplus_commands) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  crr_statement = Vorax::Parser.current_statement(
                        VIM::evaluate('a:sql_script'), 
                        VIM::evaluate('a:position'), 
                        :plsql_blocks => (VIM::evaluate('a:plsql_blocks') == 1 ? true : false),
                        :sqlplus_commands => (VIM::evaluate('a:sqlplus_commands') == 1 ? true : false)) 
  if crr_statement[:statement] != ''
    start_at = crr_statement[:range].min
    VIM::command("return {'text' : #{crr_statement[:statement].inspect}, 'position' : #{start_at}}")
  else
    VIM::command("return {'text' : '', 'position' : -1}")
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlStatements(sql_script, plsql_blocks, sqlplus_commands) "{{{
  ruby <<ERC
# encoding: UTF-8
  statements = Vorax::Parser.statements(
                        VIM::evaluate('a:sql_script'), 
                        :plsql_blocks => (VIM::evaluate('a:plsql_blocks') == 1 ? true : false),
                        :sqlplus_commands => (VIM::evaluate('a:sqlplus_commands') == 1 ? true : false)) 
  VIM::command("return #{statements.inspect}")
ERC
endfunction "}}}

function! vorax#ruby#StatementType(statement) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  stmt_type = "#{Vorax::Parser.statement_type(VIM::evaluate('a:statement'))}"
  VIM::command("return #{stmt_type.inspect}")
ERC
endfunction"}}}

function! vorax#ruby#PrepareExec(statement) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  stmt = Vorax::Parser.prepare_exec(VIM::evaluate('a:statement'))
  VIM::command("return #{stmt.inspect}")
ERC
endfunction"}}}

function! vorax#ruby#ParseResultset(html, ...) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  if VIM::evaluate('a:0') == 0
    result = Vorax::Parser.query_result(VIM::evaluate('a:html'))
  else
    result = Vorax::Parser.query_result(VIM::evaluate('a:html'), VIM::evaluate('a:1') == 1 ? true : false)
  end
  vim_hash = "{'resultset' : #{result[:resultset].inspect}, 'errors' : #{result[:errors].inspect}}"
  VIM::command("return #{vim_hash}")
ERC
endfunction"}}}

function! vorax#ruby#ArgumentBelongsTo(statement, position) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  argument = Vorax::Parser.argument_belongs_to(VIM::evaluate('a:statement'), VIM::evaluate('a:position'))
  VIM::command("return #{argument.inspect}")
ERC
endfunction"}}}

function! vorax#ruby#GetAlias(statement, alias_name, position)"{{{
  call VORAXDebug('vorax#ruby#GetAlias a:statement=' . string(a:statement) .
        \ ' a:alias_name = ' . string(a:alias_name) .
        \ ' a:position = ' . a:position)
  ruby <<ERC
# encoding: UTF-8
  vim_alias = {}
  inspector = Vorax::Parser::StmtInspector.new(VIM::evaluate('a:statement'))
  target_alias = inspector.find_alias(VIM::evaluate('a:alias_name'), 
                                      VIM::evaluate('a:position') - 1)
  if target_alias
    vim_alias = "{'alias_type' : #{target_alias.class.name.split(/::/).last.inspect}, 'base' : #{target_alias.base.inspect} }"
  end
  VIM::command("return #{vim_alias}") 
ERC
endfunction"}}}

function! vorax#ruby#IsAliasVisible(statement, alias_name, position) "{{{
  ruby <<ERC
# encoding: UTF-8
  status = 0
  inspector = Vorax::Parser::StmtInspector.new(VIM::evaluate('a:statement'))
  target_alias = inspector.find_alias(VIM::evaluate('a:alias_name'), 
                                      VIM::evaluate('a:position') - 1)
  status = 1 if target_alias
  VIM::command("return #{status}") 
ERC
endfunction "}}}

function! vorax#ruby#AliasColumns(statement, alias_name, position) abort"{{{
  exec VORAXDebug("ruby.vim AliasColumns() statement=" . string(a:statement) .
        \ " alias_name=" . string(a:alias_name) .
        \ " position=" . string(a:position))
  ruby <<ERC
# encoding: UTF-8
  columns = []
  inspector = Vorax::Parser::StmtInspector.new(VIM::evaluate('a:statement'))
  target_alias = inspector.find_alias(VIM::evaluate('a:alias_name'), 
                                      VIM::evaluate('a:position') - 1)
  columns = target_alias.columns if target_alias
  VIM::command("return #{columns.inspect}") 
ERC
endfunction"}}}

function! vorax#ruby#DescribeDeclare(source_text) abort"{{{
  call VORAXDebug("vorax#ruby#DescribeDeclare source_text=" . string(a:source_text))
  let result = []
  ruby <<ERC
# encoding: UTF-8
    structure = Vorax::Parser::PlsqlStructure.new(VIM::evaluate('a:source_text'))
    region = structure.regions.children.first.content
    items = []
    region.declared_items.each do |i| 
      item = Vorax::Utils.transform_hash(i.to_hash, :deep => true) do |h, k, v|
        if v.nil?
          h[k] = '' 
        elsif v.is_a?(TrueClass) 
          h[k] = 1
        elsif v.is_a?(FalseClass)
          h[k] = 0
        else
          h[k] = v
        end
      end
      items << item.to_json
    end
  VIM::command("return [#{items.join(',')}]")
ERC
endfunction"}}}

function! vorax#ruby#ComputePlsqlStructure(stored_as, source_text) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  Vorax.extra[VIM::evaluate('a:stored_as')] = Vorax::Parser::PlsqlStructure.new(VIM::evaluate('a:source_text'))
ERC
endfunction"}}}

function! vorax#ruby#CompositeName(structure_stored_in, position) abort "{{{
  ruby <<ERC
# encoding: UTF-8
  structure = Vorax.extra[VIM::evaluate('a:structure_stored_in')]
  region = structure.region_at(VIM::evaluate('a:position'))
  package_name = ''
  begin
    if region 
      if region.is_a?(Vorax::Parser::CompositeRegion)
        package_name = region.name
        break
      end
      region = region.node.parent.content
    else
      break
    end
  end while true
  VIM::command("return #{package_name.inspect}")
ERC
endfunction "}}}

function! vorax#ruby#RegionScope(structure_stored_in, position) abort "{{{
  ruby <<ERC
# encoding: UTF-8
  scope = []
  structure = Vorax.extra[VIM::evaluate('a:structure_stored_in')]
  region = structure.region_at(VIM::evaluate('a:position'))
  begin
    if region
      region_hash = region.to_hash
      region_hash[:region_type] = region.class.name.split(/::/).last || ''
      vim_region_hash = region_hash.inject({}) { |h,(k,v)| h[k] = (v ? v : ''); h }.to_json
      scope << vim_region_hash
      region = region.node.parent.content
    else
      break
    end
  end while true
  VIM::command("return [#{scope.join(',')}]")
ERC
endfunction "}}}

function! vorax#ruby#LocalItems(structure_stored_in, position, prefix)"{{{
  ruby <<ERC
# encoding: UTF-8
  structure = Vorax.extra[VIM::evaluate('a:structure_stored_in')]
  region = structure.region_at(VIM::evaluate('a:position'))
  items = []
  begin
    if region
      if region.kind_of?(Vorax::Parser::ForRegion)
        item = {:item_type => 'ForVariable', 
                  :domain => region.domain, 
                  :domain_type => region.domain_type.to_s,
                  :variable => region.variable.to_s,
                  :declared_at => region.variable_position,
                  :start_pos => region.start_pos,
                  :end_pos => region.end_pos
                  }.to_json
        items << item
      elsif region.respond_to?(:declared_items)
        if region.declared_items
          region.declared_items.each do |i| 
            if i && i.respond_to?(:name) && i.name.downcase.start_with?(VIM::evaluate('a:prefix').downcase)
              item = Vorax::Utils.transform_hash(i.to_hash, :deep => true) do |h, k, v|
                if v.nil?
                  h[k] = '' 
                elsif v.is_a?(TrueClass) 
                  h[k] = 1
                elsif v.is_a?(FalseClass)
                  h[k] = 0
                else
                  h[k] = v
                end
              end
              items << item.to_json
            end
          end
        end
      end
      if region.kind_of?(Vorax::Parser::PackageBodyRegion)
        name = region.name
        spec = structure.regions.find do |r| 
          r.content.kind_of?(Vorax::Parser::PackageSpecRegion) && r.content.name =~ /^#{name}$/i
        end
        if spec
          region = spec.content
        else
          break
        end
      else
        region = region.node.parent.content
      end
    else
      break
    end
  end while true
  VIM::command("return [#{items.join(',')}]")
ERC
endfunction"}}}

function! vorax#ruby#PlsqlRegions(source_text) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  vim_regions = []
  structure = Vorax::Parser::PlsqlStructure.new(VIM::evaluate('a:source_text'))
  structure.regions.breadth_each do |node|
    region = node.content
    if region
      vim_hash = region.to_hash.inject({}) { |h,(k,v)| h[k] = (v ? v : ''); h }
      vim_hash[:level] = node.level
      vim_hash[:region_type] = region.class.name.split(/::/).last || ''
      vim_regions << vim_hash.to_json
    end
  end
  VIM::command("return [#{vim_regions.join(',')}]")
ERC
endfunction"}}}

function! vorax#ruby#RemoveAllComments(text) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  clear_text = Vorax::Parser.remove_all_comments(VIM::evaluate('a:text'))
  VIM::command("return #{clear_text.inspect}")
ERC
endfunction"}}}

function! vorax#ruby#DescribeRecordType(text) abort"{{{
  ruby <<ERC
# encoding: UTF-8
    items = []
    rec_items = Vorax::Parser.describe_record(VIM::evaluate('a:text'))
    rec_items.each do |i|
        item = Vorax::Utils.transform_hash(i.to_hash, :deep => true) do |h, k, v|
          if v.nil?
            h[k] = '' 
          elsif v.is_a?(TrueClass) 
            h[k] = 1
          elsif v.is_a?(FalseClass)
            h[k] = 0
          else
            h[k] = v
          end
        end
        items << item.to_json
    end
    VIM::command("return [#{items.join(',')}]")
ERC
endfunction"}}}

function! vorax#ruby#IdentifierAt(line, crrpos) abort "{{{
  ruby <<ERC
# encoding: UTF-8
  data = VIM::evaluate("a:line")
  crrpos = VIM::evaluate('a:crrpos')
  identifier = Vorax::Parser.identifier_at(data, crrpos)
  VIM::command("return #{identifier.inspect}")
ERC
endfunction "}}}

" }}}

" SqlPlus Interaction {{{

" add some helper methods to Vorax module"{{{
ruby <<ERC
# encoding: UTF-8
  module Vorax

    def self.sqlplus=(sp)
      @sp = sp
    end

    def self.sqlplus
      @sp
    end

    def self.with_sqlplus
      if Vorax::sqlplus_initialized? 
        if Vorax::sqlplus_alive?
          yield(Vorax::sqlplus) if block_given?
        else
          Vorax::debug("Buddy sqlplus process died")
          #VIM::command('call vorax#utils#SpitWarn("The buddy SqlPlus process behind has unexpectedly died! You should :VORAXConnect again!")')
          VIM::command('throw "VRX-02: Sqlplus process has died"')
        end
      else
        Vorax::debug("Vorax::sqlplus not initialized")
        #VIM::command('call vorax#utils#SpitWarn("There\'s no SqlPlus process running. Did you connect first?")')
        VIM::command('throw "VRX-01: Sqlplus not ready"')
      end
    end

    def self.sqlplus_initialized?
      defined?(Vorax::sqlplus) && (not Vorax::sqlplus.nil?) 
    end

    def self.sqlplus_alive?
      Vorax::sqlplus.process.alive?
    rescue Errno::ECHILD
      return false
    end

  end
ERC
"}}}

function! vorax#ruby#SqlplusFork(...) abort"{{{
  call VORAXDebug("vorax#ruby#SqlplusFork() extra params=" . string(a:000))
  ruby <<ERC
# encoding: UTF-8
  begin 
    Vorax::sqlplus.terminate
  rescue 
  end
  if VIM::evaluate("a:0") == 0
    Vorax::sqlplus = Vorax::Sqlplus.new
  else
    Vorax::sqlplus = Vorax::Sqlplus.new(VIM::evaluate("a:1"))
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlplusIsInitialized() abort "{{{
  ruby VIM::command("return #{Vorax::sqlplus_initialized? ? 1 : 0}")
endfunction "}}}

function! vorax#ruby#SqlplusIsAlive() abort "{{{
  if vorax#ruby#SqlplusIsInitialized()
    ruby VIM::command("return #{Vorax::sqlplus_alive? ? 1 : 0}")
  else
    return 0
  endif
endfunction"}}}

function! vorax#ruby#SqlplusExec(command, ...) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  Vorax::with_sqlplus do |sp|
    params = {}
    if VIM::evaluate("exists('a:1')") == 1
      if VIM::evaluate("exists('a:1[\"prep\"]')") == 1
        params[:prep] = VIM::evaluate("a:1['prep']")
      end
      if VIM::evaluate("exists('a:1[\"post\"]')") == 1
        params[:post] = VIM::evaluate("a:1['post']")
      end
      if VIM::evaluate("exists('a:1[\"pack_file\"]')") == 1
        params[:pack_file] = VIM::evaluate("a:1['pack_file']")
      end
      if VIM::evaluate("exists('a:1[\"funnel\"]')") == 1
        funnel = VIM::evaluate("a:1['funnel']")
        if funnel == 1
          sp.default_convertor = :vertical
        elsif funnel == 2
          sp.default_convertor = :pagezip
        elsif funnel == 3
          sp.default_convertor = :tablezip
        else
          sp.default_convertor = nil
        end
      end
    end
    sp.exec(VIM::evaluate("a:command"), params)
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlplusReadOutput(...) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  output = ""
  Vorax::with_sqlplus do |sp|
    if VIM::evaluate("a:0") == 1
      output = sp.read_output(VIM::evaluate("a:1"))
    else
      output = sp.read_output()
    end
  end
  VIM::command("return #{output.inspect}")
ERC
endfunction"}}}

function! vorax#ruby#SqlplusSendText(str) abort"{{{
  call VORAXDebug("vorax#ruby#SqlplusSendText a:str=" . string(a:str))
  ruby Vorax::with_sqlplus { |sp| sp.send_text(VIM::evaluate("a:str")) }
endfunction"}}}

function! vorax#ruby#SqlplusBusy() abort"{{{
  ruby <<ERC
# encoding: UTF-8
  Vorax::with_sqlplus do |sp|
    status = (sp.busy? ? 1 : 0)
    VIM::command("return #{status}")
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlplusEofOutput() abort"{{{
  ruby <<ERC
# encoding: UTF-8
  Vorax::with_sqlplus do |sp|
    status = (sp.eof? ? 1 : 0)
    VIM::command("return #{status}")
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlplusSetFunnel(type) abort"{{{
  ruby <<ERC
# encoding: UTF-8
  Vorax::with_sqlplus do |sp|
    if VIM::evaluate("a:type") == 1
      sp.default_convertor = :vertical
    elsif VIM::evaluate("a:type") == 2
      sp.default_convertor = :pagezip
    elsif VIM::evaluate("a:type") == 3
      sp.default_convertor = :tablezip
    else
      sp.default_convertor = nil
    end
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlplusHasFunnel() abort"{{{
  ruby <<ERC
# encoding: UTF-8
  Vorax::with_sqlplus do |sp|
    if sp.default_convertor_name.nil?
      VIM::command("return 0")
    else
      VIM::command("return 1")
    end
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlplusCancel() abort"{{{
  call VORAXDebug("vorax#ruby#SqlplusCancel() invoked")
  ruby <<ERC
# encoding: UTF-8
  cancelled = 0
  Vorax::with_sqlplus do |sp| 
    begin
      sp.cancel do 
        key = VIM::evaluate('getchar(0)').to_i
        VIM::command('sleep 50m')
        if key.chr == 'K' || key.chr == 'k'
          # a lot of "K" may follow, so it's better to get rid of them
          VIM::command('call vorax#utils#ClearUserInputStream()')
          abort = true
          if VIM::evaluate("s:ShouldKill()") == 1
            answer = 0
            VIM::command('redraw')
            answer = VIM::evaluate('s:ShouldKill()')
            VIM::command('call vorax#utils#ClearUserInputStream()') if answer == 2
            VIM::command('redraw')
            abort = false if answer == 2 || answer == 0
          end
          if abort
            # force stop spitter
            VIM::command('au! VoraX CursorHold <buffer>')
            sp.terminate 
            break
          end
        end
      end
      cancelled = 1
    rescue Vorax::PlatformNotSupported
    VIM::command('redraw | echo ""')
      if VIM::evaluate("s:ShouldKill()") == 1
        VIM::command('au! VoraX CursorHold <buffer>')
        VIM::command('redraw | echo "Aborting..."')
        sp.terminate
        break
      end
    end
  end
  VIM::command("return #{cancelled}")
ERC
endfunction"}}}

function! vorax#ruby#SqlplusKill() abort"{{{
  call VORAXDebug("vorax#ruby#SqlplusKill() invoked")
  ruby Vorax::with_sqlplus { |sp| sp.terminate }
ERC
endfunction"}}}

function! s:ShouldKill() abort"{{{
  if g:vorax_abort_session_warning
    if confirm("Are you sure you want to abort this session?", "&Yes\n&No", 1, "Q") == 1
      return 1
    else
      return 0
    endif
  endif
  return 1
endfunction"}}}

" }}}

" Connection Profiles Management {{{

function! vorax#ruby#PmInit(config_dir)
  ruby <<ERC
  Vorax.extra['pm'] = Vorax::ProfilesManager.new(VIM::evaluate('a:config_dir'))
ERC
endfunction

function! vorax#ruby#PmHasKeys(config_dir)
  ruby <<ERC
# encoding: UTF-8
  if Vorax::ProfilesManager.initialized?(VIM::evaluate('a:config_dir'))
    VIM::command("return 1")
  else
    VIM::command("return 0")
  end
ERC
endfunction

function! vorax#ruby#PmSecure(config_dir, master_pwd)
  ruby <<ERC
# encoding: UTF-8
  Vorax::ProfilesManager.create(VIM::evaluate('a:config_dir'), VIM::evaluate('a:master_pwd'))
ERC
endfunction

function! vorax#ruby#PmChangePwd(config_dir, old_pwd, new_pwd)
  ruby <<ERC
# encoding: UTF-8
  Vorax::ProfilesManager.change_master_pwd(
    VIM::evaluate('a:config_dir'), 
    VIM::evaluate('a:old_pwd'),
    VIM::evaluate('a:new_pwd')
  )
ERC
endfunction

function! vorax#ruby#PmCategories()
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  VIM::command("return #{pm.categories.inspect}")
ERC
endfunction

function! vorax#ruby#PmProfiles(category)
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  VIM::command("return #{pm.profiles(VIM::evaluate('a:category')).inspect}")
ERC
endfunction

function! vorax#ruby#PmAllProfiles()
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  VIM::command("return #{pm.profiles(nil).inspect}")
ERC
endfunction

function! vorax#ruby#PmSetMasterPassword(pwd)
  ruby <<ERC
# encoding: UTF-8
  begin
    pm = Vorax.extra['pm']
    pm.master_password = VIM::evaluate('a:pwd')
  rescue OpenSSL::PKey::RSAError => e
    # invalide password... ignore it
  end
ERC
endfunction

function! vorax#ruby#PmSave()
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  pm.save
ERC
endfunction

function! vorax#ruby#PmGetPassword(profile)
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  pwd = pm.password(VIM::evaluate('a:profile'))
  VIM::command("return #{pwd.inspect}")
ERC
endfunction

function! vorax#ruby#IsPmUnlocked()
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  if pm.unlocked
    VIM::command('return 1')
  else
    VIM::command('return 0')
  end
ERC
endfunction

function! vorax#ruby#IsPmProfileWithPassword(profile)
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  if pm.attribute(VIM::evaluate('a:profile'), 'password')
    VIM::command('return 1')
  else
    VIM::command('return 0')
  end
ERC
endfunction

function! vorax#ruby#PmAdd(profile, password, category, important)
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  pm.add(VIM::evaluate('a:profile'), 
    :password => VIM::evaluate('a:password'),
    :category => VIM::evaluate('a:category'),
    :important => VIM::evaluate('a:important'))
ERC
endfunction

function! vorax#ruby#PmRemove(profile)
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  pm.remove(VIM::evaluate('a:profile'))
ERC
endfunction

function! vorax#ruby#PmEdit(profile, property_name, property_value)
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  pm.edit(VIM::evaluate('a:profile'),
    VIM::evaluate('a:property_name'),
    VIM::evaluate('a:property_value'))
ERC
endfunction

function! vorax#ruby#PmMasterPwd()
  ruby <<ERC
# encoding: UTF-8
  pm = Vorax.extra['pm']
  VIM::command("return #{pm.master_password.inspect}")
ERC
endfunction

" }}}

" Oradoc {{{

function! vorax#ruby#AllBooks(folder)
  ruby <<EOR
# encoding: UTF-8
  books = Vorax::Oradoc.all_books(VIM::evaluate('a:folder'))
  VIM::command("return #{books.inspect}")
EOR
endfunction

function! vorax#ruby#DisplayBooks(folder)
  ruby <<EOR
# encoding: UTF-8
  Vorax::Oradoc.all_books(VIM::evaluate('a:folder')) do |book, file|
    VIM::command("echo #{book.inspect}")
  end
EOR
endfunction

function! vorax#ruby#CreateDocIndex(doc_folder, index_folder, only_books)
  ruby <<EOR
# encoding: UTF-8
  Vorax::Oradoc.create_index(VIM::evaluate('a:doc_folder'),
                             VIM::evaluate('a:index_folder'),
                             VIM::evaluate('a:only_books'))
EOR
endfunction

function! vorax#ruby#OradocSearch(index_folder, what, ...)
  ruby <<EOR
# encoding: UTF-8
  if VIM::evaluate('a:0') == 0
    results = Vorax::Oradoc.search(
      VIM::evaluate('a:index_folder'),
      VIM::evaluate('a:what'))
  else
    results = Vorax::Oradoc.search(
      VIM::evaluate('a:index_folder'),
      VIM::evaluate('a:what'),
      VIM::evaluate('a:1'))
  end
  VIM::command("return #{results.to_json}")
EOR
endfunction

" }}}
