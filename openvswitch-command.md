#### 列出所有 bridge 和 port
```
ovs-vsctl show
```
#### 查看 openflow port
```
ovs-ofctl -O OpenFlow13 show br0
```
#### 查看 openflow port table
```
ovs-ofctl -O OpenFlow13 dump-ports br0
```
#### 查看 openflow flow table
```
ovs-ofctl -O OpenFlow13 dump-flows br0
```
