var config = {};

config.mqtt = {
    host: process.env.IOTA_MQTT_HOST || 'mosquitto',
    port: process.env.IOTA_MQTT_PORT || 1883
};

config.http = {
    port: process.env.IOTA_HTTP_PORT || 7896
};

config.iota = {
    logLevel: process.env.IOTA_LOG_LEVEL || 'DEBUG',
    timestamp: process.env.IOTA_TIMESTAMP || true,
    contextBroker: {
        host: process.env.IOTA_CB_HOST || 'orion',
        port: process.env.IOTA_CB_PORT ||'1026'
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
    types: {},
    service: 'howtoService',
    subservice: '/howto',
    providerUrl: process.env.IOTA_PROVIDER_URL || 'http://iotagent:4041',
    deviceRegistrationDuration: 'P1M',
    defaultType: 'Thing'
};

config.defaultKey = 'TEF';
module.exports = config;
