var config = {};

config.lwm2m = {
    logLevel: process.env.IOTA_LOG_LEVEL || 'DEBUG',
    port: process.env.IOTA_LWM2M_PORT || 5684,
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
    logLevel: process.env.IOTA_LOG_LEVEL || 'DEBUG',
    contextBroker: {
        host: process.env.IOTA_CB_HOST || 'orion',
        port: process.env.IOTA_CB_PORT || '1026'
    },
    server: {
        port: process.env.IOTA_NORTH_PORT || 4041
    },
    deviceRegistry: {
        type: process.env.IOTA_REGISTRY_TYPE || 'mongodb'
    },
    mongodb: {
        host: process.env.IOTA_MONGO_HOST || 'mongo',
        port: process.env.IOTA_MONGO_PORT || '27017',
        db: process.env.IOTA_MONGO_DB || 'iotagentjson',
        replicaSet: process.env.IOTA_MONGO_REPLICASET || 'rs'
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
    providerUrl: process.env.IOTA_PROVIDER_URL || 'http://iotagent:4041',
        deviceRegistrationDuration: 'P1M'
};

module.exports = config;
