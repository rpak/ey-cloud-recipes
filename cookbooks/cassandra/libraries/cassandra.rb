class Chef
  class Recipe
    def configure
      template File.join("/data/#{app_name}/current",'config', 'cassandra', 'storage-conf.xml') do
        owner node[:owner_name]
        group node[:owner_name]
        source 'storage-conf.xml.erb'
        variables({
          :app_name => app_name
        })
      end
    end
  end
end