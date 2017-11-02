var config = {};

config.lwm2m = {
    logLevel: 'DEBUG',
    port: 5684,
    defaultType: 'Device',
    ipProtocol: 'udp4',
    serverProtocol: 'udp4',
    formats: [
        {
            name: 'application-vnd-oma-lwm2m/text',
            value: 1541
        },
        {
            name: 'application-vnd-oma-lwm2m/tlv',
            value: 1542
        },
        {
            name: 'application-vnd-oma-lwm2m/json',
            value: 1543
        },
        {
            name: 'application-vnd-oma-lwm2m/opaque',
            value: 1544
        }
    ],
    writeFormat: 'application-vnd-oma-lwm2m/text',
    types: [ 
        {
            name: 'Robot',
            url: '/robots'
        }
    ]
};

config.ngsi = {
    logLevel: 'DEBUG',
    contextBroker: {
        host: 'orion',
        port: '1026'
    },
    server: {
        port: 4041
    },
    deviceRegistry: {
        type: 'memory'
    },
    types: { 
        'Robot': {
            service: 'Factory',
            subservice: '/robots',
            commands: [
              {
                "name": "Position",
                "type": "location"
              }            
            ],
            lazy: [
              {
                "name": "Message",
                "type": "string"
              }            
            ],
            active: [
              {
                "name": "Battery",
                "type": "number"
              }
            ],
            lwm2mResourceMapping: {
              "Battery" : {
                "objectType": 7392,
                "objectInstance": 0,
                "objectResource": 1
              },
              "Message" : {
                "objectType": 7392,
                "objectInstance": 0,
                "objectResource": 2
              },
              "Position" : {
                "objectType": 7392,
                "objectInstance": 0,
                "objectResource": 3
              }
            }
        }
    },
    service: 'smartGondor',
    subservice: '/gardens',
    providerUrl: 'http://iotagent:4041',
    deviceRegistrationDuration: 'P1M'
};

module.exports = config;
