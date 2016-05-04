### phpldapadmin deployment config yaml
```
apiVersion: v1
kind: DeploymentConfig
metadata:
  annotations:
    openshift.io/deployment.cancelled: "2"
  creationTimestamp: null
  labels:
    run: phpldapadmin
  name: phpldapadmin
spec:
  replicas: 1
  selector:
    run: phpldapadmin
  strategy:
    resources: {}
    rollingParams:
      intervalSeconds: 1
      maxSurge: 25%
      maxUnavailable: 25%
      timeoutSeconds: 600
      updatePeriodSeconds: 1
    type: Rolling
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: phpldapadmin
    spec:
      containers:
      - env:
        - name: PHPLDAPADMIN_LDAP_HOSTS
          value: ldap-lb-1160675848.cn-north-1.elb.amazonaws.com.cn
        image: osixia/phpldapadmin:0.6.8
        imagePullPolicy: IfNotPresent
        name: phpldapadmin
        resources: {}
        terminationMessagePath: /dev/termination-log
      dnsPolicy: ClusterFirst
      nodeSelector:
        node: container9
      restartPolicy: Always
      securityContext: {}
      terminationGracePeriodSeconds: 30
  test: false
  triggers:
  - type: ConfigChange
status: {}
```

### steps
1. oc create -f phpldapadmin.yaml
2. oc export dc phpldapadmin --port 443
3. oc create route passthrough --service phpldapadmin

### information links
https://github.com/osixia/docker-phpLDAPadmin
