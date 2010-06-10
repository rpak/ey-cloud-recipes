
APP_NAME = node[:applications].keys.first

execute "restart-nginx" do
  command %Q{
    sudo /etc/init.d/nginx restart
  }
  action :nothing
end

if node[:instance_role].include?("app") # && (node[:environment][:framework_env] == 'production')
  template "/etc/nginx/servers/#{APP_NAME}.rewrites" do
    owner node[:owner_name]
    group node[:owner_name]
    source 'nginx.rewrites.erb'
    variables({
      :app_name => APP_NAME
    })
    not_if "grep www /etc/nginx/servers/#{APP_NAME}.rewrites"
    notifies :run, resources(:execute => "restart-nginx")
  end
end
