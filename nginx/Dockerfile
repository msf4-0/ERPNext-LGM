ARG FRAPPE_BRANCH=develop
FROM node:14-buster

ARG GITHUB_OWNER=msf4-0 			# you could give a default value as well
ENV GITHUB_OWNER=$GITHUB_OWNER

COPY install_frappe.sh /install_frappe
#COPY install_erpnext.sh /install_erpnext
COPY install_app.sh /install_app
COPY prepare_production.sh /prepare_production

# Install frappe
RUN /install_frappe ${FRAPPE_BRANCH} && \
  #/install_erpnext && \
  # Install required apps with following command
  # /install_app <app_name> <repo> <app_branch>
  /install_app erpnext https://github.com/seejayyy/ERPNext-LGM main && \
  /prepare_production

FROM frappe/erpnext-nginx:${FRAPPE_BRANCH}

COPY --from=0 /home/frappe/frappe-bench/sites/ /var/www/html/
COPY --from=0 /rsync /rsync

# Append list of installed to apps.txt
RUN echo -n "erpnext\n" >> /var/www/html/apps.txt

VOLUME [ "/assets" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
