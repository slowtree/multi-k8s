#!/bin/bash
# Deploy script to kubernetes
# Remember to tag images with different versions 
# otherwise the kubectl won't see any changes
# to the configuration you try to apply

# Build images
# Reason for the latest tag to be always there is to make sure
# we can always spin up an instance of all servers with the latest code
# when starting from scratch
docker build -t slowtree/multi-client:latest -t slowtree/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t slowtree/multi-server:latest -t slowtree/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t slowtree/multi-worker:latest -t slowtree/multi-worker:$SHA -f ./worker/Dockerfile ./worker

# Push images to registry both the latest tag and the SHA tag
docker push slowtree/multi-client:latest 
docker push slowtree/multi-client:$SHA 
docker push slowtree/multi-server:latest 
docker push slowtree/multi-server:$SHA
docker push slowtree/multi-worker:latest 
docker push slowtree/multi-worker:$SHA

# Apply kubeconfig files for deployment
kubectl apply -f k8s

# Apply image update for all components
kubectl set image deployments/server-deployment server=slowtree/multi-server:$SHA
kubectl set image deployments/client-deployment client=slowtree/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=slowtree/multi-worker:$SHA