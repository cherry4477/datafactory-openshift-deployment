### 以下在四节点环境 ansible hosts 配置文件，可参考
```
[OSEv3:children]
masters
nodes
etcd
lb
[OSEv3:vars]
ansible_ssh_user=root
debug_level=2
deployment_type=origin
osm_image=registry.dataos.io/openshift/origin
osn_image=registry.dataos.io/openshift/node
osn_ovs_image=registry.dataos.io/openshift/openvswitch
openshift_pkg_version=abcdef
openshift_image_tag=abcdef
cli_docker_additional_registries=registry.dataos.io
cli_docker_insecure_registries=registry.dataos.io
openshift_master_api_port=443
openshift_master_console_port=443
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
openshift_master_cluster_method=native
openshift_master_cluster_hostname=example.com
openshift_master_cluster_public_hostname=example.com
os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
osm_cluster_network_cidr=172.16.0.0/16
[masters]
10.1.130.121 containerized=true
10.1.130.126 containerized=true
10.1.130.131 containerized=true
[etcd]
10.1.130.121 containerized=false
10.1.130.126 containerized=false
10.1.130.131 containerized=false
[lb]
10.1.130.132
[nodes]
10.1.130.131 containerized=true
10.1.130.132 containerized=true
10.1.130.121 containerized=true
10.1.130.126 containerized=true
```
### install 步骤
1. install docker ansible, docker pull registry.dataos.io/openshift/{origin, node, openvswitch, origin-docker-registry, origin-docker-haproxy, origin-pod, origin-docker-builder, origin-deployer} 
2. git clone https://github.com/openshift/openshift-ansible.git
3. ansible-playbook -i host openshift-ansible/playbook/byo/config.yaml
4. 安装完成后，oc get node 验证
