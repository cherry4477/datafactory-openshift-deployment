## heketi   
### 简介  
Heketi provides a RESTful management interface which can be used to manage the life cycle of GlusterFS volumes.  With Heketi, cloud services like OpenStack Manila, Kubernetes, and OpenShift can dynamically provision GlusterFS volumes with any of the supported durability types.  Heketi will automatically determine the location for bricks across the cluster, making sure to place bricks and its replicas across different failure domains.  Heketi also supports any number of GlusterFS clusters, allowing cloud services to provide network file storage without being limited to a single GlusterFS cluster.  
### Workflow  
When a request is received to create a volume, Heketi will first allocate the appropriate storage in a cluster, making sure to place brick replicas across failure domains.  It will then format, then mount the storage to create bricks for the volume requested.  Once all bricks have been automatically created, Heketi will finally satisfy the request by creating, then starting the newly created GlusterFS volume.  

### 优点  
1、帮助管理glusterfs集群物理卷，heketi可以调用lvcreate命令从glusterfs集群中的物理盘中划分所需空间并且均衡节点间空间使用  
2、帮助管理glusterfs bricks，heketi在划分好空间后可以完成glusterfs volume的创建  
3、提供restapi  

### 缺点  
1、heketi集群元数据存储的单点    

## 安装  
[wiki/Installation](https://github.com/heketi/heketi/wiki/Installation)  
环境：glusterfs 3.8.0.1 * 3, heketi 2.0.3
全容器方式安装没有成功，所以暂时选择二进制方式安装，安装过程非常简单  
0、至少三个glusterfs node，每个node上至少有一个块裸设备待用  
　　heketi可以和glusterfs node各节点互信  
　　glusterfs node各节点/etc/sudoers文件的“Defaults    requiretty”被注释  
1、wget https://copr.fedorainfracloud.org/coprs/lpabon/Heketi/repo/epel-7/lpabon-Heketi-epel-7.repo  
2、rpm install heketi heketi-client  
3、复制heketi server与glusterfs node互信的ssh private key到 /etc/heketi/ 并且改变key文件属组为heketi:heketi  
3、修改/etc/heketi/heketi.json  
  　　    "executor": "ssh"  
   　　   "keyfile": "/etc/heketi/key"  
   　　   "user": "user"  
4、service heketi start  
5、创建一个heketi拓扑文件  heketi-cli topology load --json=topology.json
   topology.json  
```  
  {  
    "clusters": [  
        {  
            "nodes": [  
                {  
                    "node": {  
                        "hostnames": {  
                            "manage": [  
                                "192.168.0.17"  
                            ],  
                            "storage": [  
                                "192.168.0.17"  
                            ]  
                        },  
                        "zone": 1  
                    },  
                    "devices": [  
                        "/dev/vdb"  
                    ]  
                },  
                {  
                    "node": {  
                        "hostnames": {  
                            "manage": [  
                                "192.168.0.18"  
                            ],  
                            "storage": [  
                                "192.168.0.18"  
                            ]  
                        },  
                        "zone": 1  
                    },  
                    "devices": [  
                        "/dev/vdb"  
                    ]  
                },  
                {  
                    "node": {  
                        "hostnames": {  
                            "manage": [  
                                "192.168.0.19"  
                            ],  
                            "storage": [  
                                "192.168.0.19"  
                            ]  
                        },  
                        "zone": 1  
                    },  
                    "devices": [  
                        "/dev/vdb"  
                    ]  
                }  
            ]  
        }  
    ]  
}  
```   
6、export HEKETI_CLI_SERVER=http://localhost:8080   
7、heketi-cli topology load --json=topology.json  
8、heketi-cli volume create --size=10  

## 常见问题
1、到glusterfs集群网络不通，确保glusterfs node上的端口都已正确开放
```
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 24007 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 24008 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
-A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m multiport --dports 49152:49251 -j ACCEPT
```

2、创建的卷不能再POD中挂载
检查glusterfs客户端都已正确安装,yum install glusterfs-client
检查glusterfs endpoint是否存在
检查操作系统中glusterd服务是否启动

3、glusterfs endpoint丢失
检查glusterfs endpoint对应的service是否存在
