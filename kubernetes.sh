kubectl apply -f resource-manifests/sa-frontend-deployment.yaml --record
kubectl apply -f resource-manifests/service-sa-frontend-lb.yaml --record

kubectl apply -f resource-manifests/sa-logic-deployment.yaml --record
kubectl apply -f resource-manifests/service-sa-logic.yaml --record

kubectl apply -f resource-manifests/sa-web-app-deployment.yaml --record
kubectl apply -f resource-manifests/service-sa-web-app-lb.yaml --record

