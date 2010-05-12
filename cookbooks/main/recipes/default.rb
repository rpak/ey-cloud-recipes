execute "testing" do
  command %Q{
    echo "i ran at #{Time.now}" >> /root/cheftime
  }
end

if node[:instance_role] == 'util' && (node[:name] != nil && node[:name].include?("cass"))
  require_recipe 'cassandra'
  require_recipe 'solr'
end

if node[:instance_role].include?("app") || (node[:name] != nil && node[:name].include?("job"))
  require_recipe 'solr_client'
  require_recipe 'cassandra_client'
end

#require_recipe 'paperclip'
#require_recipe 'google_analytics'
#require_recipe 'ssmtp'
#require_recipe 'delayed_job'
# require_recipe 's3fs'

# uncomment if you want to run couchdb recipe
# require_recipe "couchdb"

# uncomment to turn use the MBARI ruby patches for decreased memory usage and better thread/continuationi performance
# require_recipe "mbari-ruby"

# uncomment to turn on thinking sphinx 
# require_recipe "thinking_sphinx"

# uncomment to turn on ultrasphinx 
# require_recipe "ultrasphinx"

#uncomment to turn on memcached
# require_recipe "memcached"
