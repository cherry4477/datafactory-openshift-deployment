# Greenplum多节点安装
##目的
为LDP环境提供一套MPP数据库。必须是高可用，可以多租户区隔的。后续通过ServiceBorker来进行控制。
##环境
经过测试，只对centos 6比较好的支持，因此选用centos 6.5为基础版本。
OS:	centos6
CPU:	4
MEM:	8G
DISK:	外挂200G xfs
####挂盘步骤 
	#fdisk -l 
	#yum install lvm2
	#pvcreate /dev/vdb
	#vgcreate -s 64M locvg01 /dev/vdb 
	#lvcreate -l 100%VG -n lvg01fs01 locvg01 
	#mkfs -t xfs /dev/locvg01/lvg01fs01 
	#mkdir /data
	#mount -o rw,noatime,inode64,allocsize=16m /dev/locvg01/lvg01fs01 /data
修改挂盘配置
```vi /etc/fstab```
/dev/locvg01/lvg01fs01 /data xfs nodev,noatime,inode64,allocsize=16m 0 0  
##操作系统准备
**以下操作需要在每个节点执行**
1.关闭selinux和防火墙。
http://gpdb.docs.pivotal.io/4380/prep_os-system-req.html#topic2

2.设置推荐参数
http://gpdb.docs.pivotal.io/4380/prep_os-system-params.html#topic4

3.安装推荐软件 
```yum -y install rsync coreutils glib2 lrzsz sysstat e4fsprogs xfsprogs ntp readline-devel zlib zlib-devel openssl openssl-devel pam-devel libxml2-devel libxslt-devel python-devel tcl-devel gcc make smartmontools flex bison perl perl-devel perl-ExtUtils* OpenIPMI-tools openldap openldap-devel logrotate gcc-c++ python-py```
##代码安装
**以下操作只需要在主节点进行**
**以下操作以root执行**
**可以选择两种方式，二进制和源代码编译**
####二进制安装
去network.pivotal.io上下载文件
解压、执行，会安装在/usr/local/greenplum-db-X.X.X
建立链接 
```#ln /usr/local/greenplum-db-X.X.X /usr/local/greenplum-db```
####源代码编译
	#yum install git
	#cd /opt
	#git clone https://github.com/greenplum-db/gpdb.git
	
	#yum install readline-devel.x86_64 -y 
	#yum install apr-devel.x86_64 -y
	#yum install libevent-devel.x86_64 -y
	#yum install libcurl-devel.x86_64 -y
	#yum install bzip2-devel.x86_64  -y
	
	#./configure --prefix=/usr/local/greenplum-db
	
	#yum install bison-devel.x86_64 -y
	#yum install bison.x86_64 -y
	
	#make
	#make install
##初始化配置
**以下语句需要在所有节点上执行，因为需要执行自动安装**
1.将所有节点加入/etc/hosts
2.建立自动安装的依赖环境

	#yum install gcc python-devel.x86_64 libffi-devel.x86_64 openssl-libs.x86_64 openssl-devel.x86_64 python-setuptools -y
	#easy_install pip
	#pip install psutil
	#pip install paramiko
	#pip install psi
	#pip install lockfile
	#pip install epydoc
	#pip install setuptools
**以下语句仅在主节点上执行**
3.获取环境变量

	# source /usr/local/greenplum-db/greenplum_path.sh
	
4.建立部署目标配置文件hostfile_exkeys

	#vi hostfile_exkeys
	greenplum-master1
	greenplum-master2
	...
	
5.执行自动安装程序

	# gpseginstall -f hostfile_exkeys -u gpadmin -p asiainfo
	这个非常棒，能为所有节点建立用户，并正确设置/usr/local/greenplum-db的权限，并将所有代码打包传递过去。最后还会设置互信。
	
**唯一的问题是，他似乎并没有吧gpadmin加入root组，所以执行过程中会出错。需要手动执行usermod -g root gpadmin后再重新执行上述语句**

6.设置目录
http://gpdb.docs.pivotal.io/4380/prep_os_install_gpdb-topic13.html#topic13

**接下来的操作需要用gpadmin用户，greenplum 不允许用root建立数据库**
7.为gpinitsystem建立初始化的节点配置，这个初始化配置仅对segment，如果要把主节点和备主节点当作segment，也要加入进去

	$su - gpadmin
	$vi host_seg
	greenplum-master1
	greenplum-master2
	
8.为gpinitsysmtem建立参数配置文件.
	
	$cp $GPHOME/docs/cli_help/gpconfigs/gpinitsystem_config .
	修改，主要参数包括：
	DATA_DIRECTORY
	MASTER_HOSTNAME
	MASTER_DIRECTORY
	MIRROR的参数
	MACHINE_LIST_FILE
	
9.执行初始化

	$gpinitsystem -c ./gpinitsystem_config --locale=C --max_connections=48 --shared_buffers=256MB —su_password=asiainfo -s greenplum-master2 -S
##其他配置
	$vi .bashrc
添加 
source /usr/local/gpdb/greenplum_path.sh
以及
export MASTER_DATA_DIRECTORY=/data/gpdata/master/gpseg-1 
export PGHOST=127.0.0.1
export PGPORT=5432
export PGUSER=gpdb
export PGDATABASE=share
##测试
	$psql share
	create table test(a int);
	insert into test values(1);
	
##其他gp命令
	
	$gpconfig -c optimizer -v on
	$gpstop -u
	$gpstop -a
	$gpstart -a
	$gpconfig -s shared_buffers
	$gpconfig -s gp_vmem_protect_limit
	$gpconfig -s max_connections
	$gpconfig -s wal_send_client_timeout
	$gpstate

##设置可以从外网访问
$cd /data/master/gpseg-1
	$vi pg_hba.conf
	host	 all         all	     0.0.0.0/0     password
	也可以将password修改为md5

##修改主密码
	$psql share
	alter user pgadmin with password 'xxx'
	

##其他问题
1.内网不是所有端口都通，特别是一些高阶端口
2.不支持centos7.2
3.需要执行yum install ed，因为需要这个，否则会在初始化的时候莫名其妙出错

##遗留工作

2.研究建立账户和权限的机制
3.资源隔离


