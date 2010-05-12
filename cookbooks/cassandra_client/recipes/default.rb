#
# Cookbook Name:: cassandra_client
# Recipe:: default
#
APP_NAME = node[:applications].keys.first

template "/data/#{APP_NAME}/current/config/cassandra.yml" do
  owner node[:owner_name]
  group node[:owner_name]
  source 'cassandra.yml.erb'
  variables({
    :env_name => node[:environment][:name],
    :env_type => node[:environment][:framework_env],
    :cassandra_instance => node[:utility_instances].find {|v| v[:name].include?("cass")}
  })
  # notifies :run, resources(:execute => "restart-servers")
end

execute "restart-servers" do
  command %Q{
    monit restart all -g #{APP_NAME}
  }
  action :nothing
end
