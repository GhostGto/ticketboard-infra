#!/bin/bash

echo "🏥 Health check for TicketBoard..."

echo "📊 Namespace status:"
kubectl get all -n ticketboard

echo "🔍 Pods details:"
kubectl describe pods -n ticketboard

echo "📝 Recent events:"
kubectl get events -n ticketboard --sort-by=.metadata.creationTimestamp