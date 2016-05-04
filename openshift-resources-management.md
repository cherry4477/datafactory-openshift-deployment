### Allocating Node Resources
1. edit /etc/origin/node/node-config.yaml 
```
kubeletArguments:
  kube-reserved:
    - "cpu=200m,memory=30G"
  system-reserved:
    - "cpu=200m,memory=30G"
```
2. restart node service
3. [Allocatable] = [Node Capacity] - [kube-reserved] - [system-reserved]
4. 查看 Node 可分配资源和容量  
`oc get node/<node_name> -o yaml`   
5. 保留系统和 kubelet ,可以保证系统不被 hang 死
#### infor links
https://docs.openshift.org/latest/admin_guide/allocating_node_resources.html

### Resource Quota
1. 限制资源个数和计算资源
```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
spec:
  hard:
    configmaps: "10" 
    persistentvolumeclaims: "4" 
    replicationcontrollers: "20" 
    secrets: "10" 
    services: "10"
    pods: "4" 
    requests.cpu: "1" 
    requests.memory: 1Gi 
    limits.cpu: "2" 
    limits.memory: 2Gi
```
#### infor links
https://docs.openshift.org/latest/admin_guide/quota.html

### Resource Limits
资源限制分为三层 container, pod, namespace, namespace级计算资源限制在quota中, 如果没有显式声明资源，按默认；如果超出，则拒绝
```
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "limits" 
spec:
  limits:
    -
      type: "Pod"
      max:
        cpu: "2" 
        memory: "1Gi" 
      min:
        cpu: "200m" 
        memory: "6Mi" 
    -
      type: "Container"
      max:
        cpu: "2" 
        memory: "1Gi" 
      min:
        cpu: "100m" 
        memory: "4Mi" 
      default:
        cpu: "300m" 
        memory: "200Mi" 
      defaultRequest:
        cpu: "200m" 
        memory: "100Mi" 
      maxLimitRequestRatio:
        cpu: "10"
```

### Configuring Quota Synchronization Period
1. setting /etc/origin/master/master-config.yaml file
```
kubernetesMasterConfig:
  apiLevels:
  - v1beta3
  - v1
  apiServerArguments: null
  controllerArguments:
    resource-quota-sync-period:
      - "10s"
```
2. restart master service
