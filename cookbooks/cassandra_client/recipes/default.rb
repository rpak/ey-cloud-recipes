#
# Cookbook Name:: cassandra_client
# Recipe:: default
#
APP_NAME = node[:applications].keys.first

execute "restart-servers" do
  command %Q{
    echo "sleep 20 && monit restart all -g #{APP_NAME}" | at now
  }
  action :nothing
end

cassandra_nodes = node[:utility_instances].find_all {|v| v[:name].include?("cass")}
servers = (cassandra_nodes.collect{|n| n[:hostname] + ":9160"}).join ","

template "/data/#{APP_NAME}/current/config/cassandra.yml" do
  owner node[:owner_name]
  group node[:owner_name]
  source 'cassandra.yml.erb'
  variables({
    :env_name => node[:environment][:name],
    :env_type => node[:environment][:framework_env],
    :servers => servers
  })
  notifies :run, resources(:execute => "restart-servers")
end
