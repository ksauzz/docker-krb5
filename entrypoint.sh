#!/bin/bash

set -ue

add_princ() {
  princ=$1
  pass=$2
  expect -c "
    set timeout 5
    spawn /usr/sbin/kadmin.local
    expect {
      \"kadmin.local:\" {
        send -- \"addprinc $princ\n\"

        expect {
          \"Enter password for principal\" {
            send -- \"$pass\n\"
            exp_continue
          }
          \"Re-enter password for principal\" {
            send -- \"$pass\n\"
            exp_continue
          }
          \"Principal \\\"$princ\\\" created\" {
            exit 0
          }
          \"Principal or policy already exists while creating\" {
            exit 0
          }
        }
      }
    }
"
}

templates="/etc/krb5kdc/kdc.conf.tmpl /etc/krb5.conf.tmpl"
for tmpl in $templates; do
  conf_path=`echo $tmpl | sed 's/\.tmpl$//'`
  echo generating $conf_path ...
  envsubst < $tmpl > $conf_path
done

if [ ! -f $DATA_ROOT/db/principal ]; then
  mkdir -pv $DATA_ROOT/db $DATA_ROOT/key

  # initialize database
  expect -c "
    set timeout 5
    spawn /usr/sbin/kdb5_util create -r $REALM -s
    expect {
      \"Enter KDC database master key\" {
        send -- \"$MASTER_PASS\n\"
        exp_continue
      }
      \"Re-enter KDC database master key to verify:\" {
        send -- \"$MASTER_PASS\n\"
        exp_continue
      }
      eof {
        exit 0
      }
    }
"
  # create admin principal
  add_princ $ADMIN_PRINC $ADMIN_PASS
  add_princ $USER_PRINC $USER_PASS
fi

exec "$@"
