# Service Broker Database部署
##简介
当前Database Service Broker提供了MongoDB、Postgresql、Mysql和GreenPlum四种数据库服务。
通过CloudFoundry的ServiceBroker协议v2.8，可以为Openshift集群中的应用提供backingservice，实现有状态服务的托管。
##环境


* mongodb:当前运行在aws的ec2实例 ```i-567938ee``` 上。通过二进制代码的方式安装，用后台服务的方式启动。［todo，后续业务量的大以后应该迁移到京东环境］。接入点为：```dashboard.servicebroker.dataos.io:27017```。通过DNS的cname指定到ec2的dns
* mysql: 通过aws的rds实例```servicebrokershare```实现。[todo，按需增加实例的配置]。接入点为：```mysqlshare.servicebroker.dataos.io:3306```。通过DNS的cname指定到rds的dns
* postgres: 通过aws的rds实例```servicebrokerpqsql```实现。[todo，按需增加实例的配置]。接入点为：```postgresqlshare.servicebroker.dataos.io:5432```。通过DNS的cname指定到rds的dns
* greenplum: 在京东上部署了两节点的greenplum，二进制代码直接部署。地址为111.202.122.23和111.202.120.27。[todo，按需增加节点]。接入点为:```greenplumshare.servicebroker.dataos.io:5432```。通过DNS的A地址指定到111.202.122.23（master）
* Dashboard：均运行在```service-broker-db@dataos.io```上，作为Openshift中的应用
* Servicebroker本身：运行在```service-broker-db@dataos.io```上，作为Openshift中的应用
* ETCD：Servicebroker本身是无状态的，其状态信息存储在三个节点组成的ETCD中。这三个ETCD节点均由最小的aws ec2实例构成。etcd1、2、3。通过docker启动，初始化脚本见~/bin。如果要添加和删除节点，使用命令:

		export ETCDCTL_ENDPOINT=http://etcdsystem.servicebroker.dataos.io:2379
		export ETCDCTL_USERNAME=asiainfoLDP:*****
		etcdctl -u $ETCDCTL_USERNAME member remove <nodeid>
		etcdctl -u $ETCDCTL_USERNAME member add <name> <peer-ip>

##部署Dashboard和servicebroker的步骤
	#创建servicebroker的build config
	oc new-build  https://github.com/asiainfoLDP/datafoundry_servicebroker_go.git
	#创建dashboard mysql的build config
	oc new-build --name phpmyadmin  https://github.com/asiainfoLDP/datafoundry_servicebroker_go.git --context-dir='dashboard/phpmyadmin'
	#创建dashboard postgres的build config
	oc new-build --name phppgadmin  https://github.com/asiainfoLDP/datafoundry_servicebroker_go.git --context-dir='dashboard/phppgadmin'
	#创建dashboard greeenplum的build config
	oc new-build --name phpgreenplumadmin  https://github.com/asiainfoLDP/datafoundry_servicebroker_go.git --context-dir='dashboard/phpgreenplumadmin'
	#创建dashboard mongodb的build config
	oc new-build --name rockmongo  https://github.com/asiainfoLDP/datafoundry_servicebroker_go.git --context-dir='dashboard/rockmongo'
	
	-----
	##run servicebroker dashboard for greenplum
	oc run phpgreenplumadmin --image=172.30.188.59:5000/service-broker-db/phpgreenplumadmin 
	oc expose dc  phpgreenplumadmin  --port 80
	oc expose svc phpgreenplumadmin 
	
	##run servicebroker dashboard for postgres
	oc run phppgadmin --image=172.30.188.59:5000/service-broker-db/phppgadmin 
	oc expose dc  phppgadmin  --port 80
	oc expose svc phppgadmin 
	
	##run servicebroker dashboard for mysql
	oc run phpmyadmin --image=172.30.188.59:5000/service-broker-db/phpmyadmin 
	oc expose dc  phpmyadmin  --port 80
	oc expose svc phpmyadmin 
	
	##run servicebroker dashboard for mongodb
	oc run rockmongo --image=172.30.188.59:5000/service-broker-db/rockmongo 
	oc expose dc  rockmongo  --port 80
	oc expose svc rockmongo 
	
	#运行serviceborker
	oc run servicebroker-go --image=172.30.188.59:5000/service-broker-db/datafoundryservicebrokergo     \
	    --env  ETCDENDPOINT="http://etcdsystem.servicebroker.dataos.io:2379"  \
	    --env  ETCDUSER="asiainfoLDP" \
		--env  ETCDPASSWORD="6ED9BA74-75FD-4D1B-8916-842CB936AC1A" \
	    --env  BROKERPORT="8000"  \
	    --env  MONGOURL="dashboard.servicebroker.dataos.io:27017"  \
	    --env  MONGOADMINUSER="asiainfoLDP"   \
	    --env  MONGOADMINPASSWORD="****"   \
	    --env  MONGODASHBOARD="rockmongo-service-broker-db.app.dataos.io"  \
	    --env  MYSQLURL="mysqlshare.servicebroker.dataos.io:3306" \
	    --env  MYSQLADMINPASSWORD="****" \
	    --env  MYSQLDASHBOARD="phpmyadmin-service-broker-db.app.dataos.io" \
	    --env  POSTGRESURL="postgresqlshare.servicebroker.dataos.io:5432" \
	    --env  POSTGRESUSER="asiainfoLDP" \
	    --env  POSTGRESADMINPASSWORD="****" \
	    --env  POSTGRESDASHBOARD="phppgadmin-service-broker-db.app.dataos.io" \
	    --env  GREENPLUMURL="greenplumshare.servicebroker.dataos.io:5432" \
	    --env  GREENPLUMUSER="gpadmin"  \
	    --env  GREENPLUMADMINPASSWORD="****"  \
	    --env  GREENPLUMDASHBOARD="phpgreenplumadmin-service-broker-db.app.dataos.io"
	
	oc expose dc  servicebroker-go  --port 8000
	
	oc expose svc servicebroker-go 
	
	
##监控点
1. 监控postgresql mysql mongodb和greenplum的入口地址是否正常
2. 监控他们的dashboard是否正常
3. 监控servicebroker的接口是否正常提供访问
4. 监控4个数据库的用量[todo]

##注意事项
1. 注意DNS的映射
2. ```service-broker-db```是生产环境，```service-broker-db-test```是测试环境。

