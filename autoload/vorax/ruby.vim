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

" Always set the following variable to match the
" vorax.gem version requirement.
let s:ruby_vorax_gem_requirement = "~> 0.2"

let s:ruby_ver = ''
if has('ruby')
  ruby VIM::command("let s:ruby_ver=#{RUBY_VERSION.inspect}")
endif

if has('ruby') && s:ruby_ver =~ '\m^1\.9.*$'
  try
    ruby require 'vorax'
    ruby <<ERC
    unless Gem::Version::Requirement.new([VIM::evaluate("s:ruby_vorax_gem_requirement")]).satisfied_by?(Gem::Version.new(Vorax::VERSION))
      VIM::command("echom 'Vorax found an incompatible version of its buddy ruby code!'")
      VIM::command("echom 'To fix it:")
      VIM::command("echom '  1) ensure you run the last version of Vorax")
      VIM::command("echom '  2) gem update vorax")
    end
ERC
 catch /.*LoadError.*/
    echom "Vorax cannot load its ruby buddy code!"
    echom "You need to install vorax gem using:"
    echom "   gem install vorax"
    finish
  endtry
else
  echom("Vorax needs that your VIM to be compiled with ruby 1.9 support!")
  finish
endif
" }}}

" Logging Facility {{{

function! vorax#ruby#InitLogging(file)
  ruby <<ERC
  if Vorax::logger.nil?
    require 'logger'
    Vorax::logger = Logger.new(VIM::evaluate("a:file"), "daily")
    Vorax::logger.level = Logger::DEBUG
    Vorax::logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime('%Y-%m-%d %H:%M:%S.%3N')} [#{progname}] - #{msg}\n"
    end
  end
ERC
endfunction

function! vorax#ruby#Log(level, message)
  ruby Vorax::logger.add(VIM::evaluate("a:level"), nil, 'vim') { VIM::evaluate("a:message").gsub(/\n/, '\n') }
endfunction

" }}}

" Parsing {{{

function! vorax#ruby#ParseConnectionString(cstr) abort"{{{
  ruby <<ERC
  parts = Vorax::Parser::ConnString.new.parse(VIM::evaluate("a:cstr"))
  vim_hash = "{" + parts.inject([]) do |a, (k, v)| 
    a << "#{k.to_s.inspect} : #{(v.nil? ? "" : v).to_s.inspect}" 
  end.join(",") + "}"
  VIM::command("return #{vim_hash}")
ERC
endfunction"}}}

function! vorax#ruby#CurrentStatement(sql_script, position, plsql_blocks, sqlplus_commands) abort"{{{
  ruby <<ERC
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

function! vorax#ruby#StatementType(statement) abort"{{{
  ruby <<ERC
  stmt_type = "#{Vorax::Parser.statement_type(VIM::evaluate('a:statement'))}"
  VIM::command("return #{stmt_type.inspect}")
ERC
endfunction"}}}

function! vorax#ruby#PrepareExec(statement) abort"{{{
  ruby <<ERC
  stmt = Vorax::Parser.prepare_exec(VIM::evaluate('a:statement'))
  VIM::command("return #{stmt.inspect}")
ERC
endfunction"}}}

function! vorax#ruby#ParseResultset(html) abort"{{{
  ruby <<ERC
  result = Vorax::Parser.query_result(VIM::evaluate('a:html'))
  vim_hash = "{'resultset' : #{result[:resultset].inspect}, 'errors' : #{result[:errors].inspect}}"
  VIM::command("return #{vim_hash}")
ERC
endfunction"}}}

function! vorax#ruby#ArgumentBelongsTo(statement, position) abort"{{{
  ruby <<ERC
  argument = Vorax::Parser.argument_belongs_to(VIM::evaluate('a:statement'), VIM::evaluate('a:position')-1)
  VIM::command("return #{argument.inspect}")
ERC
endfunction"}}}

function! vorax#ruby#AliasColumns(statement, alias_name, position) abort"{{{
  exec VORAXDebug("ruby.vim AliasColumns() statement=" . string(a:statement) .
        \ " alias_name=" . string(a:alias_name) .
        \ " position=" . string(a:position))
  ruby <<ERC
  columns = []
  inspector = Vorax::Parser::StmtInspector.new(VIM::evaluate('a:statement'))
  target_alias = inspector.find_alias(VIM::evaluate('a:alias_name'), 
                                      VIM::evaluate('a:position') - 1)
  columns = target_alias.columns if target_alias
  VIM::command("return #{columns.inspect}") 
ERC
endfunction"}}}

function! vorax#ruby#DescribePackageSpec(source_text) abort"{{{
  let result = {'constants' : [], 
        \ 'variables' : [],
        \ 'types' : [],
        \ 'exceptions' : [],
        \ 'cursors' : [],
        \ 'procedures' : [],
        \ 'functions' : []}
  ruby <<ERC
  parser = Vorax::Parser::PackageSpec.new
  parser.walk(VIM::evaluate('a:source_text'))
  VIM::command("let result['constants'] = #{parser.constants.to_a.inspect}")
  VIM::command("let result['variables'] = #{parser.variables.to_a.inspect}")
  VIM::command("let result['types'] = #{parser.types.to_a.inspect}")
  VIM::command("let result['exceptions'] = #{parser.exceptions.to_a.inspect}")
  VIM::command("let result['cursors'] = #{parser.cursors.to_a.inspect}")
  VIM::command("let result['procedures'] = #{parser.procedures.to_a.inspect}")
  VIM::command("let result['functions'] = #{parser.functions.to_a.inspect}")
ERC
  return result
endfunction"}}}

function! vorax#ruby#PlsqlRegions(source_text) abort"{{{
  ruby <<ERC
  regions = []
  structure = Vorax::Parser::PlsqlStructure.new(VIM::evaluate('a:source_text'))
  structure.tree.breadth_each do |node|
    if node.content
      regions << {'start_pos' => node.content.start_pos,
                  'end_pos' => node.content.end_pos,
                  'type' => node.content.type,
                  'name' => node.content.name,
                  'body_start_pos' => node.content.body_start_pos,
                  'level' => node.node_depth}
    end
  end
  VIM::command("return #{regions.inspect.gsub(/=>/, ':')}")
ERC
endfunction"}}}

function! vorax#ruby#SubprocUnderCursor(text, pos) abort"{{{
  ruby <<ERC
  modules = Vorax::Parser.plsql_structure(VIM::evaluate('a:text'))
  crr_module = modules.find { |subprog| (subprog.start_pos..subprog.end_pos).include?(VIM::evaluate('a:pos')) }
  if crr_module
    VIM::command("return #{crr_module.name.inspect}")
  else
    VIM::command("return ''")
  end
ERC
endfunction"}}}

function! vorax#ruby#RemoveAllComments(text) abort"{{{
	ruby <<ERC
	clear_text = Vorax::Parser.remove_all_comments(VIM::evaluate('a:text'))
	VIM::command("return #{clear_text.inspect}")
ERC
endfunction"}}}

" }}}

" SqlPlus Interaction {{{

" add some helper methods to Vorax module"{{{
ruby <<ERC
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

function! vorax#ruby#SqlplusIsInitialized() abort"{{{
  ruby VIM::command("return #{Vorax::sqlplus_initialized? ? 1 : 0}")
endfunction

function! vorax#ruby#SqlplusIsAlive() abort
  if vorax#ruby#SqlplusIsInitialized()
    ruby VIM::command("return #{Vorax::sqlplus_alive? ? 1 : 0}")
  else
    return 0
  endif
endfunction"}}}

function! vorax#ruby#SqlplusExec(command, ...) abort"{{{
  ruby <<ERC
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
  Vorax::with_sqlplus do |sp|
    status = (sp.busy? ? 1 : 0)
    VIM::command("return #{status}")
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlplusEofOutput() abort"{{{
  ruby <<ERC
  Vorax::with_sqlplus do |sp|
    status = (sp.eof? ? 1 : 0)
    VIM::command("return #{status}")
  end
ERC
endfunction"}}}

function! vorax#ruby#SqlplusSetFunnel(type) abort"{{{
  ruby <<ERC
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

