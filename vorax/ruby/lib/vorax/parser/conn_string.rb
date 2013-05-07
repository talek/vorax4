# encoding: utf-8

require 'strscan'

module Vorax

  module Parser

    # A class used to parse a connection string.
    class ConnString

      # Parse the given connection string.
      #
      # @return [Hash] a hash with the following keys:
      #
      # :user => the username,
      # :password => the password,
      # :db => the target database,
      # :role => sysdba, sysasm or sysoper (if that's the case),
      # :prompt_for => when some pieces are missing (e.g. password), the corresponding keys from above is put here
      def parse(cstr)
        # well known connection strings:
        #   - user => just the password will be prompted
        #   - user/pwd
        #   - user@db => just the password will be prompted
        #   - user/pwd@db [as sysdba|sysoper|sysasm]
        #   - /
        #   - / [as sysdba|sysoper|sysasm}
        #   - /@db => use wallet
        Vorax::debug("parse connection string #{cstr.inspect}")
        result = {:user => '', :password => '', :db => '', :role => '', :prompt_for => nil}
        input = cstr.strip
        scanner = StringScanner.new(input)
        result[:user] = unquoted_scan(scanner, /[@\/]/)
        has_pwd_slash = false

        if scanner.matched?
          # we have a @ or a / in our connection string
          result[:user].chop!
          if scanner.matched == "/"
            has_pwd_slash = true
            result[:password] = unquoted_scan(scanner, /@/)
            if scanner.matched?
              # there is a "@" so we know where to stop to extract the pwd
              result[:password].chop!
              extract_db(scanner, result)
            else
              # there's no "@" so assume everything to be the password
              # except for the role
              result[:password] = scanner.scan_until(/\z/)
              extract_role(result, :password)
            end
          elsif scanner.matched == "@"
            extract_db(scanner, result)
          end
        else
          # we don't have a @ or a / in our connection string
          result[:user] = input
        end
        result[:user] = strip_quotes(result[:user])
        result[:password] = strip_quotes(result[:password])
        if result[:user].empty? && result[:password].empty? && has_pwd_slash
          # assume OS authentication
          result[:prompt_for] = nil
        else
          if result[:user].empty?
            result[:prompt_for] = :user
          elsif (not result[:user].empty?) && result[:password].empty?
            result[:prompt_for] = :password
          end
        end
        result
      end

      private

      def strip_quotes(text)
        text.gsub(/\A"|"\z/, '')
      end

      def extract_db(scanner, cstr_hash)
        cstr_hash[:db] = scanner.scan_until(/\z/)
        extract_role(cstr_hash, :db)
      end

      def extract_role(cstr_hash, from_attr)
        cstr_hash[from_attr].sub!(/\s+as\s+(sysdba|sysoper|sysasm)\z/i, '')
        cstr_hash[:role] = $1.downcase if $1
      end

      def unquoted_scan(scanner, pattern)
        result = ''
        begin
          fragment = scanner.scan_until(pattern)
          result << fragment if fragment
        end while fragment && result.count('"').odd? # go on if between quotes
        result
      end

    end

  end

end
