#                       FastDFS Installation manual

![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic1.png)
#####Tracker (10.1.130.153) Nginx Load balancing + cache
![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic2.png) ![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic2.png)
##### Group1 Storage x 2#######group2 Storage x 2 
#####10.1.130.152 10.1.130.154####  10.1.130.123 10.1.130.124

##1.Install the compiler tools and libfastcommon
###<br />All servers:<br />
<br />`yum -y groupinstall 'Development Tools' && yum -y install wget`<br />
<br />`wget https://github.com/happyfish100/libfastcommon/archive/master.zip`<br />
<br />`unzip master.zip`<br />
<br />`cd libfastcommon-master`<br />
<br />`./make.sh`<br />
<br />`./make.sh install`<br />
##2.Install FastDFS
###<br />All servers:<br />
<br />`wget https://github.com/happyfish100/fastdfs/archive/V5.05.tar.gz`<br />
<br />`tar -zxvf V5.05.tar.gz`<br />
<br />`cd fastdfs-5.05/`<br />
<br />`./make.sh`<br />
<br />`./make.sh install`<br />
###<br />Tracker:<br />
<br />`mv /etc/fdfs/tracker.conf.sample  /etc/fdfs/tracker.conf`<br />
<br />`Vi  /etc/fdfs/tracker.conf`<br />
![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic4.png)

<br />`iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 22122 -j ACCEPT`<br />
<br />`fdfs_trackerd /etc/fdfs/tracker.conf start`<br />
###<br />Storage:<br />
<br />`mv /etc/fdfs/storage.conf.sample  /etc/fdfs/storage.conf `<br />
<br />`Vi /etc/fdfs/storage.conf`<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic5.png)<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic6.png)<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic9.png)<br />

![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic8.png)or
![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic7.png)
<br />`iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 23000 -j ACCEPT`<br />
<br />`fdfs_storaged /etc/fdfs/storage.conf`<br />
##3.Storage install nginx
<br />`iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 22122 -j ACCEPT`<br />
<br />`wget https://github.com/happyfish100/fastdfs-nginx-module/archive/master.zip`<br />
<br />`wget http://openresty.org/download/ngx_openresty-1.7.10.1.tar.gz`<br />
<br />`tar -zxvf ngx_openresty-1.7.10.1.tar.gz`<br />
<br />`unzip master.zip`<br />
<br />`yum -y install pcre-devel openssl openssl-devel`<br />
<br />`cd ngx_openresty-1.7.10.1/`<br />
<br />`./configure --with-luajit --with-http_stub_status_module --with-http_ssl_module                                            --with-http_realip_module --add-module=/root/fastdfs/nginx/fastdfs-nginx-module-master/src/ && gmake && gmake install`<br />
<br />`cp ../fastdfs-nginx-module-master/src/mod_fastdfs.conf /etc/fdfs/`<br />
<br />`vi /etc/fdfs/mod_fastdfs.conf`<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic9.png)<br />
![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic10.png)or
![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic11.png)
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic12.png)<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic13.png)<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic14.png)<br />
<br />`vi /usr/local/openresty/nginx/conf/nginx.conf`<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic15.png)<br />
<br />`/usr/local/openresty/nginx/sbin/nginx start`<br />
##4.Tracker install nginx:
<br />`cd ngx_openresty-1.7.10.1`<br />
<br />`./configure --prefix=/usr/local/nginx --add-module=/root/nginx/ngx_cache_purge-2.3 --with-pcre=/root/nginx/pcre-7.8/ --with-zlib=/root/nginx/zlib-1.2.5`<br />
<br />`gmake && gmake install`<br />
<br />`vi /usr/local/nginx/nginx/conf/nginx.conf`<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic16.png)<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic17.png)<br />
<br />`/usr/local/nginx/nginx/sbin/nginx start`<br />
##5.Test:
<br />`vi /etc/fdfs/client.conf`<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic18.png)<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic19.png)<br />
<br />![](https://github.com/lixwlixw/fastdfs-install/blob/master/pic20.png)<br />
<br />`echo 1234 > test.html`<br />
<br />`fdfs_test /etc/fdfs/client.conf upload test.html`<br />
###And then give you a link to directly access the can。
