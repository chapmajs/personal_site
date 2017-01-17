---
layout: post
title: Configuring MariaDB Replication
topic: Getting MariaDB replication working with an existing database
category: coding
description: MariaDB/MySQL replication provides an easy way to do realtime database backup, or allow for high-speed LAN access to a read-only reporting DB. Here's my method for getting a new replication slave running from an existing live DB.
image: mariadb.png
---

[MariaDB](https://mariadb.org/), the open-source, non-Oracle drop in replacement for MySQL, supports master->slave database replication. What this means is that a MariaDB server can have one or more slave servers that connect to it and receive live updates as queries are executed on the master. This is useful for live backups as well as running a high speed, low latency read-only reporting database on a local network. It seems like I need to look up some step in the replication set-up process every time I configure a new slave, and none of the existing documents out there match what I typically need to do.

There are a few requirements and limitations for MariaDB replication:

* Connection between master and slave requires the master listen on an address accessible to the slave
* A slave can only replicate one master
* Unique server IDs need to be assigned to the master and slave(s)

The master configuration should be secured with respect to allowing incoming connections. I currently use an existing [OpenVPN](https://openvpn.net/) link to replicate masters to local reporting servers. The MariaDB traffic can be encrypted with SSL/TLS if it must pass through the public Internet. If the master listens on a public-facing interface, it's probably a good idea to restrict source IPs in your server's firewall.

Master Configuration
--------------------

Add a unique [server ID](https://mariadb.com/kb/en/mariadb/replication-and-binary-log-server-system-variables/#server_id) to the master's configuration, usually through `my.cnf`. If set to 0 (default if omitted from the configuration), replication will not work. This will require a restart of MariaDB.

Once you've configured a server ID, you'll need to add a GRANT for replication:

{% highlight mysql %}
MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'1.2.3.4' IDENTIFIED BY 'ReplicationPassword';
{% endhighlight %}

Replace the address `1.2.3.4` with the address that the slave will be connecting from. The identifying password will be encrypted in MariaDB and recent versions of MySQL. You must grant replication on all master databases; however, you can restrict what's actually replicated through the server's configuration, [as shown here](http://forums.mysql.com/read.php?26,388310,388448#msg-388448).

While logged in to the master's host, you can go ahead and prepare a database dump using `mysqldump`. The following command will dump `masterdb` with master position data, which will make configuring the slave simpler:

{% highlight bash %}
$ mysqldump --master-data --add-drop-table --disable-keys -u root -p masterdb > masterdb_replication_load.sqldump
$ gzip masterdb_replication_load.sqldump
{% endhighlight %}

You'll be prompted for the root MariaDB password (you weren't going to type it on the command line and leave it in the shell history, right?!). GZIPping the data isn't necessary if it's very small or you're transferring across a fast, unmetered link. Copy the database dump to the slave machine and proceed with slave configuration.

Slave Configuration
-------------------

As with the master, configure the slave with a unique server ID and restart. The server IDs need to be unique among all servers involved in replication -- if you're replicating to multiple slaves, they each should have a unique ID. Connect as root to the MariaDB console and configure the slave:

{% highlight mysql %}
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='4.3.2.1', MASTER_USER='replication', MASTER_PASSWORD='ReplicationPassword';
{% endhighlight %}

Replace the address `4.3.2.1` with the address that the MariaDB master is listening on, and of course use the `MASTER_USER` and `MASTER_PASSWORD` set when the master was configured. The slave now knows which master it will receive updates from, but the master is not yet running. The database dump from earlier can now be loaded:

{% highlight bash %}
$ pv masterdb_replication_load.sqldump.gz | zcat | mysql -u root -p masterdb
{% endhighlight %}

You'll again be prompted for the root MariaDB password. This snippet uses the `pv` command, which is the [pipe viewer](http://www.ivarch.com/programs/pv.shtml). You can replace it with `cat` if you don't have it and don't want to install it; however, `pv` is basically `cat` with a status bar and provides a general idea of how far along you are in the DB load. Generally a very useful utility to have.

If you're on a non-GNU userland (Mac OS X, *BSD) you will probably need to use `gzcat` instead of `zcat`.

The slave can now be started from the MariaDB console with `START SLAVE`, and its status viewed with `SHOW SLAVE STATUS`:

{% highlight mysql %}
MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 4.3.2.1
                  Master_User: replication
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000010
          Read_Master_Log_Pos: 536038669
               Relay_Log_File: slave-relay-bin.000009
                Relay_Log_Pos: 2455984
        Relay_Master_Log_File: mysql-bin.000010
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 536038669
              Relay_Log_Space: 6126412
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 4321
1 row in set (0.00 sec)
{% endhighlight %}

Notes on Users
--------------

It appears MariaDB replication requires that any users who execute some SQL commands to which the user is associated also exist on the slave server. This issue popped up when configuring replication for a [Ruby on Rails](http://rubyonrails.org/) -- it appears that Rails migrations will cause an error if the Rails application connects as a user other than root if that user does not exist on the slave and have adequate GRANT permissions on the replicated database.

{:.center}
<span><script language="javascript" src="https://services.theglitchworks.net/counters/replication"></script> tables dropped</span>