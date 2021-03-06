class LoadCommand < CommandParser
  def initialize
    super
    @parser.banner += <<-EOS

    >>> starman load <package_name>[@<package_version>] ...
EOS
    @parser.on '-cNAME', '--compiler-set NAME', 'Set the active compiler set by its name set in conf file.' do |compiler_set|
      @@args[:compiler_set] = compiler_set
    end
    @parser.on '-w', '--without-deps', 'Do not load dependencies.' do
      @@args[:without_deps] = true
    end
    @parser.on '-a', '--all', 'Load all packages for current compiler set.' do
      @@args[:all] = true
    end
    @parser.on '-p', '--print', 'Print modified environment variables.' do
      @@args[:print] = true
      @@args[:verbose] = false
    end
    @parser.parse!
    parse_packages empty_is_ok: true
  end

  def run
    if @@args[:all]
      append_path Package.link_bin if Dir.exist? Package.link_bin
      append_ld_library_path Package.link_lib if Dir.exist? Package.link_lib
      append_ld_library_path Package.link_lib64 if Dir.exist? Package.link_lib64
      append_pkg_config_path Package.link_lib + '/pkgconfig' if Dir.exist? Package.link_lib + '/pkgconfig'
      append_pkg_config_path Package.link_lib64 + '/pkgconfig' if Dir.exist? Package.link_lib64 + '/pkgconfig'
      append_manpath Package.link_man if Dir.exist? Package.link_man
      append_path Package.common_bin if Package.common_bin
      append_ld_library_path Package.common_lib if Dir.exist? Package.common_lib
      append_ld_library_path Package.common_lib64 if Dir.exist? Package.common_lib64
      append_pkg_config_path Package.common_lib + '/pkgconfig' if Dir.exist? Package.common_lib + '/pkgconfig'
      append_pkg_config_path Package.common_lib64 + '/pkgconfig' if Dir.exist? Package.common_lib64 + '/pkgconfig'
      append_manpath Package.common_man if Dir.exist? Package.common_man
    else
      PackageLoader.loaded_packages.each do |name, package|
        next if (not PackageLoader.from_cmd_line? package and CommandParser.args[:without_deps]) or package.skipped?
        if package.has_label? :group
          CLI.notice "Load package group #{CLI.green package.name}@#{CLI.blue package.version} ..." if CommandParser.args[:verbose]
        elsif not History.installed?(package)
          CLI.warning "Package #{CLI.red package.name}@#{CLI.blue package.version} has not been installed."
        else
          CLI.notice "Load package #{CLI.green package.name}@#{CLI.blue package.version} ..." if CommandParser.args[:verbose]
          append_path package.bin if Dir.exist? package.bin
          append_ld_library_path package.lib if Dir.exist? package.lib
          append_ld_library_path package.lib64 if Dir.exist? package.lib64
          append_pkg_config_path package.lib + '/pkgconfig' if Dir.exist? package.lib + '/pkgconfig'
          append_pkg_config_path package.lib64 + '/pkgconfig' if Dir.exist? package.lib64 + '/pkgconfig'
          append_manpath package.man if Dir.exist? package.man
          package.export_env
        end
      end
    end
    if @@args[:print]
      if @@args[:all]
        print "export STARMAN_INSTALL_ROOT=#{Package.link_root}\n"
      else
        PackageLoader.loaded_packages.each do |name, package|
          next unless PackageLoader.from_cmd_line? package
          env_name = name.to_s.gsub('-', '_').upcase
          print "export #{env_name}_ROOT=#{package.prefix}\n"
          print "export #{env_name}_DIR=#{package.prefix}\n"
          print "export #{env_name}_PATH=#{package.prefix}\n"
        end
      end
      added_env.each do |key, val|
        print "export #{key}=#{val}\n"
      end
      appended_env.each do |key, val|
        print "export #{key}=#{val}\n"
      end
    end
  end
end
