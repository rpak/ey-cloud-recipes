#
# Cookbook Name:: cassandra
# Recipe:: default
#
#package "dev-java/sun-jdk" do
#  action :install
#end
#
#package "openjdk-6-jre" do
#  action :install
#end

node[:applications].each do |app_name, data|

  if node[:instance_role] == 'util' && (node[:name] != nil && node[:name].include?("cass"))
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


