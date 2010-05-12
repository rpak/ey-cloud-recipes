#
# Cookbook Name:: solr
# Recipe:: default
#

APP_NAME = node[:applications].keys.first
SOLR_VERSION = "1.4.0"
SOLR_INSTALL_DIR = "apache-solr-#{SOLR_VERSION}"
SOLR_INSTALL_FILE = "#{SOLR_INSTALL_DIR}.tgz"
SOLR_INSTALL_FILE_CHECKSUM = "1cc3783316aa1f95ba5e250a4c1d0451"

include_recipe "tomcat"

remote_file "/tmp/#{SOLR_INSTALL_FILE}" do
  owner node[:owner_name]
  group node[:owner_name]
  source "http://apache.mirror.facebook.net/lucene/solr/#{SOLR_VERSION}/#{SOLR_INSTALL_FILE}"
  mode "0644"
  checksum SOLR_INSTALL_FILE_CHECKSUM
end

directory "/data/solr" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0640"
  action :create
end

directory "/data/solr/data" do
  owner node[:owner_name]
  group node[:owner_name]
  mode "0640"
  action :create
end

execute "unarchive-solr" do
  user node[:owner_name]
  cwd "/tmp"
  command %Q{
    tar -zxf #{SOLR_INSTALL_FILE}
  }
  creates "/tmp/#{SOLR_INSTALL_DIR}"
end

execute "install-solr" do
  user node[:owner_name]
  cwd "/tmp/#{SOLR_INSTALL_DIR}/dist/"
  command %Q{
    cp #{SOLR_INSTALL_DIR}.war /opt/apache-tomcat/default/webapps/solr.war
  }
  creates "/opt/apache-tomcat/default/webapps/solr"
end

execute "set-solr-home" do
  command %Q{
    export JAVA_OPTS="$JAVA_OPTS -Dsolr.data.dir=/data/solr/data"
  }
end

execute "stop-tomcat" do
  returns 1
  command %Q{
    /opt/apache-tomcat/default/bin/catalina.sh stop
  }
  action :nothing
end

template "/opt/apache-tomcat/default/conf/Catalina/localhost/solr.xml" do
  owner node[:owner_name]
  group node[:owner_name]
  source 'solr.xml.erb'
  variables({
    :solr_home => "/data/#{APP_NAME}/current/config/solr/"
  })
  notifies :run, resources(:execute => "stop-tomcat"), :immediately
end

execute "start-tomcat" do
  command %Q{
    /opt/apache-tomcat/default/bin/catalina.sh start
  }
  not_if "sleep 5 && pgrep -f tomcat"
end

