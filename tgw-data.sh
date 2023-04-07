#!/bin/bash

# AWS CLI commands to capture TGW, attachments, route table, and routes information
tgw_info=$(aws ec2 describe-transit-gateways --query "TransitGateways[*].{TGName: TransitGatewayId, TGState: State}" --output table)
tgw_attachments=$(aws ec2 describe-transit-gateway-attachments --query "TransitGatewayAttachments[*].{AttachmentID: TransitGatewayAttachmentId, VPCID: VpcId, TGWID: TransitGatewayId}" --output table)
tgw_route_table=$(aws ec2 describe-transit-gateway-route-tables --query "TransitGatewayRouteTables[*].{RouteTableID: TransitGatewayRouteTableId, TGWID: TransitGatewayId}" --output table)

# function to capture TGW routes information
function get_tgw_routes {
  routes=$(aws ec2 search-transit-gateway-routes --transit-gateway-route-table-id $1 --query "Routes[*].{CIDR: DestinationCidrBlock, AttachmentID: TransitGatewayAttachment.TransitGatewayAttachmentId, Type: Type}" --output table)
  echo "$routes"
}

# loop through all TGW route tables and capture routes information
for rt in $(aws ec2 describe-transit-gateway-route-tables --query "TransitGatewayRouteTables[*].TransitGatewayRouteTableId" --output text); do
  echo "Routes for Route Table: $rt"
  get_tgw_routes $rt
  echo "--------------------------------------"
done

# output captured information
echo "Transit Gateway Information:"
echo "$tgw_info"
echo "--------------------------------------"
echo "Transit Gateway Attachments:"
echo "$tgw_attachments"
echo "--------------------------------------"
echo "Transit Gateway Route Tables:"
echo "$tgw_route_table"
echo "--------------------------------------"
