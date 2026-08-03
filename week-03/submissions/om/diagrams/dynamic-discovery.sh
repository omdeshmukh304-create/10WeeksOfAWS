#!/bin/bash

# ======================================================
# Week 3 - Dynamic AWS Resource Discovery
# Author: Your Name
# ======================================================

echo "========================================="
echo "AWS Dynamic Resource Discovery"
echo "========================================="

echo ""
echo "Current AWS Region:"
aws configure get region

echo ""
echo "-----------------------------------------"
echo "Available VPCs"
echo "-----------------------------------------"
aws ec2 describe-vpcs \
    --query "Vpcs[*].[VpcId,CidrBlock,State]" \
    --output table

echo ""
echo "-----------------------------------------"
echo "Subnets"
echo "-----------------------------------------"
aws ec2 describe-subnets \
    --query "Subnets[*].[SubnetId,VpcId,CidrBlock,AvailabilityZone]" \
    --output table

echo ""
echo "-----------------------------------------"
echo "Route Tables"
echo "-----------------------------------------"
aws ec2 describe-route-tables \
    --query "RouteTables[*].[RouteTableId,VpcId]" \
    --output table

echo ""
echo "-----------------------------------------"
echo "Internet Gateways"
echo "-----------------------------------------"
aws ec2 describe-internet-gateways \
    --query "InternetGateways[*].[InternetGatewayId]" \
    --output table

echo ""
echo "-----------------------------------------"
echo "NAT Gateways"
echo "-----------------------------------------"
aws ec2 describe-nat-gateways \
    --query "NatGateways[*].[NatGatewayId,State]" \
    --output table

echo ""
echo "-----------------------------------------"
echo "VPC Endpoints"
echo "-----------------------------------------"
aws ec2 describe-vpc-endpoints \
    --query "VpcEndpoints[*].[VpcEndpointId,ServiceName,State]" \
    --output table

echo ""
echo "-----------------------------------------"
echo "VPC Peering Connections"
echo "-----------------------------------------"
aws ec2 describe-vpc-peering-connections \
    --query "VpcPeeringConnections[*].[VpcPeeringConnectionId,Status.Code]" \
    --output table

echo ""
echo "-----------------------------------------"
echo "EC2 Instances"
echo "-----------------------------------------"
aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress,PublicIpAddress]" \
    --output table

echo ""
echo "-----------------------------------------"
echo "VPC Flow Logs"
echo "-----------------------------------------"
aws ec2 describe-flow-logs \
    --query "FlowLogs[*].[FlowLogId,ResourceId,FlowLogStatus]" \
    --output table

echo ""
echo "Discovery Complete."
