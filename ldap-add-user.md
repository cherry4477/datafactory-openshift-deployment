首先oc login 登陆openshift
oc get pod 找到ldap的pod 然后进入这个pod 
然后 vi /ldap-user-data/more.ldif #编辑这个文件
添加用户的格式为：
                dn: cn=user,ou=Users,dc=openstack,dc=org 
                objectclass: inetOrgPerson
                cn: user
                sn: user
                uid: user
                userpassword: user_passwd
                mail: user@asiainfo.com
                ou: BDX
                # user是你要添加的用户名，user_passwd为用户的密码。
添加完了以后保存退出。
然后执行 ldapadd -x -D cn=admin,dc=openstack,dc=org -w password -c -f /ldap-user-data/more.ldif 这个命令是创建用户。
查看已创建的用户 ldapsearch -H ldap://localhost -LL -b ou=Users,dc=openstack,dc=org -x

验证用户是否可以登录：while read line; do echo $line; oc login -u $(echo $line | awk '{print $1}') -p $(echo $line | awk '{print $2}') && (echo -e "\033[32m login success \033[0" ;tput sgr0;) || echo -e "\033[31m login failed \033[0" ;tput sgr0; done < namepasswd.txt
把用户名和密码放到namepasswd.txt这个文件里 第一列是用户名，第二列是密码，分隔符为空格。


                    
