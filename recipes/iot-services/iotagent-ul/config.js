var config = {};

config.mqtt = {
    host: 'mosquitto',
    port: 1883
};

config.http = {
    port: 7896
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
        db: 'iotagentul'
    },
    types: {},
    service: 'howtoService',
    subservice: '/howto',
    providerUrl: 'http://iotagent:4041',
    deviceRegistrationDuration: 'P1M',
    defaultType: 'Thing'
};

config.defaultKey = 'TEF';
module.exports = config;