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

APP_NAME = node[:applications].keys.first
CASSANDRA_VERSION = "0.6.1"
CASSANDRA_INSTALL_DIR = "apache-cassandra-#{CASSANDRA_VERSION}"
CASSANDRA_INSTALL_FILE = "#{CASSANDRA_INSTALL_DIR}-bin.tar.gz"

include_recipe "java"

remote_file "/tmp/apache-cassandra-0.6.1-bin.tar.gz" do
  owner node[:owner_name]
  group node[:owner_name]
  source "http://apache.mirror.facebook.net/cassandra/#{CASSANDRA_VERSION}/#{CASSANDRA_INSTALL_FILE}"
  mode "0644"
  checksum "6aa1764f76e26fbc9d62b59e2f6a9ab4"
end

execute "unarchive-and-install-cassandra" do
  cwd "/opt"
  command %Q{
    tar -zxf /tmp/#{CASSANDRA_INSTALL_FILE}
  }
end

link "/opt/cassandra" do
  to "/opt/#{CASSANDRA_INSTALL_DIR}"
end

execute "ensure-permissions-for-cassandra" do
  cwd "/opt"
  command %Q{
    chown -R #{node[:owner_name]} cassandra/
  }
end

template File.join("/data/#{APP_NAME}/current",'config', 'cassandra', 'storage-conf.xml') do
  owner node[:owner_name]
  group node[:owner_name]
  source 'storage-conf.xml.erb'
  variables({
    :app_name => APP_NAME
  })
end

#    execute "ensure-cassandra-is-running" do
#      returns 1
#      command %Q{
#        /opt/cassandra/bin/cassandra --host localhost --port 9160
#      }
#      not_if "pgrep -f org.apache.cassandra.service.CassandraDaemon"
#    end
