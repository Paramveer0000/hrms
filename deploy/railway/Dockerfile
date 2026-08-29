FROM frappe/erpnext:v16.33.0
USER root
COPY . /opt/hrms-src
RUN cp -a /opt/hrms-src /home/frappe/frappe-bench/apps/hrms \
 && pip install --no-cache-dir -e /home/frappe/frappe-bench/apps/hrms \
 && chown -R frappe:frappe /home/frappe/frappe-bench/apps/hrms
COPY deploy/railway/entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod 0755 /usr/local/bin/railway-entrypoint
USER frappe
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
