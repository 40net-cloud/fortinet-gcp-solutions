
def generate_config(context):
    """ Entry point for the deployment resources. """

    resources = []
    properties = context.properties
    hubVpcName = properties['hubVpcName']
    spokeVpcName = properties['spokeVpcName']

    hubVpcNameFull = context.env['deployment'] + '-' + hubVpcName
    spokeVpcNameFull = context.env['deployment'] + '-' + spokeVpcName

    peer_down = {
        'name': 'VPC Peering to ' + spokeVpcName,
        'action': 'gcp-types/compute-v1:compute.networks.addPeering',
        'metadata': {
            'runtimePolicy': ['CREATE',
                             ]
        },
        'properties':
            {
                'name': 'peering-'+ hubVpcName + '-to-' + spokeVpcName,
                'network': hubVpcNameFull,
                'peerNetwork': 'projects/' + context.env['project'] + '/global/networks/' + spokeVpcNameFull,
                'exportCustomRoutes': True,
                'autoCreateRoutes': True,
                'exchangeSubnetRoutes': True
            }
    }

    resources.append(peer_down)

    return {'resources': resources}
