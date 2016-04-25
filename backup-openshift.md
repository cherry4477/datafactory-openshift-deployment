### cat datafoundry-backup/datafoundry-backup.sh
```
#!/bin/bash

BASEDIR="/home/jieliu/datafactory-backup"
rm -fr $BASEDIR/cluster
rm -fr $(ls $BASEDIR/cluster-*| sort -r | head -n 1)
/usr/bin/ruby $BASEDIR/openshift-backup.rb
tar_name=$(date +%Y%m%d-%H%M%S)
cd $BASEDIR
tar zcvf $BASEDIR/cluster-${tar_name}.tar.gz cluster
aws s3 cp $BASEDIR/cluster-${tar_name}.tar.gz s3://datafactory-backup/cluster-${tar_name}.tar.gz

```
### cat openshift.rb
```
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'yaml'

base_url = "https://lab.asiainfodata.com:8443"
oapi_url = "/oapi/v1"
api_url = "/api/v1"

#initial http client
uri = URI.parse(base_url)
http = Net::HTTP.new(uri.host,uri.port)
http.use_ssl = true
http.cert =OpenSSL::X509::Certificate.new(File.read("/home/jieliu/datafactory-backup/client-liujie.crt"))
http.key =OpenSSL::PKey::RSA.new((File.read("/home/jieliu/datafactory-backup/client-liujie.key")), "")
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

cluster_path = "/home/jieliu/datafactory-backup/cluster"
Dir.mkdir(cluster_path) if not File.exist?(cluster_path)

namespaces_path = "#{cluster_path}/namespaces"
Dir.mkdir(namespaces_path) if not File.exist?(namespaces_path)

hosts_path = "#{cluster_path}/hosts"
Dir.mkdir(hosts_path) if not File.exist?(hosts_path)

persistentvolumes_path = "#{cluster_path}/persistentvolumes"
Dir.mkdir(persistentvolumes_path) if not File.exist?(persistentvolumes_path)

persistentvolumes = JSON.parse(http.request_get(api_url+"/persistentvolumes").body)['items']
persistentvolumes.each do |pv|
    File.open("#{cluster_path}/persistentvolumes/#{pv['metadata']['name']}", "w") { |file| file.write pv.to_yaml }
end if not persistentvolumes.empty?

hostsubnets = JSON.parse(http.request_get(oapi_url+"/hostsubnets").body)['items']
File.open("#{hosts_path}/hostsubnets", "w") { |file| file.write hostsubnets.to_yaml }

projects = JSON.parse(http.request_get(oapi_url+"/projects").body)['items']

projects.each do |project|
  name = project['metadata']['name']

  Dir.mkdir("#{namespaces_path}/#{name}") if not File.exist?("#{namespaces_path}/#{name}")

  policybindings = JSON.parse(http.request_get(oapi_url+"/namespaces/#{name}/policybindings").body)['items']
  # p policybindings
  policybinding = policybindings.select { |pb| pb['metadata']['name'] == ":default" }.first
  if not ['openshift', 'openshift-infra', 'default'].include?(name) then
    rolebinding = policybinding['roleBindings'].select { |rb| rb['name'] == "admins" }.first
    users = rolebinding['roleBinding']['userNames']
    # p name + "--->" + users.to_s
  end
  File.open("#{namespaces_path}/#{name}/adminusers", "w") { |file| file.write users.to_yaml }

# export all buildconfigs in project
  Dir.mkdir("#{namespaces_path}/#{name}/buildconfigs") if not File.exist?("#{namespaces_path}/#{name}/buildconfigs")
  buildconfigs = JSON.parse(http.request_get(oapi_url+"/namespaces/#{name}/buildconfigs").body)['items']
  buildconfigs.each do |bc|
    File.open("#{namespaces_path}/#{name}/buildconfigs/#{bc['metadata']['name']}", "w") { |file| file.write bc.to_yaml }
  end if not buildconfigs.empty?

# export all deploymentconfigs in project
  Dir.mkdir("#{namespaces_path}/#{name}/deploymentconfigs") if not File.exist?("#{namespaces_path}/#{name}/deploymentconfigs")
  deploymentconfigs = JSON.parse(http.request_get(oapi_url+"/namespaces/#{name}/deploymentconfigs").body)['items']
  deploymentconfigs.each do |dc|
    File.open("#{namespaces_path}/#{name}/deploymentconfigs/#{dc['metadata']['name']}", "w") { |file| file.write dc.to_yaml }
  end if not deploymentconfigs.empty?

# export all pvcs in project
  Dir.mkdir("#{namespaces_path}/#{name}/persistentvolumeclaims") if not File.exist?("#{namespaces_path}/#{name}/persistentvolumeclaims")
  persistentvolumeclaims = JSON.parse(http.request_get(api_url+"/namespaces/#{name}/persistentvolumeclaims").body)['items']
  # p persistentvolumeclaims
  persistentvolumeclaims.each do |pvc|
    # p pvc
    File.open("#{namespaces_path}/#{name}/persistentvolumeclaims/#{pvc['metadata']['name']}", "w") { |file| file.write pvc.to_yaml }
  end if not persistentvolumeclaims.empty?
  
end if not projects.empty?
```
### cat .aws/credentials 
```
[default]
aws_access_key_id = AKxxxxxxxxxxxx
aws_secret_access_key = MMflxxxxxxxxxxxxxxxxx
```
### crt and key file generate and replace liujie15.{crt key}
```
Create a client configuration for connecting to the server

This command creates a folder containing a client certificate, a client key,
a server certificate authority, and a .kubeconfig file for connecting to the
master as the provided user.

Usage:
  oc adm create-api-client-config [options]
Options:
      --basename='': The base filename to use for the .crt, .key, and .kubeconfig files. Defaults to the username.
      --certificate-authority=[openshift.local.config/master/ca.crt]: Files containing signing authorities to use to verify the API server's serving certificate.
      --client-dir='': The client data directory.
      --groups=[]: The list of groups this user belongs to. Comma delimited list
      --master='https://localhost:8443': The API server's URL.
      --public-master='': The API public facing server's URL (if applicable).
      --signer-cert='openshift.local.config/master/ca.crt': The certificate file.
      --signer-key='openshift.local.config/master/ca.key': The key file.
      --signer-serial='openshift.local.config/master/ca.serial.txt': The serial file that keeps track of how many certs have been signed.
      --user='': The scope qualified username.

Use "oc adm options" for a list of global command-line options (applies to all commands).
```
