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
      owner "deploy"
      source "http://apache.mirror.facebook.net/cassandra/0.6.1/apache-cassandra-0.6.1-bin.tar.gz"
      mode "0644"
      checksum "6aa1764f76e26fbc9d62b59e2f6a9ab4"
    end



#    execute "unarchive-and-install-cassandra" do
#      cwd "/opt"
#      command %Q{
#        tar -zxf /tmp/cassandra.tar.gz
#      }
#    end

    configure()

  end

end
