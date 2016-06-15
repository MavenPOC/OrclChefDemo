#
# Cookbook Name:: jenkins_server
# Recipe:: default
#
# Copyright 2016, OFSS
#
# All rights reserved - Do Not Redistribute
#
#Install Jenkins
 #include_recipe 'jenkins::jav
 #node.default['java']['jdk_version']='8'
 #include_recipe 'jenkins::java'
 include_recipe 'jenkins::master'


#Global configuration
 Chef::Log.info("Java home: #{node['jenkins']['java']}:")

#Port Change
 node.default['jenkins']['master']['port'] = 8085
 node.default['jenkins']['master']['endpoint'] = "http://#{node['jenkins']['master']['host']}:#{node['jenkins']['master']['port']}"

 template "#{node['jenkins']['master']['home']}/config.xml" do
   source "config.xml.erb"
 end

 template "#{node['jenkins']['master']['home']}/hudson.tasks.Maven.xml" do
   source 'hudson.tasks.Maven.xml.erb'
 end

 template "#{node['jenkins']['master']['home']}/jenkins.model.JenkinsLocationConfiguration.xml" do
  source 'jenkins.model.JenkinsLocationConfiguration.xml'
 end

 #Install Plugins
 jenkins_plugin 'git' do
  version '2.4.4'
 end

 jenkins_plugin 'build-pipeline-plugin' do
  version '1.5.2'
 end

 jenkins_plugin 'deploy' do
  version '1.10'
 end

#Job creation
 job_config = File.join(Chef::Config[:file_cache_path], 'job-config.xml')

 template job_config do
  source 'stage1-job-config.xml.erb'
 end
 jenkins_job 'Continuous_Delivery_Stage1_Build' do
   config job_config
 end

 template job_config do
  source 'stage2-job-config.xml.erb'
 end

  jenkins_job 'Continuous_Delivery_Stage2_UnitTest' do
  config job_config
 end

 template job_config do
  source 'stage3-job-config.xml.erb'
 end
 jenkins_job 'Continuous_Delivery_Stage3_StaticAnalysis' do
      config job_config
  end

 template job_config do
  source 'stage4-job-config.xml.erb'
 end
 jenkins_job 'Continuous_Delivery_Stage4_Deploy' do
  config job_config
 end

 template job_config do
  source 'stage5-job-config.xml.erb'
 end
 jenkins_job 'Continuous_Delivery_Stage5_LatestBuild' do
   config job_config
 end

 template job_config do
  source 'stage6-job-config.xml.erb'
 end
 jenkins_job 'Continuous_Delivery_Stage6_IntegrationTest' do
      config job_config
  end

 template job_config do
  source 'stage7-job-config.xml.erb'
 end
 jenkins_job 'Continuous_Delivery_Stage7_Packaging' do
    config job_config
 end

#Build Jon
#
 jenkins_job 'Continuous_Delivery_Stage1_Build' do
# if true will live stream the console output of the executing job  (default is true)
#
   stream_job_output true
# if true will block the Chef client run until the build is completed or aborted (defaults to true)
#
  wait_for_completion true
  action :build
 end
