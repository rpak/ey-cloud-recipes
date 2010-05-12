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

execute "unarchive-and-install-cassandra" do
  cwd "/opt"
  user node[:owner_name]
  command %Q{
    tar -zxf /tmp/#{CASSANDRA_INSTALL_FILE}
  }
  creates "/opt/#{CASSANDRA_INSTALL_FILE}"
end

link "/opt/cassandra" do
  to "/opt/#{CASSANDRA_INSTALL_DIR}"
end
#
#execute "ensure-permissions-for-cassandra" do
#  cwd "/opt"
#  command %Q{
#    chown -R #{node[:owner_name]} cassandra/
#  }
#  creates "/opt/#{CASSANDRA_INSTALL_FILE}"
#end

directory "/data/cassandra" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0640"
  action :create
end

directory "/data/cassandra/data" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0640"
  action :create
end

directory "/data/cassandra/commits" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0640"
  action :create
end

directory "/var/log/cassandra" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0640"
  action :create
end

template "/opt/cassandra/conf/storage-conf.xml" do
  owner node[:owner_name]
  group node[:owner_name]
  source 'storage-conf.xml.erb'
  variables({
    :app_name => APP_NAME,
    :env_name => node[:environment][:name],
    :utility_instance => node[:utility_instances].find {|v| v[:name] == NODE_NAME}
  })
#  notifies :run, resources(:execute => "stop-cassandra"), :immediately
end

execute "stop-cassandra" do
  command %Q{
    kill `ps -ef | grep cassandra | grep -v grep | awk '{print $2}'`
  }
  action :nothing
end

execute "start-cassandra" do
  returns 1
  command %Q{
    /opt/cassandra/bin/cassandra --host localhost --port 9160
  }
  not_if "pgrep -f org.apache.cassandra.service.CassandraDaemon"
end
