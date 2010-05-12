#
# Cookbook Name:: solr
# Recipe:: default
#

APP_NAME = node[:applications].keys.first
NODE_NAME = node[:name]
TOMCAT_VERSION = "1.4.0"
TOMCAT_INSTALL_DIR = "apache-solr-#{TOMCAT_VERSION}"
TOMCAT_INSTALL_FILE = "#{TOMCAT_INSTALL_DIR}.tgz"
TOMCAT_INSTALL_FILE_CHECKSUM = "1cc3783316aa1f95ba5e250a4c1d0451"

include_recipe "java"

remote_file "/tmp/#{TOMCAT_INSTALL_FILE}" do
  owner node[:owner_name]
  group node[:owner_name]
  source "http://apache.mirror.facebook.net/lucene/solr/#{TOMCAT_VERSION}/#{TOMCAT_INSTALL_FILE}"
  mode "0644"
  checksum TOMCAT_INSTALL_FILE_CHECKSUM
end