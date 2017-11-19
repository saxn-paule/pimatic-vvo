This plugin provides information about bus, tram, etc. departures for VVO vehicles. Visit https://www.vvo-online.de/de select your stop and get the stopid from the URL.

# Configuration
There are three configuration parameters
* stopid - The stopid for your stop
* amount - How many departures should be displayed
* offset - How far in the future should the first departure lie?

### Sample Device Config:
```javascript
    {
      "id": "departures",
      "name": "Departures",
      "class": "VvoDevice",
      "stopid": "33000335",
      "amount": "10",
      "offset": "8"
    },
```

# Beware
This plugin is in an early alpha stadium and you use it on your own risk.
I'm not responsible for any possible damages that occur on your health, hard- or software.

# License
MIT
