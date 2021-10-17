## Kazarma 

A Matrix bridge to ActivityPub.

## Quickstart 

A basic module service config would look like this:

```nix
services.kazarma = {
    enable = true;
    matrixUrl = http://synapse:8008;
    activityPubDomain =  ;
    homeserverToken = ;
    accessToken = ;
    database.createLocally = true;
};


```