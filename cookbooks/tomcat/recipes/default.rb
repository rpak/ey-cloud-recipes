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

remote_file "/tmp/#{TOMCAT_INSTALL_FILE}" do
  owner node[:owner_name]
  group node[:owner_name]
  source "http://apache.mirror.facebook.net/tomcat/tomcat-#{TOMCAT_VERSION.split(".").first}/v#{TOMCAT_VERSION}/bin/#{TOMCAT_INSTALL_FILE}"
  mode "0644"
  checksum TOMCAT_INSTALL_FILE_CHECKSUM
end

execute "unarchive-and-install-tomcat" do
  cwd "/opt"
  command %Q{
    tar -zxf /tmp/#{TOMCAT_INSTALL_FILE}
  }
  creates "/opt/#{TOMCAT_INSTALL_DIR}"
end

link "/opt/tomcat" do
  to "/opt/#{TOMCAT_INSTALL_DIR}"
end

execute "ensure-permissions-for-tomcat" do
  cwd "/opt"
  command %Q{
    chown -R #{node[:owner_name]} tomcat/
  }
  creates "/opt/#{TOMCAT_INSTALL_DIR}"
end

execute "start-tomcat" do
  returns 1
  command %Q{
    /opt/tomcat/bin/startup.sh
  }
  not_if "pgrep -f tomcat"
end