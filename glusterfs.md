# glusterfs安装
安装过程主要参考以下博客  
http://www.cnblogs.com/sj9524437/p/4952914.html  
详细信息可以见  
http://gluster.readthedocs.io/en/latest/Install-Guide/Quick_start/  
安装过程出现问题及处理如下：  
###  缺少依赖包
```
Error: Package: glusterfs-server-3.7.11-1.el7.x86_64 (glusterfs-epel)
           Requires: liburcu-cds.so.1()(64bit)
Error: Package: glusterfs-server-3.7.11-1.el7.x86_64 (glusterfs-epel)
           Requires: liburcu-bp.so.1()(64bit)
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
```
需要手工安装依赖包：
```
yum install http://mirrors.aliyun.com/epel/7/x86_64/u/userspace-rcu-0.7.16-1.el7.x86_64.rpm
```
###  gluster daemon端口没有在防火墙中放开
```
[root@h-z8jk1jso ~]# gluster peer probe controller
peer probe: failed: Probe returned with Transport endpoint is not connected
```
需要手工在防火墙中打开端口或者关闭防火墙，官网推荐关闭防火墙
```
/sbin/iptables -I INPUT -p tcp --dport 24007 -j ACCEPT   # 开启24007端口
```

###  创建盘时提示node 不是“Peer in Cluster” status
这个错误是由于`gluster peer probe`命令没有在所有节点都运行一边

###  磁盘mount失败
```
[root@h-z8jk1jso log]# mount -t glusterfs 10.1.130.245:/gv0 /root/gv_test
Mount failed. Please check the log file for more details.
```
解决办法是查看当前节点下glusterfs日志，原因是glusterfs盘创建成功后，没有运行`gluster volume start`命令来使磁盘启动
```
cd /var/log/glusterfs
vi root-gv_test.log
```

###  生成的盘为只读文件系统
```
[root@h-z8jk1jso glusterfs]# mount -t glusterfs 10.1.130.245:/gv0 /root/gv_test
[root@h-z8jk1jso ~]# cd /root/gv_test/
[root@h-z8jk1jso gv_test]# touch 1.txt
touch: cannot touch ‘1.txt’: Read-only file system
```
解决办法是查看当前节点下glusterfs日志，原因是glusterfs每块盘都会在每个节点上有一个自己的随机端口，如果某块盘所对应的端口不通，磁盘就会进入只读状态，解决办法就是在每个节点防火墙中打开相应端口
```
cd /var/log/glusterfs
vi root-gv_test.log

[2016-05-19 04:47:41.446196] E [socket.c:2279:socket_connect_finish] 0-gv0-client-1: connection to 10.1.130.246:49152 failed (No route to host)
```
在每个节点上防火墙上打开相应端口后gluster盘自动变为可写状态
```
[root@h-z8jk1jso glusterfs]# ssh 10.1.130.246 /sbin/iptables -I INPUT -p tcp --dport 49152 -j ACCEPT
[root@h-z8jk1jso glusterfs]# ssh 10.1.130.247 /sbin/iptables -I INPUT -p tcp --dport 49152 -j ACCEPT
[root@h-z8jk1jso glusterfs]# cd /root/gv_test/
[root@h-z8jk1jso gv_test]# touch 1.txt
[root@h-z8jk1jso gv_test]# ls
1.txt
```

###   通过pv/pvc将盘挂在到openshift中提示“Error syncing pod, skipping: unsupported volume type”
先检查要挂载的盘是否正常，任意找一个glusterfs node挂载glusterfs盘排除盘自身问题  
可以直接使用glusterfs存储插件方式挂载盘，而不是pv/pvc方式，看看是否为存储插件问题
