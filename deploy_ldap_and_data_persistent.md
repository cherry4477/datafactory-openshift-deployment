1.  ldap部署镜像：https://github.com/asiainfoLDP/docker-openldap.git
fork自刘杰的ldap镜像，把ldap初始化步骤从Dockerfile中改到了run-openldap.sh以适应数据持久化的要求，
其实也可以不借助volume来持久化，把ldap用户列表放在s3上，然后容器创建时把所有用户创建一遍。
另外openshift项目带有自己的ldap容器，但是默认不对数据做任何加密
关于ldap的简单查询和用户添加命令见ldap代码库read.md文档
2.  容器持久化目录/var/lib/docker
3.  为了能让多个openshift集群或其他服务共同使用ldap认证，POD部署时开放了主机端口，可以通过主机端口和地址访问
4.  openshift与ldap镜像集成配置
```
oauthConfig:
  assetPublicURL: https://***.***.***.***:8443/console/
  grantConfig:
    method: auto
  identityProviders:
  - challenge: true
    login: true
    mappingMethod: add
    name: ldap_provider
    provider:
      apiVersion: v1
      kind: LDAPPasswordIdentityProvider
      attributes:
        email:
        - mail
        id:
        - dn
        name:
        - cn
        preferredUsername:
        - uid
      bindDN: cn=admin,dc=openstack,dc=org
      bindPassword: password
      insecure: true
      mappingMethod: add
      url: ldap://***.***.***.***:389/dc=openstack,dc=org?uid
  masterCA: ca.crt
  masterPublicURL: https://***.***.***.***:8443
  masterURL: https://***.***.***.***:8443
```
