# Gitlab deploy

## gitlab deployment steps

### create gitlab.yaml and oc create -f gitlab.yaml

```
apiVersion: v1
kind: DeploymentConfig
metadata:
  creationTimestamp: null
  labels:
    run: git
  name: git
spec:
  replicas: 1
  selector:
    run: git
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
        run: git
    spec:
      containers:
      - env:
        - name: DEBUG_ENTRYPOINT
          value: "1"
        - name: GITLAB_SECRETS_DB_KEY_BASE
          value: <xxxxxxx>
        - name: DEBUG
          value: "true"
        - name: DB_HOST
          value: <xxxxxxx>
        - name: DB_ADAPTER
          value: postgresql
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: gitlab
        - name: DB_USER
          value: <xxxxxx>
        - name: DB_PASS
          value: <xxxxxx>
        - name: REDIS_HOST
          value: <xxxxxxx>
        - name: REDIS_PORT
          value: "6379"
        - name: LDAP_ACTIVE_DIRECTORY
          value: "false"
        - name: LDAP_BIND_DN
          value: cn=<xxxx>,dc=<xxxx>,dc=<xxx>
        - name: dc
          value: org
        - name: dc
          value: org
        - name: LDAP_ENABLED
          value: "true"
        - name: LDAP_HOST
          value: <xxxxxxxxx>
        - name: LDAP_LABEL
          value: ldap
        - name: LDAP_PASS
          value: <xxxxxx>
        - name: LDAP_PORT
          value: "389"
        - name: LDAP_UID
          value: uid
        - name: LDAP_BASE
          value: dc=<xxxx>,dc=<xxxx>
        - name: dc
          value: org
        - name: LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN
          value: "true"
        - name: GITLAB_HOST
          value: code.dataos.io
        - name: OAUTH_GITHUB_API_KEY
          value: <xxxxxxxxxxxxxx>
        - name: OAUTH_GITHUB_APP_SECRET
          value: <xxxxxxxxxxxxxxxxxxx>
        image: sameersbn/gitlab
        imagePullPolicy: Always
        name: git
        resources: {}
        terminationMessagePath: /dev/termination-log
        volumeMounts:
        - mountPath: /home/git/data
          name: volume-yt62j
      dnsPolicy: ClusterFirst
      nodeSelector:
        node: 0-242
      restartPolicy: Always
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - nfs:
          host: xxx.xxx.xxx.xxx
          path: /gitlab
        name: volume-yt62j
  test: false
  triggers:
  - type: ConfigChange
status: {}
```

### Environment

1. nfs host path, and mount at /gitlab on host
2. deployment config use hostPaht volume '/gitlab'
3. use aws rds postgresql and aws elastic search redis service
4. debug gitlab errors, oc rsh git-pod-name and check logs 
5. for more information, view https://hub.docker.com/r/sameersbn/gitlab/

### 问题处理
1、服务器重启后无法访问gitlab ssh服务端口
gitlab ssh服务是通过kubernetes service node-port方式实现，也就是kubernetes会在每个节点上为service占用特定端口，可以通过访问每个节点上的指定端口都可以使用gitlab的ssh服务，但是需要在每个节点上iptables开放gitlab ssh 指定的端口，如果在没有保存iptables规则的情况下重启服务，这条路由就会丢失，导致gitlab ssh服务无法使用。
