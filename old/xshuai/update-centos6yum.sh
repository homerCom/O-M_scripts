#!/bin/bash

mkdir /etc/yum.repos.d/backup

mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/

cat>>/etc/yum.repos.d/CentOS-Base.repo<<EOF
[base]

name=CentOS-6.10 - Base - mirrors.aliyun.com

failovermethod=priority

baseurl=http://mirrors.aliyun.com/centos-vault/6.10/os/\$basearch/

gpgcheck=1

gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

#released updates

[updates]

name=CentOS-6.10 - Updates - mirrors.aliyun.com

failovermethod=priority

baseurl=http://mirrors.aliyun.com/centos-vault/6.10/updates/\$basearch/

gpgcheck=1

gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful

[extras]

name=CentOS-6.10 - Extras - mirrors.aliyun.com

failovermethod=priority

baseurl=http://mirrors.aliyun.com/centos-vault/6.10/extras/\$basearch/

gpgcheck=1

gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages

[centosplus]

name=CentOS-6.10 - Plus - mirrors.aliyun.com

failovermethod=priority

baseurl=http://mirrors.aliyun.com/centos-vault/6.10/centosplus/\$basearch/

gpgcheck=1

enabled=0

gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users

[contrib]

name=CentOS-6.10 - Contrib - mirrors.aliyun.com

failovermethod=priority

baseurl=http://mirrors.aliyun.com/centos-vault/6.10/contrib/\$basearch/

gpgcheck=1

enabled=0

gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
EOF

cat>>/etc/yum.repos.d/epel.repo<<EOF
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
baseurl=https://archives.fedoraproject.org/pub/archive/epel/6/\$basearch
failovermethod=priority
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 6 - \$basearch - Debug
baseurl=https://archives.fedoraproject.org/pub/archive/epel/6/\$basearch/debug
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 6 - \$basearch - Source
baseurl=https://archives.fedoraproject.org/pub/archive/epel/6/SRPMS
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1
EOF

yum clean all
yum makecache
