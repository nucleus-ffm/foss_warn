
!!! Version note
    This feature has been available since version 1.1.0 and is still experimental.


FOSSWarn can track your current location to inform you about alerts at your current location. This works by periodically waking up FOSSWarn, accessing your current location, and if a new location is detected, subscribing to this location. FOSSWarn will attempt to update your location every 1.5h.

To use this feature, go into `settings` and enable `Receive alerts for your current location`. This will prompt you in multiple dialogs for the correct permissions to access your location. Following the dialog and granting the right permissions will eventually enable the feature. 

In the `My places` overview, you will see a new entry named `current location` as soon as FOSSWarn detects your location and subscribes to it. You can press on the icon on the left of the entry to see the details for this place, which also shows the subscribed area. 


Using this feature requires permanently enabling location access on your device. FOSSWarn will only use your location to subscribe to your current location, and this information will be stored on the server as long as the subscription is valid. The server will not store or use this information for anything else. For more information regarding your data privacy, please consult the privacy declaration of the FOSS Public Alert Server you use. 

The subscription for your current location is separate from your other manually subscribed places. If in your manually subscribed places are the same areas as in the current location area, you might receive alerts twice. This might improve in future updates. 