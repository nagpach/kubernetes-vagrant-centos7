testing kubernetes cluster 


kubectl --server http://192.168.20.2:8080 get pods

Basics

wget https://raw.githubusercontent.com/kubernetes/kubernetes.github.io/release-1.3/docs/user-guide/walkthrough/pod-nginx.yaml
kubectl --server http://192.168.20.2:8080 create -f pod-nginx.yaml 
kubectl --server http://192.168.20.2:8080 get pods
wget http://kubernetes.io/docs/user-guide/walkthrough/pod-redis.yaml
kubectl --server http://192.168.20.2:8080 create -f pod-redis.yaml 
kubectl --server http://192.168.20.2:8080 get pods --all-namespaces
kubectl --server http://192.168.20.2:8080 describe pods podname
kubectl --server http://192.168.20.2:8080 delete pod nginx

Labels

wget http://kubernetes.io/docs/user-guide/walkthrough/pod-nginx-with-label.yaml
kubectl --server http://192.168.20.2:8080 create -f pod-nginx-with-label.yaml
kubectl --server http://192.168.20.2:8080 get pods -l app=nginx


Deployments

wget https://raw.githubusercontent.com/kubernetes/kubernetes.github.io/release-1.3/docs/user-guide/walkthrough/deployment.yaml
kubectl --server http://192.168.20.2:8080 create -f deployment.yaml
kubectl --server http://192.168.20.2:8080 get deployment



Services

wget https://raw.githubusercontent.com/kubernetes/kubernetes.github.io/release-1.3/docs/user-guide/walkthrough/service.yaml
kubectl --server http://192.168.20.2:8080 create -f service.yaml
kubectl --server http://192.168.20.2:8080 get services


Health Checking

wget https://raw.githubusercontent.com/kubernetes/kubernetes.github.io/release-1.3/docs/user-guide/walkthrough/pod-with-http-healthcheck.yaml
kubectl create -f pod-with-http-healthcheck.yaml


misc

kubectl --server http://192.168.20.2:8080 run nginx --image=nginx:1.9.12
kubectl --server http://192.168.20.2:8080 expose rc nginx --port=80 --type=NodePort
kubectl --server http://192.168.20.2:8080 describe svc nginx

du --exclude downloads --exclude binaries -h .
