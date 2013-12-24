# encoding: UTF-8

require 'ferret'
require 'find'
require 'nokogiri'
require 'cgi'
require 'pathname'

include Ferret

module Vorax

  module Oradoc

    def self.all_books(doc_folder)
      nbsp = Nokogiri::HTML("&nbsp;").text
      folder = Pathname.new(doc_folder).realpath
      books_list = []
      Dir["#{folder}/**/index.htm"].each do |index_file|
        File.open(index_file) do |file|
          doc = Nokogiri::HTML(file)
          book = doc.at("meta[@name='doctitle']/@content").to_s
          book.gsub!(/^Oracle[^[:ascii:]] /, '')
          book.gsub!(nbsp, " ")
          unless book.empty?
            books_list << book
            yield(book, index_file) if block_given?
          end
        end
      end
      books_list
    end

    def self.create_index(doc_folder, index_folder, selective_books = nil)
      folder = Pathname.new(doc_folder).realpath
      nbsp = Nokogiri::HTML("&nbsp;").text
      filter = "."
      if selective_books && !selective_books.empty?
        filter = selective_books.map { |b| "^(#{Regexp.escape(b)})" }.join('|')
      end
      index = Index::Index.new(:path => index_folder,
                               :id_field => 'content',
                               :create => true)
      all_books(folder) do |book, index_file|
        VIM::command "redraw | echo vorax#utils#Throbber() . ' Searching... <q> to abort.'"
        return if Oradoc::abort?
        if book =~ /^#{filter}/ 
          Dir[File.dirname(index_file) + "/**/*.htm"].each do |path|
            File.open(path) do |file|
              VIM::command "redraw | echo vorax#utils#Throbber() . ' Indexing: #{book[(0..30)].gsub(/'/,'''')}... <q> to abort.'"
              return if Oradoc::abort?
              doc = Nokogiri::HTML(file)
              title = doc.at("head/title").content
              index.add_document :file => path, 
                :content => doc.text.split,
                :title => title.to_s,
                :book => book.to_s
            end
          end
        end
      end
      VIM::command "redraw | echo 'Optimizing index...'"
      index.optimize
      VIM::command "redraw | echo 'Done!'"
    end

    def self.search(index_folder, what, max_results = nil)
      nbsp = Nokogiri::HTML("&nbsp;").text
      index = Index::Index.new(:path => index_folder, 
                              :id_field => 'content',
                              :create => false)
      results = []
      maxr = max_results || :all
      index.search_each(what, :limit => maxr) do |doc, score| 
        title = index[doc]['title']
        book = index[doc]['book']
        results << {:title => title.gsub(nbsp, " "),
          :book => book.gsub(nbsp, " "),
          :file => index[doc]['file'],
          :score => score}
      end
      return results
    end

    private

    def self.abort?
      key = VIM::evaluate('getchar(0)').to_i
      if key.chr == 'q'
        VIM::command "redraw | echo 'Aborted!'"
        return true
      else
        return false
      end
    end

  end

end
