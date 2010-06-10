#
# Cookbook Name:: solr_client
# Recipe:: default
#
APP_NAME = node[:applications].keys.first
SOLR_ENDPOINT = "http://localhost:9090/solr"

solr_nodes = node[:utility_instances].find_all {|v| v[:name].include?("cass")}

execute "reload-haproxy" do
  command %Q{
    /etc/init.d/haproxy reload
  }
  action :nothing
end

template "/data/#{APP_NAME}/current/config/solr.yml" do
  owner node[:owner_name]
  group node[:owner_name]
  source 'solr.yml.erb'
  variables({
    :env_type => node[:environment][:framework_env],
    :solr_endpoint => SOLR_ENDPOINT
  })
end

execute "ha-proxy-add-solr" do
  command %Q{
    echo '' >> /etc/haproxy.cfg && echo 'listen solr :9090' >> /etc/haproxy.cfg
  }
  not_if 'grep solr /etc/haproxy.cfg'
end

solr_nodes.each_with_index do |n, i|
  execute "add-node" do
    command %Q{
      echo '  server solr-#{i} #{n[:hostname]}:9090 check inter 5000 fastinter 1000 fall 1 weight #{i == 0 ? '50' : '49'}' >> /etc/haproxy.cfg
    }
    not_if "grep #{n[:hostname]}:9090 /etc/haproxy.cfg"
    notifies :run, resources(:execute => "reload-haproxy")
  end
end
