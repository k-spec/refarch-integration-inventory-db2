# DB2 Inventory Database
This project is part of the 'IBM Integration Reference Architecture' suite, available at [https://github.com/ibm-cloud-architecture/refarch-integration](https://github.com/ibm-cloud-architecture/refarch-integration).
This project represents on-premise deployment so you need a running DB2 server to install the database.

Updated - September 2018, we are reusing this project for a [lift and shift of MQ, WAS and DB2 workloads to the IBM Cloud ](https://github.com/ibm-cloud-architecture/refarch-integration/blob/master/docs/toSaaS/readme.md) (Public) solution. The migrate DB2 database tutorial can be read [here](docs/db2-cloud.md).

## Table of Contents
* [Project goals](#goals)
* [Run locally with docker](#run-locally)
* [On premise installation](#db2-server-installation)
* [Lift and shift DB2 workload to IBM Cloud](docs/db2-cloud.md)
* [Deploy DB2 to ICP for development](docs/db2-icp.md)
* [Administer DB2 databases](#administer)

## Goals

This project supports scripts to create DB2 `Inventory` database and load it with 12 items related to old computers. And for customer table to support Customer churn demonstration.

### For inventory DB

The Data model looks like the following diagram:

![](docs/inventory-model.png)

The ItemEntity is mapped to a ITEMS table to persist item information
The SupplierEntity is mapped to the SUPPLIER table to persist information about the supplier delivering the item.
The Inventory is mapped to INVENTORY table to persist item allocated per site. When a new item is added the supplier id is used as foreign key to the SUPPLIER table.

### For Customer DB

The model defines four main tables: customers, accounts and products, and a join table as customer may have multiple products. Customer has one account only. To simplify our life.

## Run Locally 

We are providing a dockerfile to tune the ibmcom base db2express-c image and a set of scripts to prepare table and load data.
```
# Start the docker container
$ ./rundb2docker.sh
# change the user
$ su - db2inst1
# start db2
[db2inst1@9f3200f453e4 ~]$ db2start
# create the database
db2inst1@9f3200f453e4 ~]$ cd browndb/db-sql/inventory
db2inst1@9f3200f453e4 ~]$ ./createDB.sh
```

## DB2 Server Installation

The following steps can be done manually to create a VM with REDHAT. We are using vmware vSphere center.
* Create a vm machine for a REDHAT 7 (64 bits) OS using ESXi 5.5  
* Configure the virtual machine to start on RedHat .iso file (configure DVD to point to .iso file). Be sure to select connect at power on  
![](docs/cd-drive.png)
* Configure REDHAT: Attention spend time to go over each configuration items if not you may have to reinstall or the install will not complete.
[See this note from RedHat](https://developers.redhat.com/products/rhel/hello-world/#fndtn-vmware_get-ready-for-software-development], in particular the Software Selection: Server with GUI in the Base Environment: Select the target destination disk that will map the one configured at the virtual machine settings.
* Reboot and finalize the language and time settings.
* Create an *admin* user
* Once logged as *admin* on the newly operational OS, download the free version of DB2 Express v11 from [here](https://www-01.ibm.com/marketing/iwm/iwm/web/pick.do?source=swg-db2expressc) as a gz file
* Unzip the gz file under **/home/admin/IBM/expc**
* Login as root goes to **/home/admin/IBM/expc** and execute `./db2setup`. The wizard creates two users **db2inst1** and **db2fenc1**
* Once installation is done login as **db2inst1** and then validate your installation files, instance, and database functionality, run the Validation Tool, `/opt/ibm/db2/V11.1/bin/db2val`

When a database is created, there are several objects created by default: table spaces, tables, a buffer pool and log files.
 * Table space SYSCATSPACE contains the System Catalog tables.
 * Table space TEMPSPACE1 is used by DB2 when it needs additional space to perform some operations such as sorts.
 * Table space USERSPACE1 is normally used to store user database tables if there is no table space specified when creating a table
* The OS firewall was disabled
 ```
 $ systemctl status firewalld
 $ service firewalld stop
 $ systemctl disable firewalld
 ```
* If not done already, clone this repository as you need the INVDB scripts
```
git clone https://github.com/ibm-cloud-architecture/refarch-integration-inventory-db2.git
```
## Administer
### Inventory
The folder db-scripts includes shell scripts to create the INVDB and populate it with 12 items. This script has to be executed on the DB2 server as it uses db2 CLI.
```
$ createDB.sh
```

The project [refarch-integration-tests](https://github.com/ibm-cloud-architecture/refarch-integration-tests) includes Java and nodejs code to test each component of Brown compute solution and specially DB2 Inventory DB: the scripts is testInventoryDB2.sh.

### Customers

### DB2 command summary

|Command|Description|
|-------|---------|
|db2level|get the version of the product|
|db2licm -l|Get license info |
|db2val|Validate installation|
|db2ilist|to list instance created.  An instance is simply an independent environment where applications can run, and databases can be created. You can create multiple instances on a data server.  On Linux, an instance must match a Linux operating system user|
|db2icrt myinst|Create a new DB instance. But this is not necessary as db2inst1 is the instance created by installation. New instance means also new user created|
|db2start and db2stop|Performed while logged as db2inst1 user for example|
|db2 create database invdb|To create a database inside of the instance|
|db2 list tables for all|Get the list of all tables in the instance|
|db2 list tables for schema DB2INST1|For a given schema like db2inst1|
|db2 describe table items|See the structure of a table|
|db2 insert into <tab_name>(col1,col2,...)  values(val1,val2,..)|Insert data to table|
|db2 select id,name from items | select some columns and all rows for a given table|

## Verify DB2 is accessible

Using Eclipse DataBase Development perspective, define a new connection using the jdbc driver which can be found at: [refarch-premsource-inventory-dal](https://github.com/ibm-cloud-architecture/refarch-integration-inventory-dal)/lib/db2jcc4.jar  

![Eclipse DB Connection](docs/db2-cx-eclipse.png)
The parameters are:
`jdbc:db2://172.16.254.23:50000/INVDB:retrieveMessagesFromServerOnGetMessage=true;`
Once connected you can perform some SQL query, update records, etc... Useful during development time.

Also note that the testing project has code to test DB2 availability. See [Integration tests](https://github.com/ibm-cloud-architecture/refarch-integration-tests)

## Update the DB schema
* It may be needed to adapt the schema by adding new columns to one table. To do so, you can use Eclipse Database development perspective and connect to the DB and use SQL script editor.
```
alter table items add column  serialNumber VARCHAR(50);
```
For more information about the `alter` command for DB2 see the [knowledge center note.](https://www.ibm.com/support/knowledgecenter/en/SSEPEK_11.0.0/sqlref/src/tpc/db2z_sql_altertable.html)

## Working on data

* removing row:
`delete from inventory where id = '531'`

## Common issues

While updating row or insert new row in a table, like INVENTORY, you may get a SQLERROR = -668.  You may need to reorganize the table. Connect to the DB using eclipse database development perspective, use a SQL script and perform the command:
`call ADMIN_CMD('REORG TABLE INVENTORY')`
update should work.

## DB2 Reference material for knowledge acquisition
* [Free e-book](http://publib.boulder.ibm.com/epubs/pdf/dsncrn01.pdf)
* [dw article](https://www.ibm.com/developerworks/data/newto/db2luw-getstarted.html)
* [Considerations for building and deploying DB2 Docker containers](https://developer.ibm.com/articles/dm-1602-db2-docker-trs/)
