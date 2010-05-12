#
# Cookbook Name:: tomcat
# Recipe:: default
#

TOMCAT_VERSION = "6.0.26"
TOMCAT_INSTALL_DIR = "apache-tomcat-#{TOMCAT_VERSION}"
TOMCAT_INSTALL_FILE = "#{TOMCAT_INSTALL_DIR}.tar.gz"
TOMCAT_INSTALL_FILE_CHECKSUM = "f9eafa9bfd620324d1270ae8f09a8c89"

include_recipe "java"

package "dev-java/tomcat-native" do
  action :install
end

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
  command %Q{
    tar -zxf /tmp/#{TOMCAT_INSTALL_FILE}
  }
  creates "/opt/apache-tomcat/#{TOMCAT_INSTALL_DIR}"
end

link "/opt/apache-tomcat/default" do
  to "/opt/apache-tomcat/#{TOMCAT_INSTALL_DIR}"
end

execute "ensure-permissions-for-tomcat" do
  cwd "/opt"
  command %Q{
    chown -R #{node[:owner_name]} apache-tomcat/
  }
  creates "/opt/apache-tomcat/#{TOMCAT_INSTALL_DIR}"
end

execute "start-tomcat" do
  command %Q{
    /opt/apache-tomcat/default/bin/startup.sh
  }
  not_if "pgrep -f tomcat"
end
