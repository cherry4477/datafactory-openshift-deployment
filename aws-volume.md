## Configuring for AWS
### Configuring AWS Variables
1. create a /etc/aws/aws.conf file with the following contents on all of your OpenShift hosts, both masters and nodes:
```
[Global]
Zone = cn-north-1b
```
### Configuring Masters
1. Edit or create the master configuration file on all masters (/etc/origin/master/master-config.yaml by default) and update the contents of the apiServerArguments and controllerArguments sections:
```
kubernetesMasterConfig:
  ...
  apiServerArguments:
    cloud-provider:
      - "aws"
    cloud-config:
      - "/etc/aws/aws.conf"
  controllerArguments:
    cloud-provider:
      - "aws"
    cloud-config:
      - "/etc/aws/aws.conf"
```
### Configuring Nodes
1. Edit or create the node configuration file on all nodes (/etc/origin/node/node-config.yaml by default) and update the contents of the kubeletArguments section:
```
kubeletArguments:
  cloud-provider:
    - "aws"
  cloud-config:
    - "/etc/aws/aws.conf"
```
### Setting Key Value Access Pairs
1. Make sure the following environment variables are set in the /etc/sysconfig/origin-master file on masters and the /etc/sysconfig/origin-node file on nodes:
```
AWS_ACCESS_KEY_ID=<key_ID>
AWS_SECRET_ACCESS_KEY=<secret_key>
```
Then, start or restart OpenShift services on the master and all nodes.

### Script
```
#!/bin/bash

VOLUMEZONE=$1
VOLUMETYPE=$2
VOLUMESIZE=$3

volumeZone=${VOLUMEZONE:="cn-north-1b"}
volumeType=${VOLUMETYPE:="gp2"}
volumeSize=${VOLUMESIZE:=10}

echo $volumeZone

volumeId=$(aws ec2 create-volume --size $volumeSize --volume-type $volumeType --availability-zone $volumeZone | jq '.VolumeId')
if [ -z volumeId ]; then
  echo "aws ec2 volume create failed!!!"
  exit 3
fi

pvName="pv-$(openssl rand -hex 6)"
echo "
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "${pvName}"
spec:
  capacity:
    storage: "${volumeSize}Gi"
  accessModes:
    - "ReadWriteOnce"
  awsElasticBlockStore:
    fsType: "ext4"
    volumeID: "${volumeId}"
" | oc create -f -
```


自动化加入卷功能：
  用户可以根据自己需要加入若干个可持久化卷，无需管理员手动干预
  
openshift 添加持久化卷的流程(AWS)：
```
create_ec2_volume(AZ) ---> create_openshift_persistent_volume ---
                                                                 | ---> bounding ---> deployment_config_mount_point
                               create_persistent_volume_claim ---
```
自动化流程建议：
  1. 修改openshift pvc controller, 监听用户的pvc请求，处理请求的时候可以同时创建一个pv与之配对；
  2. 或者新建一个controller, 处理请求并实现以上功能；
  3. 或者功能在service broker里实现功能；

pvc自动创建pv配置实例
{
  "kind": "PersistentVolumeClaim",
  "apiVersion": "v1",
  "metadata": {
    "name": "pvc-var-lib-ldap1",
    "annotations": {
        "volume.alpha.kubernetes.io/storage-class": "foo"
    }
  },
  "spec": {
    "accessModes": [
      "ReadWriteOnce"
    ],
    "resources": {
      "requests": {
        "storage": "3Gi"
      }
    }
  }
}
