#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=`pwd`

#Get namesapce variable
# tenant=`awk '{print $NF}' $working_dir/tenant_export`

read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

#Get Master pod details

#master_pod=`kubectl get pod -n loadtesting | grep jmeter-master | awk '{print $1}'`

master_pod=`oc get pod  | grep jmeter-master | awk '{print $1}'`

oc cp load_test $master_pod:/tmp/load_test

oc exec -ti $master_pod -- chmod +x /tmp/load_test

oc cp $jmx $master_pod:/tmp/pepper_box.jmx

oc exec -ti $master_pod -- chmod +x /tmp/pepper_box.jmx

## Echo Starting Jmeter load test

oc exec -ti $master_pod -- /bin/bash /tmp/load_test /tmp/pepper_box.jmx
