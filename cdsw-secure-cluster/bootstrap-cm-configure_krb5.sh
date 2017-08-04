#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright Cloudera 2013

# logging stdout/stderr
set -x
exec >> /root/bootstrap-cm-configure-krb5.log 2>&1
date

#tmpl_dir="tmpl"
domain="$(hostname -d)"
hostname="$(hostname -f)"
kdc_realm="HADOOP" 
kdc_directory="/var/kerberos/krb5kdc"


kdc_conf_tmpl=$(cat << EOS
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 @@kdc_realm@@ = {
  #master_key_type = aes256-cts
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  default_principal_flags = renewable
  max_renewable_life = 7d

  # WARNING: aes256-ct:normal is disabled to simplify testing, since it
  # requires the enhanced security JCE policy file to be installed. You should
  # NOT run with this configuration in production or any real environment. You
  # have been warned.
  supported_enctypes = aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
 }

EOS
)

kadm5_acl_tmpl=$(cat << EOS
*/admin@@@kdc_realm@@	*

EOS
)

etc_krb5_conf_tmpl=$(cat << EOS
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = @@kdc_realm@@
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
 @@kdc_realm@@ = {
  kdc = @@hostname@@
  admin_server = @@hostname@@
 }

[domain_realm]
 .@@domain@@ = @@kdc_realm@@
 @@hostname@@ = @@kdc_realm@@

EOS
)

cmf_principal_tmpl=$(cat << EOS
cloudera-scm/admin@@@kdc_realm@@

EOS
)

log() {
  local level="$1"
  local msg="$2"

  echo "$(date "+%Y-%m-%d %H:%M:%S") ($$) $level - $msg"
}

error() {
  log ERROR "$1"

  if [ -n "$2" ] ; then
    exit $2
  fi
}

generate_unique_str() {
  $DATE +%Y%m%d-%H%M%S
}

detect_command() {
  local cmd="$1"
  local v="$2"

  log DEBUG "Detecting command $cmd"

  v=${v:-$(echo $cmd | tr 'a-z' 'A-Z')}
  cmd_path=$(type -p $cmd)
  eval_str="${v}=\"$cmd_path\""

  [ -n "$cmd_path" ] || error "Unable to locate command \"$cmd\" in path" 1

  eval "$eval_str"

  log DEBUG "  found at $cmd_path (assigned to \$$v)"
}

configure_environment() {
  log DEBUG "Checking distro type and version"

  [ -f "/etc/redhat-release" ] ||
    error "No /etc/redhat-release found - This only works on RH workalikes!" 1
  [ -n "$hostname" ] ||
    error "hostname -f produced an empty hostname (you're in clown town!)" 1
  [ -n "$domain" ] ||
    error "hostname -d produced an empty domain name (non-fully qualified hostname?)" 1

  detect_command date
  detect_command rpm
  detect_command yum
  detect_command seq
  detect_command mkdir
  detect_command chown
  detect_command chmod
  detect_command sleep
  detect_command sed
  detect_command service
  detect_command chkconfig
  detect_command id

  [ "$($ID -u)" -eq 0 ] || error "You must run this script as root" 1
}

prompt_for_safety() {
  echo "*** Local Kerberos Bootstrapper ***"
  echo
  echo "This utility will bootstrap a local MIT KDC for use with"
  echo "Cloudera Manager and Hadoop. Changes *will* be made to"
  echo "Kerberos related files and any pre-existing KDC. Backups"
  echo "are made of all changes files, but you shouldn't depend"
  echo "on them."
  echo
  echo "Using the following settings:"
  echo
  echo "         domain: ${domain}"
  echo "       hostname: ${hostname}"
  echo "      kdc_realm: ${kdc_realm}"
  echo "  kdc_directory: ${kdc_directory}"
  echo
  echo "*** DANGER DANGER DANGER DANGER DANGER ***"
  echo "You have 10 seconds to hit Control-C to stop this script!"
  echo "*** DANGER DANGER DANGER DANGER DANGER ***"
  echo

  for i in $($SEQ 1 10) ; do
    $SLEEP 1
    echo -n "."
  done

  echo
}

install_krb_packages() {
  log DEBUG "Installing necessary krb5 packages"

  local krb_packages="krb5-server krb5-workstation"

  $YUM install -y $krb_packages || error "Yum install failed" 1

  detect_command kadmin.local KADMIN_LOCAL
  detect_command kadmin
  detect_command kdb5_util
}

