#
# Cookbook Name:: solr_client
# Recipe:: default
#
APP_NAME = node[:applications].keys.first
SOLR_ENDPOINT = " http://#{(node[:utility_instances].find {|v| v[:name].include?("cass")})[:hostname]}:9090/solr"

template "/data/#{APP_NAME}/current/config/solr.yml" do
  owner node[:owner_name]
  group node[:owner_name]
  source 'solr.yml.erb'
  variables({
    :env_type => node[:environment][:framework_env],
    :solr_endpoint => SOLR_ENDPOINT
  })
end
