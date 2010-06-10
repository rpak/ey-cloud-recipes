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

if node[:name] != nil && node[:name].include?("job")
  cron "br-jobs-aggregate" do
    minute "*/5"
    user node[:owner_name]
    command "cd /data/#{APP_NAME}/current && RAILS_ENV=#{node[:environment][:framework_env]} rake br:jobs:aggregate > /data/#{APP_NAME}/shared/log/br-jobs-aggregate.log"
  end
  cron "br-jobs-solr" do
    minute "*/2"
    user node[:owner_name]
    command "cd /data/#{APP_NAME}/current && RAILS_ENV=#{node[:environment][:framework_env]} rake br:jobs:solr > /data/#{APP_NAME}/shared/log/br-jobs-solr.log"
  end
  cron "br-jobs-blast" do
    minute "*/2"
    user node[:owner_name]
    command "cd /data/#{APP_NAME}/current && RAILS_ENV=#{node[:environment][:framework_env]} rake br:jobs:blast > /data/#{APP_NAME}/shared/log/br-jobs-blast.log"
  end
  cron "br-jobs-facebook" do
    minute "*/2"
    user node[:owner_name]
    command "cd /data/#{APP_NAME}/current && RAILS_ENV=#{node[:environment][:framework_env]} rake br:jobs:facebook > /data/#{APP_NAME}/shared/log/br-jobs-facebook.log"
  end
end

# */5 * * * * cd /data/bitchroom/current && RAILS_ENV=staging rake br:jobs:aggregate > /data/bitchroom/shared/log/br-jobs-aggregate.log
# */1 * * * * cd /data/bitchroom/current && RAILS_ENV=staging rake br:jobs:solr > /data/bitchroom/shared/log/br-jobs-solr.log
# */1 * * * * cd /data/bitchroom/current && RAILS_ENV=staging rake br:jobs:blast > /data/bitchroom/shared/log/br-jobs-blast.log
