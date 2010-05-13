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
    command "cd /data/#{APP_NAME}/current && rake br:jobs:aggregate"
  end
  cron "br-jobs-solr" do
    minute "/2"
    command "cd /data/#{APP_NAME}/current && rake br:jobs:solr"
  end
  cron "br-jobs-blast" do
    minute "/2"
    command "cd /data/#{APP_NAME}/current && rake br:jobs:blast"
  end
end