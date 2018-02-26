# Security Management

Within FIWARE security is by different services that provide the following 
functionalities:

* Identity Management (IDM): the reference implementation is currently
    [KeyRock](http://fiware-idm.readthedocs.io/en/latest/index.html)
* Policy Decision Point PDP service: the reference implementation is currently
    [authzforce](http://authzforce-ce-fiware.readthedocs.io/en/latest/)
* Policy Enforcement Point (PEP): the reference implementation is currently
    [Wilma](http://fiware-pep-proxy.readthedocs.io/en/latest/), but is
    going to be replaced soon by an extension of
    [API Umbrella](https://apiumbrella.io).

All the above elements combined together provide you with an AAA solution for
FIWARE APIs.

In the recipes, at the time being, we cover only the ongoing implementation
of the PEP Proxy based on API Umbrella. This is due to the fact that:

* KeyRock is undergoing strong developments and new release will be announced
    soon, and the current FIWARE Lab IDM can be used for any project without
    need to deploy your own instance.
* PDP is required only in complex scenarios, and the PDP available n FIWARE Lab
    can be used for any project without need to deploy your own instance.
