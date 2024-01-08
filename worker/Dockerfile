ARG FRAPPE_BRANCH=develop
FROM frappe/erpnext-worker:${FRAPPE_BRANCH}

ARG GITHUB_OWNER=msf4-0 			# you could give a default value as well
ENV GITHUB_OWNER=$GITHUB_OWNER

COPY remove_erp.sh /remove_erp

RUN /remove_erp

RUN install_app erpnext https://github.com/seejayyy/ERPNext-LGM main
