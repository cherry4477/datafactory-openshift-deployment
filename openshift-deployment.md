集群部署过程  
# 前期准备   
## 准备openshift安装程序yum源及docker yum repo文件   
1. openshift安装程序repo  
    之所以要准备openshift安装程序repo,是因为国内网速较慢,在通过rpm包部署openshift集群时容易出现中断,  
 先把安装包下载到自建的repo上可以很大程度上提升部署效率   ,搭建yum源首先安装apache等http服务器,然后就下相应的rpm包到http服务器中即可  
openshift的官方安装rpm包 yum源地址可以在openshift集群部署工程openshift-ansible(https://github.com/openshift/openshift-ansible.git)   
内的openshift_repos/files/origin/repos/下的maxamillion-origin-next-epel-7.repo文件中找到,同时在把文件中的官方yum源地址替换为自建的yum源地址  
下载yum源可以使用wget -c -r -np -k -L -p命令下载,例如  
在/var/www/html目录下执行wget -c -r -np -k -L -p   https://copr-be.cloud.fedoraproject.org/results/maxamillion/origin-next/epel-7-x86_64/00125912-openvswitch/  
会下载所有openvswitch的安装包,一次openshift集群的安装需要下载最新的openshift和openvswitch安装包,以及相应的元数据文件目录"repodata"  

1. docker安装程序yum.repo.d配置文件    
openshift一度还不支持docker1.9,如果使用rhel7.1以上操作系统安装openshift借助配置一个阿里云的centos源来方便安装docker1.8,配置文件如下,文件任意起名后放在/etc/yum.repo.d/:  
[centos-extra]  
name=centos extra  
baseurl=http://mirrors.aliyun.com/centos/7/extras/x86_64/  
enabled=1  
gpgcheck=0  

1. 其他准备同官方文档,配置主从节点的ssh互信,安装各种依赖包,docker程序,给docker配置存储卷等,  
  集群部署工具ansible程序没有通过yum方式安装而是通过pip install ansible==1.9.4来安装的,需要提前装好gcc,python-devel,pyOpenSSL包  
```
  curl -O https://bootstrap.pypa.io/get-pip.py   
  sudo python get-pip.py
```
## 集群安装   
1. 集群部署方式按照openshift-origin官方文档中高级安装方式,通过ansible来部署,如果之前ansible脚本不是通过yum   rpm方式安装,可能无法按照官方给出的  
/etc/ansible/hosts路径找到ansible脚本的inventory file   ,这时可以在任意一个方便的位置上新建一个文本文件,在文件中保存openshift部署需要的配置信息,  
例如master,node节点信息,集群安装用户和密码以及其他需要配置的信息等,在执行安装时使用ansible-playbook   的-i参数来加载自定义的这个inventory_file  
 例如:ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml -i any_inventory_file  
1. openshift-ansible的bug应该很少,但是每次都要使用最新的rpm包和最新的ansible脚本来安装,如果不存在网络,软件兼容性问题安装应该会很顺利,把安装需要的rpm下载到自建的yum源后,安装也比较快.  

## 后续问题  
1. 如何安装指定版本的openshift,如果直接clone最新的ansible脚本来安装需要有最新的openshift   yum源,这样可能会错过相对稳定的openshift版本,解决办法应该是在搭建yum源的时候按指定的openshift版本重新生成yum源下的repodata文件,有待验证  
1. 目前安装都是单主节点,单etcd,单router方式,为了提高可用性需要搭建多主节点,多etcd节点,多router节点的集群  
1. 节点扩容还没有成功执行过,虽然做过节点过程但是基本都没有成功,问题多集中在sdn的配置上,以及对openshift集群原有配置信息的继承上,即通过ansible脚本进行节点扩容,其实也不是扩容而是在所有节点上全新安装.  


