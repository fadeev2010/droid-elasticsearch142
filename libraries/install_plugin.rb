module Extensions

  # Install an Elasticsearch plugin
  #
  # In the simplest form, just pass a plugin name in the GitHub <user>/<repo> format:
  #
  #     install_plugin 'karmi/elasticsearch-paramedic'
  #
  # You may also optionally pass a version:
  #
  #     install_plugin 'elasticsearch/elasticsearch-mapper-attachments', 'version' => '1.6.0'
  #
  # ... as well as the URL:
  #
  #     install_plugin 'hunspell', 'url' => 'https://github.com/downloads/.../elasticsearch-analysis-hunspell-1.1.1.zip'
  #
  # The "elasticsearch142::plugins" recipe will install all plugins listed in
  # the role/node attributes or in the data bag (`node.elasticsearch142.plugins`).
  #
  # Example:
  #
  #     { elasticsearch: {
  #         plugins: {
  #           'karmi/elasticsearch-paramedic' => {},
  #           'lukas-vlcek/bigdesk'           => { 'version' => '1.0.0' },
  #           'hunspell'                      => { 'url' => 'https://github.com/downloads/...' }
  #         }
  #       }
  #     }
  #
  # See <http://wiki.opscode.com/display/chef/Setting+Attributes+(Examples)> for more info.
  #
  def install_plugin name, params={}

    ruby_block "Install plugin: #{name}" do
      block do
        version = params['version'] ? "/#{params['version']}" : nil
        url     = params['url']     ? " -url #{params['url']}" : nil

        command = "#{node.elasticsearch142[:bindir]}/plugin -install #{name}#{version}#{url}"
        Chef::Log.debug command

        raise "[!] Failed to install plugin" unless system command

        # Ensure proper permissions
        raise "[!] Failed to set permission" unless system "chown -R #{node.elasticsearch142[:user]}:#{node.elasticsearch142[:user]} #{node.elasticsearch142[:dir]}/elasticsearch-#{node.elasticsearch142[:version]}/plugins/"
      end

      notifies :restart, 'service[elasticsearch142]' unless node.elasticsearch142[:skip_restart]

      not_if do
        Dir.entries("#{node.elasticsearch142[:dir]}/elasticsearch-#{node.elasticsearch142[:version]}/plugins/").any? do |plugin|
          next if plugin =~ /^\./
          name.include? plugin
        end rescue false
      end

    end

  end

end
