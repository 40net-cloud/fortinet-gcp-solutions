
def generate_config(context):
    """ Entry point for the deployment resources. """

    resources = []
    properties = context.properties
    hubVpcName = properties['hubVpcName']
    spokeVpcName = properties['spokeVpcName']

    hubVpcNameFull = context.env['deployment'] + '-' + hubVpcName
    spokeVpcNameFull = context.env['deployment'] + '-' + spokeVpcName

    peer_up = {
        'name': 'VPC Peering from ' + spokeVpcName,
        'action': 'gcp-types/compute-v1:compute.networks.addPeering',
        'metadata': {
            'runtimePolicy': ['CREATE',
                             ]
        },
        'properties':
            {
                'name': 'peering-' + spokeVpcName + '-to-' + hubVpcName,
                'network': spokeVpcNameFull,
                'peerNetwork': 'projects/' + context.env['project'] + '/global/networks/' + hubVpcNameFull,
                'importCustomRoutes': True,
                'autoCreateRoutes': True,
                'exchangeSubnetRoutes': True
            }
    }

    resources.append(peer_up)

    return {'resources': resources}
