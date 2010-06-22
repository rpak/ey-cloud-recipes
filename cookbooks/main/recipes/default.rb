execute "testing" do
  command %Q{
    echo "i ran at #{Time.now}" >> /root/cheftime
  }
end

APP_NAME = node[:applications].keys.first

require_recipe 'newrelic'

if node[:instance_role] == 'util' && (node[:name] != nil && node[:name].include?("cass"))

  package 'net-proxy/haproxy' do
    action :install
  end

  require_recipe 'cassandra'
  require_recipe 'solr'

end

if node[:instance_role].include?("app") || (node[:name] != nil && node[:name].include?("job"))
  require_recipe 'solr_client'
  require_recipe 'cassandra_client'
  require_recipe 'nginx'
end
