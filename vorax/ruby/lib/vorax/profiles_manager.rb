# encoding: UTF-8

require 'base64'

module Vorax

  # A secure password repository. All passwords are encrypted using RSA
  # algorithm. The private key is also protected by a password provided
  # by the user. This password is the master key of the repository.
  class ProfilesManager

    # The file name for the private key
    PRIVATE_KEY = 'id_rsa' unless defined?(PRIVATE_KEY)
    # The file name for the public key
    PUBLIC_KEY = 'id_rsa.pub' unless defined?(PUBLIC_KEY)
    # The file name for the repository file.
    REPOSITORY_FILE = 'profiles.xml' unless defined?(REPOSITORY_FILE)

    attr_reader :repository_xml, :unlocked, :master_password

    # Creates a new repository. The config_dir is the directory
    # where the RSA keys are along with the configuration
    # file. 
    def initialize(config_dir)
      require 'openssl'
      @config_dir = config_dir
      @unlocked = false
      if File.exists?("#@config_dir/#{REPOSITORY_FILE}")
        # the profiles.xml file already exists. Just load it.
        profiles_file = File.open("#{config_dir}/#{REPOSITORY_FILE}")
        @repository_xml = Nokogiri::XML(profiles_file)
        profiles_file.close
      else
        # the profiles.xml file does not exists. Initialize an empty repository.
        @repository_xml = Nokogiri::XML('<profiles></profiles>')
      end
    end

    # Set the master key for the secured repository.
    def master_password=(master_pwd)
      @master_password = master_pwd
      @private_key = OpenSSL::PKey::RSA.new(File.read("#@config_dir/#{PRIVATE_KEY}"), master_pwd)
      @public_key = OpenSSL::PKey::RSA.new(File.read("#@config_dir/#{PUBLIC_KEY}"))
      @unlocked = true
    end

    # Add the provided profile to the repository. The profile is actually
    # a key which usually consists of an user@db stuff. The provided password
    # is encrypted before being added. You can add a profile without a password
    # which means that, for this connection profile, the user will be
    # always asked for a password.
    def add(id, params = {})
      opts = {
        :password => nil,
        :category => '',
        :important => false,
      }.merge(params)
      profile_element = Nokogiri::XML::Node.new("profile", @repository_xml)
      profile_element['id'] = id
      profile_element['password'] = encrypt(opts[:password]) if opts[:password] && !opts[:password].empty?
      profile_element['category'] = opts[:category]
      profile_element['important'] = opts[:important]
      @repository_xml.root.add_child(profile_element)
    end

    def profiles(category = nil)
      profile_ids = []
      @repository_xml.xpath("//profile").each do |profile|
        if category.nil?
          profile_ids << profile["id"]
        else
          profile_ids << profile["id"] if profile['category'] == category
        end
      end
      return profile_ids.sort
    end

    def categories
      categories = []
      @repository_xml.xpath("//profile").each do |profile|
        categories << profile["category"] unless profile["category"].empty?
      end
      return categories.uniq.sort
    end

    def profile(id)
      @repository_xml.at_css("profile[@id='#{id}']")
    end

    def edit(id, property, value)
      profile_element = profile(id)
      profile_element[property] = value
    end

    # Remove the provided profile from the repository.
    def remove(id)
      profile_element = profile(id)
      profile_element.remove if profile_element
    end

    # Does the profile exists?
    def exists?(id)
      profile(id) ? true : false
    end

    # Get the password for the provided profile.
    def password(id)
      profile_element = profile(id)
      if profile_element
        enc_passwd = profile_element['password']
        return decrypt(enc_passwd) if enc_passwd
      end
    end

    # Get an attribute value for the provided profile.
    def attribute(id, attr)
      profile_element = profile(id)
      if profile_element
        profile_element[attr]
      end
    end

    # Save the repository to disk.
    def save
      File.open("#{@config_dir}/#{REPOSITORY_FILE}", 'w') { |f| @repository_xml.write_xml_to(f) }
    end

    # Creates the password repository, secured by the provided
    # password. It overwrites any keys already generated within the
    # config_dir. All profiles from the old repository will be
    # lost.
    def self.create(config_dir, master_pwd)
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      cipher =  OpenSSL::Cipher::Cipher.new('des3')
      private_key = rsa_key.to_pem(cipher, master_pwd)
      public_key = rsa_key.public_key.to_pem
      File.open("#{config_dir}/#{PRIVATE_KEY}", 'w', 0600) { |f| f.puts(private_key) }
      File.open("#{config_dir}/#{PUBLIC_KEY}", 'w') { |f| f.puts(public_key) }
    end

    def self.change_master_pwd(config_dir, old_pwd, new_pwd)
      private_key = OpenSSL::PKey::RSA.new(File.read("#{config_dir}/#{PRIVATE_KEY}"), old_pwd)
      cipher =  OpenSSL::Cipher::Cipher.new('des3')
      private_key = private_key.to_pem(cipher, new_pwd)
      File.open("#{config_dir}/#{PRIVATE_KEY}", 'w', 0600) { |f| f.puts(private_key) }
    end

    # Was the password repository already initialized into the
    # provided directory?
    def self.initialized?(config_dir)
      File.exists?("#{config_dir}/#{PRIVATE_KEY}") && 
        File.exists?("#{config_dir}/#{PUBLIC_KEY}")
    end

    private

    # Encript the provided text. The result is packed in Base64
    def encrypt(text)
      Base64.encode64(@public_key.public_encrypt(text)).gsub(/\n/, "") if text
    end

    # Decrypt the provided text. The input should be in Base64
    def decrypt(text)
      @private_key.private_decrypt(Base64.decode64(text)) if text
    end

  end

end
