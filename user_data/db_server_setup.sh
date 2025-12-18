#!/bin/bash
yum update -y
yum install -y postgresql-server
systemctl enable postgresql
systemctl start postgresql
