# openshift LDAP验证详细配置

## 建议下载一个ldap客户端，熟悉其登录的流程在登录界面可以看到以下几个基本的参数。
1. baseDN：dc=example,dc=com
2. UserDN：cn=Manager,dc=example,dc=com
3. secret：******

## 以上三个参数是接下来在openshift上配置时需要的参数
1. 登录到openshift的主机 cd /etc/orign/master
2. sudo vi master-config.yaml
3. 找到oauthConfig: 这一参数注意不要删除里面的内容。只做相应的添加。
       provider:
         apiVersion: v1
         kind: LDAPPasswordIdentityProvider
         attributes:
           id:
           - dn
           email:
           - mail
           name:
           - cn
           preferredUsername:
           - uid
         bindDN: "cn=Manager,dc=example,dc=com"
         bindPassword: "secret"
         insecure: true
         url:"ldap://54.223.94.93:389/dc=example,dc=com?uid"

## 找到bindDN、bindPassword、以及url的参数配置
1. 添加对应的参数：
2. bindDN是上述 UserDN
3. bindPassword是 secret
4. url是主机地址 域是添加自己的 BaseDN其他不变（？uid不用改动）
             