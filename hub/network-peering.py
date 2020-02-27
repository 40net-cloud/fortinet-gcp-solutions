
def generate_config(context):
    """ Entry point for the deployment resources. """

    resources = []
    properties = context.properties
    hubVpcName = properties['hubVpcName']
    spokeVpcName = properties['spokeVpcName']

    hubVpcNameFull = context.env['deployment'] + '-' + hubVpcName
    spokeVpcNameFull = context.env['deployment'] + '-' + spokeVpcName

    peer_up = {
        'name': 'create-peering-from-' + spokeVpcName,
        'action': 'gcp-types/compute-v1:compute.networks.addPeering',
        'metadata': {
            'runtimePolicy': ['CREATE',
                             ]
        },
        'properties':
            {
                'name': 'peering-' + spokeVpcName + '-' + hubVpcName,
                'network': spokeVpcNameFull,
                'peerNetwork': 'projects/' + context.env['project'] + '/global/networks/' + hubVpcNameFull,
                'importCustomRoutes': True,
                'autoCreateRoutes': True,
                'exchangeSubnetRoutes': True
            }
    }

    peer_down = {
        'name': 'create-peering-to-' + spokeVpcName,
        'action': 'gcp-types/compute-v1:compute.networks.addPeering',
        'metadata': {
            'runtimePolicy': ['CREATE',
                             ]
        },
        'properties':
            {
                'name': 'peering-'+ hubVpcName + '-' + spokeVpcName,
                'network': hubVpcNameFull,
                'peerNetwork': 'projects/' + context.env['project'] + '/global/networks/' + spokeVpcNameFull,
                'exportCustomRoutes': True,
                'autoCreateRoutes': True,
                'exchangeSubnetRoutes': True
            },
        'metadata': {
            'dependsOn': [
                'create-peering-from-' + spokeVpcName
            ]
        }
    }

    resources.append(peer_up)
    resources.append(peer_down)

    return {'resources': resources}
