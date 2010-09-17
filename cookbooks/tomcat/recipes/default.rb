#
# Cookbook Name:: tomcat
# Recipe:: default
#

TOMCAT_VERSION = "6.0.29"
TOMCAT_INSTALL_DIR = "apache-tomcat-#{TOMCAT_VERSION}"
TOMCAT_INSTALL_FILE = "#{TOMCAT_INSTALL_DIR}.tar.gz"
TOMCAT_INSTALL_FILE_CHECKSUM = "f9eafa9bfd620324d1270ae8f09a8c89"

include_recipe "java"

# TODO: Add APR support, this package installs an old version not suitable for tomcat 6.0.26+
#package "dev-java/tomcat-native" do
#  action :install
#end

#package "www-servers/tomcat" do
#  action :install
#end

remote_file "/tmp/#{TOMCAT_INSTALL_FILE}" do
  owner node[:owner_name]
  group node[:owner_name]
  source "http://apache.mirror.facebook.net/tomcat/tomcat-#{TOMCAT_VERSION.split(".").first}/v#{TOMCAT_VERSION}/bin/#{TOMCAT_INSTALL_FILE}"
  mode "0644"
  checksum TOMCAT_INSTALL_FILE_CHECKSUM
end

directory "/opt/apache-tomcat" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0740"
  action :create
end

execute "unarchive-and-install-tomcat" do
  cwd "/opt/apache-tomcat"
  user node[:owner_name]
  command %Q{
    tar -zxf /tmp/#{TOMCAT_INSTALL_FILE}
  }
  creates "/opt/apache-tomcat/#{TOMCAT_INSTALL_DIR}"
end

link "/opt/apache-tomcat/default" do
  to "/opt/apache-tomcat/#{TOMCAT_INSTALL_DIR}"
end

template "/opt/apache-tomcat/default/conf/server.xml" do
  owner node[:owner_name]
  group node[:owner_name]
  source 'server.xml.erb'
  variables({
    :shutdown_port => "8005",
    :port => "9090",
    :secure_port => "9443",
    :ajp_port => "9009"
  })
end

template "/opt/apache-tomcat/default/bin/setenv.sh" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0740"
  source 'setenv.sh.erb'
  variables({
    :env_type => node[:environment][:framework_env]
  })
end

execute "start-tomcat" do
  user node[:owner_name]
  command %Q{
    /opt/apache-tomcat/default/bin/startup.sh
  }
  not_if "pgrep -f tomcat"
end
