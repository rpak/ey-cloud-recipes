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

    include_recipe "java"

    remote_file "/tmp/cassandra.tar.gz" do
      source "http://apache.mirror.facebook.net/cassandra/0.6.1/apache-cassandra-0.6.1-bin.tar.gz"
      mode "0644"
      checksum "6aa1764f76e26fbc9d62b59e2f6a9ab4"
    end

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


