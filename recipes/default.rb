#
# Cookbook Name:: chef-perdition
# Recipe:: default
#
# Copyright (C) 2015 stephane LII
#
# All rights reserved - Do Not Redistribute
#
package 'perdition' do
    action :install
end

package 'ldap-utils' do
    action :install
end

service 'perdition' do
    supports restart: true, reload: true , stop:true
    action [:enable, :stop]
end

template node['chef-perdition']['ldap-path-conf'] do
  source 'ldap-conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template node['chef-perdition']['genbase-script'] do
  source 'genbase.erb'
  owner 'root'
  group 'root'
  mode '0700'
end

template node['chef-perdition']['path-config'] do
  source 'perdition-default.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[perdition]'
end

genere = "#{node['chef-perdition']['genbase-script']}"

bash 'genpopmap' do
  user 'root'
  cwd "#{node['chef-perdition']['perdition_home']}" 
  code <<-EOH
   #{genere}
  EOH
  notifies :restart, 'service[perdition]'
end

cron "genpopmap" do
   user 'root'
   action :create
   minute '*/10'
   hour   '*'
   month  '*'
   day    '*'
   weekday '*'
   command "#{genere}"
end
