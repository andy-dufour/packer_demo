#
# Cookbook Name:: packer_demo
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

execute 'apt-get update' do
  command 'apt-get update'
end

packages = %w( wget unzip curl docker.io )

packages.each do | pkg |
  package pkg
end

directory '/opt/packer/'

execute 'install packer' do
  command 'wget https://dl.bintray.com/mitchellh/packer/packer_0.8.2_linux_amd64.zip; unzip packer_0.8.2_linux_amd64.zip; echo "export PATH=$PATH:/opt/packer/" > /root/.bashrc'
  cwd "/opt/packer"
  not_if { File.exists?('/opt/packer/packer') }
end

directory '/opt/packer-build/cookbooks/' do
  action :create
  recursive true
end

directory "/opt/packer-build/#{node['packer_demo']['cookbook_name']}"

git "/opt/packer-build/#{node['packer_demo']['cookbook_name']}" do
  repository node['packer_demo']['repo']
  action :sync
end

execute 'berks vendor' do
  command 'berks vendor ../cookbooks'
  cwd "/opt/packer-build/#{node['packer_demo']['cookbook_name']}"
end

directory '/opt/packerfiles/'

template '/opt/packerfiles/chef.json' do
  source 'machine-file.json'
end

execute 'build docker image' do
  command 'export PATH=$PATH:/opt/packer/;packer build chef.json'
  cwd '/opt/packerfiles'
end
