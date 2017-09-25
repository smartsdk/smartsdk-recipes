URL=$1

curl $URL -v -s -S --header 'Content-Type: application/json; charset=utf-8' --header 'Accept: application/json' --header "Fiware-Service: default" --header "Fiware-ServicePath: /" -d @- <<EOF
{
    "subscriptionId" : "51c0ac9ed714fb3b37d7d5a8",
    "originator" : "localhost",
    "contextResponses" : [
        {
            "contextElement" : {
                "attributes" : [
                    {
                        "name" : "temperature",
                        "type" : "float",
                        "value" : "26.5"
                    }
                ],
                "type" : "Room",
                "isPattern" : "false",
                "id" : "Room1"
            },
            "statusCode" : {
                "code" : "200",
                "reasonPhrase" : "OK"
            }
        }
    ]
}
EOF
