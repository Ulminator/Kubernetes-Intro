Kubernetes - Container orchestrator

Container Image will always run the same appp regardless of environment.

java -jar sentiment-analysis-web-0.0.1-SNAPSHOT.jar --sa.logic.api.url=http://localhost:5000

python -m pip install -r requirements.txt
python -m textblob.download_corpora
python sentiment_analysis.py


Cons of VM
    - Resource inefficient, each VM has the overhead of a fully-fledged OS.
    - It is platform dependent. What worked on your computer might not work on the production server.
    - Heavyweight and slow scaling when compared to Containers.

Prod of Containers
    - Resource efficient, use the Host OS with the help of Docker.
    - Platform independent. The container you run on your computer will work anywhere.
    - Lightweight using image layers.

Login
-----
docker login -u="$Username" -p="$Passord"

Creating Image
--------------
docker build -f Dockerfile -t $User_ID/sentiment-analysis-frontend .

Push to Docker Hub
------------------
docker push $User_ID/sentiment-analysis-frontend

Running
-------
docker pull $User_ID/sentiment-analysis-frontend
docker run -d -p 80:80 $User_ID/sentiment-analysis-frontend

-p <hostPort>:<containerPort>

### IMPORTANT
If you do not have native docker support, you can open the application in <docker-machine ip>:80. To find your docker-machine ip execute ```docker-machine ip```

.dockerignore
    - Add all directories that you want to ignore and not is not needed to build the image.

Stop all containers
```docker stop $(docker ps -aq)```

Kill all containers
```docker kill $(docker ps -aq)```

Remove all images
```docker rmi $(docker images -q)```

Another strong point that Kubernetes drives home, is that it standardizes the Cloud Service Providers (CSPs). This is a bold statement, but let’s elaborate with an example:

– An expert in Azure, Google Cloud Platform or some other CSP ends up working on a project in an entirely new CSP, and he has no experience working with it. This can have many consequences, to name a few: he can miss the deadline; the company might need to hire more resources, and so on.

In contrast, with Kubernetes this isn’t a problem at all. Because you would be executing the same commands to the API Server no matter what CSP. You on a declarative manner request from the API Server what you want. Kubernetes abstracts away and implements the how for the CSP in question.

https://www.amazon.com/Kubernetes-Action-Marko-Luksa/dp/1617293725

https://medium.freecodecamp.org/learn-kubernetes-in-under-3-hours-a-detailed-guide-to-orchestrating-containers-114ff420e882

https://hub.docker.com/r/ulminator

docker run -d -p 5050:5000 $DOCKER_USER_ID/sentiment-analysis-logic

docker run -d -p 8080:8080 -e SA_LOGIC_API_URL='http://<container_ip or docker machine ip>:5000' $DOCKER_USER_ID/sentiment-analysis-web-app

docker run -d -p 80:80 $DOCKER_USER_ID/sentiment-analysis-frontend

### Kubernetes

minikube start
    - Provides a Kubernetes Cluster that has only one node
    - Kubernetes abstract away how many nodes so it does not matter that we will be using only one.

Pods
----
    - Can be composed of one or even a group of containers that share the same execution environment.
    - Usually just one container per pod, but there are special cases
        - When two containers need to share volumes
        - They communicate with each other using inter-process communication
        - Or otherwise tightly coupled
    - Not tied to Docker containers

    - Each pod has a unique IP address in the cluster
    - Pod can have multiple containers. Containers share the same port space. Communication with containers of other pods has to be done in conjunction with the pod ip.
    - Containers in a pod share the same volume, same ip, port space, IPC namespace.

minikube start
minikube login: root
kubectl get nodes

kubectl create -f ./resource-manifests/sa-frontend-pod.yaml
kubectl get pods
kubectl port-forward sa-frontend 88:80
Forwarding from 127.0.0.1:88 -> 80

minikube dashboard


In our Kubernetes cluster, we will have pods with different functional services. (The frontend, the Spring WebApp and the Flask Python application). So the question arises how does a service know which pods to target? I.e. how does it generate the list of the endpoints for the pods?

This is done using Labels, and it is a two-step process:

1. Applying a label to all the pods that we want our Service to target and
2. Applying a “selector” to our service so that defines which labeled pods to target.

(TO UPDATE EXISTING POD)
kubectl apply -f sa-frontend-pod.yaml 

(GETS PODS WITH SPECIFIED LABEL)
kubectl get pod -l app=sa-frontend 
kubectl get pod -l app=sa-frontend --show-labels

Load Balancers
--------------

kubectl create -f resource-manifests/service-sa-frontend-lb.yaml
kubectl get svc
    - External-IP is in pending state just because of using Minikube.
    - Deployed on GCP or Azure we would get a Public IP accessible worldwide.

Local Debugging
---------------
minikube service sa-frontend-lb

Kubernetes in Practice - Deployments
------------------------------------

kubectl apply -f sa-frontend-deployment.yaml

Delete Pods
-----------

kubectl delete pod <pod-name>

If you delete a pod made through deployment, another will spin up and take it's place.

### Benefits

Zero Downtime
-------------
- Change the container image and deploy
kubectl apply -f sa-frontend-deployment-green.yaml --record
- Check status using the following command:
kubectl rollout status deployment sa-frontend
- Verify deployment
minikube service sa-frontend-lb

Rolling Back To Previous State
------------------------------
- Check revisions
kubectl rollout history deployment sa-frontend
    - The --record above will keep track of CHANGE-CAUSE
- Rollback to specified revision
kubectl rollout undo deployment sa-frontend --to-revision=1

Service SA Logic

kubectl apply -f sa-logic-deployment.yaml --record
- Service that “acts as the entry point to a set of pods that provide the same functional service”
kubectl apply -f service-sa-logic.yaml --record

Deployment SA Web-App

kubectl apply -f sa-web-app-deployment.yaml --record

 - Now need to expose the pod externally with a LoadBalancer Service.

 kubectl apply -f service-sa-web-app-lb.yaml --record

Get SA-WebApp LoadBalancer IP
minikube service list
