execute "testing" do
  command %Q{
    echo "i ran at #{Time.now}" >> /root/cheftime
  }
end

APP_NAME = node[:applications].keys.first

if node[:instance_role] == 'util' && (node[:name] != nil && node[:name].include?("cass"))
  require_recipe 'cassandra'
  require_recipe 'solr'
end

if node[:instance_role].include?("app") || (node[:name] != nil && node[:name].include?("job"))
  require_recipe 'solr_client'
  require_recipe 'cassandra_client'
end

if node[:name] != nil && node[:name].include?("job")
  cron "br-jobs-aggregate" do
    minute "/5"
    user node[:owner_name]
    command "cd /data/#{APP_NAME}/current && rake br:jobs:aggregate > /data/#{APP_NAME}/shared/log/br-jobs-aggregate.log"
  end
  cron "br-jobs-solr" do
    minute "/2"
    user node[:owner_name]
    command "cd /data/#{APP_NAME}/current && rake br:jobs:solr > /data/#{APP_NAME}/shared/log/br-jobs-solr.log"
  end
  cron "br-jobs-blast" do
    minute "/2"
    user node[:owner_name]
    command "cd /data/#{APP_NAME}/current && rake br:jobs:blast > /data/#{APP_NAME}/shared/log/br-jobs-blast.log"
  end
end