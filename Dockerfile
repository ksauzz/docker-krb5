FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gettext \
      supervisor \
      krb5-admin-server \
      krb5-kdc \
      expect

COPY ./entrypoint.sh /
COPY ./conf/kadm5.acl ./conf/kdc.conf.tmpl /etc/krb5kdc/
COPY ./conf/krb5.conf.tmpl ./conf/supervisord.conf /etc/

RUN chmod 755 /entrypoint.sh

ENV MASTER_PASS  passwd
ENV ADMIN_PRINC  admin/admin@EXAMPLE.COM
ENV ADMIN_PASS   admin
ENV USER_PRINC   user@EXAMPLE.COM
ENV USER_PASS    pass
ENV DOMAIN       example.com
ENV REALM        EXAMPLE.COM
ENV DATA_ROOT    /var/lib/krb5kdc

EXPOSE 88 464 749 754

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
