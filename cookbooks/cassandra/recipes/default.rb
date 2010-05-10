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

# APP_NAME = node[:applications].keys.first
CASSANDRA_VERSION = "0.6.1"
CASSANDRA_INSTALL_DIR = "apache-cassandra-#{CASSANDRA_VERSION}"
CASSANDRA_INSTALL_FILE = "#{CASSANDRA_INSTALL_DIR}-bin.tar.gz"
CASSANDRA_INSTALL_FILE_CHECKSUM = "6aa1764f76e26fbc9d62b59e2f6a9ab4"

node[:applications].each do |app_name, data|
  if node[:instance_role] == 'util' && (node[:name] != nil && node[:name].include?("cass"))
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
      command %Q{
        tar -zxf /tmp/#{CASSANDRA_INSTALL_FILE}
      }
      creates "/opt/#{CASSANDRA_INSTALL_FILE}"
    end

    link "/opt/cassandra" do
      to "/opt/#{CASSANDRA_INSTALL_DIR}"
    end

    execute "ensure-permissions-for-cassandra" do
      cwd "/opt"
      command %Q{
        chown -R #{node[:owner_name]} cassandra/
      }
      creates "/opt/#{CASSANDRA_INSTALL_FILE}"
    end

    directory "/data/cassandra/data" do
      owner node[:owner_name]
      group node[:owner_name]
      mode "0640"
      action :create
    end

    directory "/data/cassandra/logs" do
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
        :app_name => app_name,
        :env_name => node[:environment][:name]
      })
    end

    execute "ensure-cassandra-is-running" do
      returns 1
      command %Q{
        /opt/cassandra/bin/cassandra --host localhost --port 9160
      }
      not_if "pgrep -f org.apache.cassandra.service.CassandraDaemon"
    end
  end
end