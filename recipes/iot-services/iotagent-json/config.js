var config = {};

config.mqtt = {
    host: 'mosquitto',
    port: 1883,
    thinkingThingsPlugin: true
};

config.iota = {
    logLevel: 'DEBUG',
    timestamp: true,
    contextBroker: {
        host: 'orion',
        port: '1026'
    },
    server: {
        port: 4041
    },
    deviceRegistry: {
        type: 'mongodb'
    },
    mongodb: {
        host: 'mongo',
        port: '27017',
        db: 'iotagentjson'
    },
    types: {},
    service: 'howtoService',
    subservice: '/howto',
    providerUrl: 'http://iotagent:4041',
    deviceRegistrationDuration: 'P1M',
    defaultKey: '1234', 
    defaultType: 'Thing'
};

module.exports = config;