configure_kdc() {
  log DEBUG "Setting up the KDC configuration files"

  local kdc_directory_tmp="${kdc_directory}.$(generate_unique_str)"

  $MKDIR "$kdc_directory_tmp" ||
    error "Failed to create KDC temp directory:$kdc_directory_tmp" 1

  echo "${kdc_conf_tmpl}" | $SED -e "s/@@kdc_realm@@/${kdc_realm}/" > "${kdc_directory_tmp}/kdc.conf" ||
    error "Unable to generate kdc.conf" 1

  echo "${kadm5_acl_tmpl}" | $SED -e "s/@@kdc_realm@@/${kdc_realm}/" > "${kdc_directory_tmp}/kadm5.acl" ||
    error "Unable to generate kadm5.acl" 1

  if [ -d "$kdc_directory" ] ; then
    mv "$kdc_directory" "${kdc_directory}.bak.$(generate_unique_str)" ||
      error "Can not back up existing kdc directory: $kdc_directory" 1
  fi

  mv "$kdc_directory_tmp" "$kdc_directory" ||
    error "Unable to move $kdc_directory_tmp to $kdc_directory" 1
}

configure_krb_client() {
  log DEBUG "Setting up krb5 client configuration file"

echo "${etc_krb5_conf_tmpl}" | $SED -e "s/@@kdc_realm@@/${kdc_realm}/g;
    s/@@hostname@@/${hostname}/g;
    s/@@domain@@/${domain}/g;" > "/etc/krb5.conf.tmp" ||
    error "Unable to generate /etc/krb5.conf" 1

  if [ -f "/etc/krb5.conf" ] ; then
    mv "/etc/krb5.conf" "/etc/krb5.conf.bak.$(generate_unique_str)" ||
      error "Unable to back up /etc/krb5.conf" 1
  fi

  mv "/etc/krb5.conf.tmp" "/etc/krb5.conf" ||
    error "Unable to move /etc/krb5.conf.tmp to /etc/krb5.conf" 1
}

create_kdc_database() {
  log DEBUG "Creating the KDC database"

  echo "*** NOTICE NOTICE NOTICE ***"
  echo "The KDC database this utility creates is for TESTING PURPOSES ONLY and"
  echo "should, under no circumstances, be used in a production setting or any"
  echo "situation where strong security is required. The master database"
  echo "password used is not secure, nor is the database created in the most"
  echo "secure manner. You have been warned."
  echo "*** NOTICE NOTICE NOTICE ***"

  log INFO "Creating the KDC can take some time as it gathers random data. To"
  log INFO "help it along, generate some activity on the host (move the mouse,"
  log INFO "generate disk IO, etc.)."

  $KDB5_UTIL -P "cloudera-test" create -s >/dev/null ||
    error "Unable to create kerberos KDC database" 1

  log DEBUG "Generating cloudera-scm/admin principal for Cloudera Manager"

  $KADMIN_LOCAL >/dev/null <<EOF
  addprinc -pw cloudera cloudera-scm/admin
#  xst -k cmf.keytab cloudera-scm/admin
EOF

  echo

  [ "$?" -eq 0 ] || error "Unable to generate and/or export cloudera-scm/admin principal" 1
}

start_services() {
  log DEBUG "Starting KDC and KAdmin services"

  $CHKCONFIG krb5kdc on ||
    error "Failed to set krb5kdc to start on boot" 1
  $CHKCONFIG kadmin on ||
    error "Failed to set kadmin to start on boot" 1

  $SERVICE krb5kdc start ||
    error "Failed to start krb5kdc service" 1
  $SERVICE kadmin start ||
    error "Failed to start kadmin service" 1
}

display_next_steps() {
  echo "*** NEXT ***"
  echo
  echo "Go to the Cloudera Manager console, click on gear icon in the upper right"
  echo "corner, \"Security\" on the left configuration navigation panel, and update"
  echo "the \"Kerberos Security Realm\" to be ${kdc_realm} and save the change."
  echo
  echo "See http://www.cloudera.com/content/cloudera-content/cloudera-docs/CM4Ent/4.5.1/Configuring-Hadoop-Security-with-Cloudera-Manager/cmeechs_topic_4_7.html"
  echo
  echo "Once complete, follow the remaining instructions to configure kerberos in"
  echo "the various Hadoop services described here:"
  echo "http://www.cloudera.com/content/cloudera-content/cloudera-docs/CM4Ent/4.5.1/Configuring-Hadoop-Security-with-Cloudera-Manager/cmeechs_topic_4_8.html"
  echo
  echo "To create kerberos principals for users, run 'kadmin.local' as root (or"
  echo "via sudo) and enter '?' for help."
  echo
}

display_next_steps2() {
  echo "*** NEXT ***"
  echo
  echo "KDC server is configured with realm \"${kdc_realm}\". "
  echo "Please do the following steps here to configure KDC with a cluster managed by Cloudera Manager:"
  echo "http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cm_sg_s4_kerb_wizard.html"
  echo 
  echo "Note that this utility installs the required packages only on the host this runs. If there are"
  echo "two or more servers in the cluster, install the client libraries on the other hosts:"
  echo
  echo "yum -y install krb5-workstation"
}

configure_environment
prompt_for_safety
install_krb_packages
configure_kdc
configure_krb_client
create_kdc_database
start_services
display_next_steps2
