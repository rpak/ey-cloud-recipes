#
# Cookbook Name:: paperclip
# Recipe:: default
#
if ['solo', 'app', 'app_master'].include?(node[:instance_role])

  template "/data/config/paperclip.yml" do
    source "paperclip.yml.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
    variables({
            :access_key_id => node[:aws_secret_id],
            :secret_access_key => node[:aws_secret_key]
    })
  end

end