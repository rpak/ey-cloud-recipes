#
# Cookbook Name:: cassandra
# Recipe:: default
#

APP_NAME = node[:applications].keys.first
NODE_NAME = node[:name]
CASSANDRA_VERSION = "0.6.1"
CASSANDRA_INSTALL_DIR = "apache-cassandra-#{CASSANDRA_VERSION}"
CASSANDRA_INSTALL_FILE = "#{CASSANDRA_INSTALL_DIR}-bin.tar.gz"
CASSANDRA_INSTALL_FILE_CHECKSUM = "6aa1764f76e26fbc9d62b59e2f6a9ab4"

include_recipe "java"

remote_file "/tmp/#{CASSANDRA_INSTALL_FILE}" do
  owner node[:owner_name]
  group node[:owner_name]
  source "http://apache.mirror.facebook.net/cassandra/#{CASSANDRA_VERSION}/#{CASSANDRA_INSTALL_FILE}"
  mode "0644"
  checksum CASSANDRA_INSTALL_FILE_CHECKSUM
end

directory "/opt/cassandra" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0740"
  action :create
end

execute "unarchive-and-install-cassandra" do
  cwd "/opt/cassandra"
  user node[:owner_name]
  command %Q{
    tar -zxf /tmp/#{CASSANDRA_INSTALL_FILE}
  }
  creates "/opt/cassandra/#{CASSANDRA_INSTALL_FILE}"
end

link "/opt/cassandra/default" do
  to "/opt/cassandra/#{CASSANDRA_INSTALL_DIR}"
end

directory "/data/cassandra" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0740"
  action :create
end

directory "/data/cassandra/data" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0740"
  action :create
end

directory "/data/cassandra/commits" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0740"
  action :create
end

directory "/var/log/cassandra" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0740"
  action :create
end

execute "restart-cassandra" do
  returns 1
  user node[:owner_name]
  command %Q{
    /opt/cassandra/default/bin/restart-server
  }
  action :nothing
end

template "/opt/cassandra/default/bin/restart-server" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0740"
  source 'restart-server.erb'
end

template "/opt/cassandra/default/conf/storage-conf.xml" do
  owner node[:owner_name]
  group node[:owner_name]
  source 'storage-conf.xml.erb'
  variables({
    :app_name => APP_NAME,
    :env_name => node[:environment][:name],
    :utility_instance => node[:utility_instances].find {|v| v[:name] == NODE_NAME}
  })
  notifies :run, resources(:execute => "restart-cassandra"), :immediately
end

