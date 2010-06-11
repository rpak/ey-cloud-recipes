#
# Cookbook Name:: cassandra_client
# Recipe:: default
#
APP_NAME = node[:applications].keys.first

execute "restart-servers" do
  command %Q{
    echo "sudo monit restart all -g #{APP_NAME}" | at now
  }
  action :nothing
end

execute "reload-haproxy" do
  command %Q{
    /etc/init.d/haproxy reload
  }
  action :nothing
end

cassandra_nodes = node[:utility_instances].find_all {|v| v[:name].include?("cass")}
# servers = (cassandra_nodes.collect{|n| n[:hostname] + ":9160"}).join ","
servers = '127.0.0.1:9160'

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

execute "ha-proxy-add-cassandra" do
  command %Q{
    echo '' >> /etc/haproxy.cfg && echo 'listen cassandra :9160' >> /etc/haproxy.cfg && echo '  mode tcp' >> /etc/haproxy.cfg
  }
  not_if 'grep cassandra /etc/haproxy.cfg' 
end

cassandra_nodes.each_with_index do |n, i|
  execute "add-node" do
    command %Q{
      echo '  server cass-#{i} #{n[:hostname]}:9160 check inter 5000 fastinter 1000 fall 1 weight #{i == 0 ? '50' : '49'}' >> /etc/haproxy.cfg
    }
    not_if "grep #{n[:hostname]}:9160 /etc/haproxy.cfg"
    notifies :run, resources(:execute => "reload-haproxy")
  end
end
