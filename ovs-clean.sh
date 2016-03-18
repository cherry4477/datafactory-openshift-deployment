#!/bin/bash
echo "--------------------------------" >> /var/log/dump_flows.log
echo "Begin at $(date "+%F %R")---------------------------" >> /var/log/dump_flows.log
ovs-ofctl -O OpenFlow13 dump-flows br0 >> /var/log/dump_flows.log

flow_ports=$(ovs-ofctl -O OpenFlow13 dump-flows br0| grep output| grep -v  '\-'| cut -d : -f2| uniq | sort -n)

ports=$(ovs-ofctl -O OpenFlow13 dump-ports br0| grep -v ports| grep port| cut -d : -f1| awk '{print $2}' | sort -n)

#ovs-ofctl -O OpenFlow13 del-flows br0 "out_port=$i"
echo "Action --------------------------------------------" >> /var/log/dump_flows.log
for i in $flow_ports; do
  [[ ${ports[@]} =~ $i ]] && (echo $i "in [" $ports "]") || (echo $i "not in [" $ports "]"; echo $i "not in [" $ports "] and will delete flows" >> /var/log/dump_flows.log ;echo $(ovs-ofctl -O OpenFlow13 dump-flows br0 "out_port=$i") >> /var/log/dump_flows.log; ovs-ofctl -O OpenFlow13 del-flows br0 "out_port=$i");
done

echo "End --------------------------------" >> /var/log/dump_flows.log
