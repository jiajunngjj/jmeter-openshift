#!/usr/bin/env bash

working_dir=`pwd`

#Get namesapce variable
# tenant=`awk '{print $NF}' $working_dir/tenant_export`

## Create jmeter database automatically in Influxdb

echo "Creating Influxdb jmeter Database"

##Wait until Influxdb Deployment is up and running
##influxdb_status=`oc get po -n $tenant | grep influxdb-jmeter | awk '{print $2}' | grep Running

influxdb_pod=`oc get pod | grep influxdb | awk '{print $1}'`
oc exec -ti $influxdb_pod -- influx -execute 'CREATE DATABASE jmeter'

## make sure the db is created

# $ oc rsh $influxdb_pod 

oc exec -ti $influxdb_pod -- influx -execute 'SHOW DATABASES'

## Create the influxdb datasource in Grafana

echo "Creating the Influxdb data source"
influxdb_pod=`oc get pod | grep influxdb | awk '{print $1}'`

## Make load test script in Jmeter master pod executable

#Get Master pod details

master_pod=`oc get pod | grep jmeter-master | awk '{print $1}'`

##oc cp $working_dir/influxdb-jmeter-datasource.json -n $tenant $grafana_pod:/influxdb-jmeter-datasource.json

grafana_pod_ip=`oc get svc | grep jmeter-grafana | awk '{print $3}'`

oc exec -it $influxdb_pod -- curl "http://admin:admin@$grafana_pod_ip:3000/api/datasources" -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://jmeter-influxdb:8086","access":"proxy","isDefault":true,"database":"jmeter","user":"admin","password":"admin"}'
