# Minikube 
.PHONY: minikube-start
minikube-start:
	@echo "Minikube - Starting ..."
	@minikube start
	@minikube addons enable ingress
	@minikube addons enable metrics-server

.PHONY: minikube-stop
minikube-stop:
	@echo "Minikube - Stopping ..."
	@minikube stop

.PHONY: minikube-delete
minikube-delete:
	@echo " Minikube - Deleting ..."
	@minikube delete

.PHONY: check-minikube
check-minikube: minikube-start
	@echo "Minikube - Checking if is ready..."
	@minikube status | grep -q "host: Running" && minikube status | grep -q "kubelet: Running" && minikube status | grep -q "apiserver: Running" || { \
		echo "Minikube is not ready. Please ensure Minikube is running before executing this task."; \
		exit 1; \
	}

# Backstage
.PHONY: backstage-build-image
backstage-build-image:
	@echo "Backstage - Building image ..."
	@yarn install --frozen-lockfile
	@yarn tsc
	@yarn build:backend --config ../../app-config.yaml
	@docker image build . -f packages/backend/Dockerfile --tag backstage:1.0.0

.PHONY: backstage-install
backstage-install:
	@echo "Backstage - Installing..."
	@minikube image load backstage:1.0.0
	@echo "Backstage - Creating data folder ..."
	@minikube ssh -- "sudo mkdir -p /mnt/data"

	@echo "Backstage - Applying backstage k8s config ..."
	# @kubectl apply -f kubernetes/backstage-config.yaml
	@minikube_ip=$$(minikube ip) && \
	sed "s/MINIKUBE_IP/$${minikube_ip}/g" iac/manifest.yml | kubectl apply -f -

.PHONY: backstage-open
backstage-open:
	@echo "Backstage - Opening ..."
	@kubectl port-forward svc/backstage 7007:80 -n backstage

# ArgoCD
ARGOCD_NAMESPACE := argocd
ARGOCD_MANIFEST_URL := https://raw.githubusercontent.com/argoproj/argo-cd/v2.5.8/manifests/install.yaml  
ARGOCD_ADMIN_PASSWORD := admin

ARGOCD_BACKSTAGE_USER := backstage
ARGOCD_BACKSTAGE_PASSWORD := backstage 

.PHONY: argocd-install
argocd-install: check-minikube
	@echo "ArgoCD - Installing ..."

	@echo "ArgoCD - Creating namespace ..."
	@kubectl create namespace $(ARGOCD_NAMESPACE) || echo "Namespace $(ARGOCD_NAMESPACE) already exists."

	@echo "ArgoCD - Applying manifest ..."
	@kubectl apply --namespace $(ARGOCD_NAMESPACE) --filename $(ARGOCD_MANIFEST_URL)

	@echo "ArgoCD - Applying config ..."
	@kubectl apply --namespace $(ARGOCD_NAMESPACE) --filename argocd-config.yaml

.PHONY: argocd-change-admin-password
argocd-change-admin-password: argocd-install
	@echo "ArgoCD - Generating bcrypt hash for the new admin password..."
	@NEW_BCRYPT_HASH=$$(argocd account bcrypt --password $(ARGOCD_ADMIN_PASSWORD)); \

	@echo "ArgoCD - Patching the secret with the new password hash..."; \
	@kubectl -n $(ARGOCD_NAMESPACE) patch secret argocd-secret \
		-p "{\"stringData\": { \
			\"admin.password\": \"$$NEW_BCRYPT_HASH\", \
			\"admin.passwordMtime\": \"$$(date +%FT%T%Z)\" \
		}}"; \
	@echo "ArgoCD - admin password has been updated successfully."

.PHONY: argocd-open-ui
argocd-open-ui:
	minikube service --namespace $(ARGOCD_NAMESPACE) argocd-server

.PHONY: argocd-clean
argocd-clean:
	kubectl delete --namespace $(ARGOCD_NAMESPACE) --filename $(ARGOCD_MANIFEST_URL)
	kubectl delete namespace $(ARGOCD_NAMESPACE)

.PHONY: argocd-login
argocd-login: 
	@echo "ArgoCD - Checking if server is ready..."
	@until minikube service --namespace $(ARGOCD_NAMESPACE) argocd-server-nodeport --url > /dev/null 2>&1 && \
	curl --output /dev/null --silent --head --fail \
		$$(minikube service --namespace $(ARGOCD_NAMESPACE) argocd-server-nodeport --url | sed 's/http:\/\///'); do \
		echo "Waiting for Argo CD server to be ready..."; \
		sleep 5; \
	done
	@echo "Argo CD server is ready. Logging in..."
	@argocd login $$(minikube service --namespace $(ARGOCD_NAMESPACE) argocd-server-nodeport --url | sed 's/http:\/\///') \
		--insecure --username admin --password $(ARGOCD_ADMIN_PASSWORD)
	@echo "Logged in to Argo CD."

.PHONY: argocd-change-backstage-user-password
argocd-change-backstage-user-password: argocd-login
	@echo "Changing new Argo CD user $(ARGOCD_BACKSTAGE_USER)..."
	@argocd account update-password --account $(ARGOCD_BACKSTAGE_USER) --current-password $(ARGOCD_ADMIN_PASSWORD) \
		--new-password  $(ARGOCD_BACKSTAGE_PASSWORD) 
	@echo "$(ARGOCD_BACKSTAGE_USER) password changed successfully."

# Gitlab
GITLAB_NAMESPACE=gitlab

.PHONY: gitlab-install
gitlab-install:
	@echo "GitLab - Installing in Minikube..."
	@kubectl create namespace $(GITLAB_NAMESPACE) || echo "Namespace $(GITLAB_NAMESPACE) already exists."
	@helm repo add gitlab https://charts.gitlab.io/
	@helm repo update
	@helm install gitlab gitlab/gitlab --namespace $(GITLAB_NAMESPACE) \
		--set global.hosts.domain=example.com \
		--set global.hosts.externalIP=$(minikube ip) \
		--set certmanager-issuer.email=me@example.com
	@echo "Waiting for GitLab to be ready..."
	@kubectl rollout status deployment/gitlab-webservice-default -n $(GITLAB_NAMESPACE)
	@echo "GitLab - Installation complete. Access it via: http://gitlab.$(minikube ip).nip.io"

.PHONY: run
run: minikube-start backstage-build-image backstage-install
