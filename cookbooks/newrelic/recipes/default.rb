#
# Cookbook Name:: newrelic
# Recipe:: default
#

APP_NAME = node[:applications].keys.first
ENV_TYPE = node[:environment][:framework_env]
PREMIUM_KEY = 'a7c3260c60ddca0fc18312af8b4d5b9c0b69725a'
DEFAULT_KEY = '396ccb0ba3d5e5c2d3bbd9f05241ba649d106156'

#
# Rails
#
if node[:instance_role].include?("app")
  template "/data/#{APP_NAME}/newrelic.yml" do
    owner node[:owner_name]
    group node[:owner_name]
    source 'newrelic.yml.erb'
    variables({
      :new_relic_app_name => APP_NAME,
      :license_key => ((node[:instance_role] == ("app_master") && ENV_TYPE == 'production') ? PREMIUM_KEY : DEFAULT_KEY),
      :env_type => node[:environment][:framework_env]
    })
  end
end

if node[:instance_role] == 'util' && (node[:name] != nil && node[:name].include?("cass"))
  #
  # SOLR
  #
  directory "/opt/apache-tomcat" do
    owner node[:owner_name]
    group node[:owner_name]
    mode "0740"
    action :create
  end

  directory "/opt/apache-tomcat/newrelic" do
    owner node[:owner_name]
    group node[:owner_name]
    mode "0740"
    action :create
  end

  remote_file "/opt/apache-tomcat/newrelic/newrelic.jar" do
    source "newrelic.jar"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
  end

  template "/opt/apache-tomcat/newrelic/newrelic.yml" do
    owner node[:owner_name]
    group node[:owner_name]
    source 'newrelic.yml.erb'
    variables({
      :new_relic_app_name => (APP_NAME + "_tomcat"),
      :license_key => DEFAULT_KEY,
      :env_type => ENV_TYPE
    })
  end

  #
  # Cassandra
  #
  directory "/opt/cassandra" do
    owner node[:owner_name]
    group node[:owner_name]
    mode "0740"
    action :create
  end

  directory "/opt/cassandra/newrelic" do
    owner node[:owner_name]
    group node[:owner_name]
    mode "0740"
    action :create
  end

  remote_file "/opt/cassandra/newrelic/newrelic.jar" do
    source "newrelic.jar"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
  end

  template "/opt/cassandra/newrelic/newrelic.yml" do
    owner node[:owner_name]
    group node[:owner_name]
    source 'newrelic.yml.erb'
    variables({
      :new_relic_app_name => (APP_NAME + "_cassandra"),
      :license_key => DEFAULT_KEY,
      :env_type => ENV_TYPE
    })
  end
end