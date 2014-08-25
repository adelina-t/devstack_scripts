##
##
## Deletes the networks created by the devstack script and creates new ones
##
##
##

neutron router-gateway-clear router1 > /dev/null 2>&1
SUBNETS=$(neutron subnet-list | grep start | awk '{print $2}')
for i in $SUBNETS
do
    neutron router-interface-delete router1 $i >/dev/null 2>&1
    neutron subnet-delete $i > /dev/null 2>&1
done

NETS=$(neutron net-list | awk '{print $2}' | sed -n '/\([a-z0-9]\)\{8\}-\(\([a-z0-9]\)\{4\}-\)\{3\}\([0-9a-z]\)\{12\}/p')

for i in $NETS
do
    neutron net-delete $i
done


NETID1=`neutron net-create private  | awk '{if (NR == 6) {print $4}}'`
EXTNETID1=`neutron  net-create public --router:external=True | awk '{if (NR == 6) {print $4}}'`
SUBNETID1=`neutron  subnet-create private 192.168.0.1/24 --dns_nameservers list=true 8.8.8.8 | awk '{if (NR == 11) {print $4}}'`
SUBNETID2=`neutron  subnet-create public --allocation-pool start=10.7.20.51,end=10.7.20.70 --gateway 10.7.1.1 10.7.0.0/16 --enable_dhcp=False | awk '{if (NR == 11) {print $4}}'`
neutron router-interface-add router1 $SUBNETID1 
neutron router-gateway-set router1 $EXTNETID1 
