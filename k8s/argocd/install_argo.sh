kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 10
echo "admin password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
echo "Apply the service application definition"
kubectl apply -f argocd_service_definition.yml
kubectl port-forward -n argocd  svc/argocd-server 8082:443
