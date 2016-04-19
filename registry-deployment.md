registry使用nginx与openshift所用的ldap结合，用ldap做认证，存储用S3.

1.起3个registry的pod，以保证高可用  
registry的编排文件见https://github.com/asiainfoLDP/nginx-registry/blob/master/registry.yaml

2.配置nginx，起三个nginx的pod以保证高可用
nginx的项目见https://github.com/asiainfoLDP/nginx-registry
nginx的编排文件见https://github.com/asiainfoLDP/nginx-registry/blob/master/auth-registry-openshift.yaml
nginx的配置需要注意的有以下几点：
    
  2.1 upstream docker-registry {
  server #servicename:5000#;
  }
  中的servicename要传入registry的service name
  2.2 ldap的地址要跟具体的类似ou=Users,dc=openstack,dc=org?uid?sub?这样的串，否则会找不到ldap地址，同时传入ldap地址时，地址中的特殊字符需要使用转义符
      ldap的binddn "#username#"和binddn_passwd "#password#"不可缺，如果没有这两个值，启动不会报错，但是ldap不起作用
  2.3 ssl认证在本例中没有做在nginx，而是做在了haproxy，所以在nginx的配置中可以屏蔽掉有关ssl的语句，有关haproxy的ssl认证在router配置中详说
  2.4 add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always这句话是确保每次请求都发到v2上，如果没有这句话，只有第一次请求会到V2，后面会发
      到V1上
  2.5 proxy_set_header X-Forwarded-Proto https原本是proxy_set_header X-Forwarded-Proto $schema，$schema是确保首次发出的请求会一路传下去，例如首次请求是
      http,那么一路都按http传下去，但是这样产生的问题是：当push镜像并且存储到S3时候是patch方法，由于按照传下来的http进行patch，所以请求中没有
      带认证，registry就会报认证失败。所以proxy_set_header X-Forwarded-Proto https就强制写死通过https来进行通信，这样写本来应该会引起通过http通信时错误，
      但是在router的配置中,配置了insecureEdgeTerminationPolicy: redirect，保证了http转到https

3.创建route
注意这里的router的创建要通过命令行方式，不要通过expose svc的方式再去修改route的方式！
创建router的命令：oc create route edge --service=service name of nginx --cert=XXX.crt --cert=XXX.cert --hostname=XXX
而后oc edit route,加入insecureEdgeTerminationPolicy: redirect这句话

4.验证route是否正确
curl http和https，如果都正确，说明route正确
  
