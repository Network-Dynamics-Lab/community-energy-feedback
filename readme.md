## open-urban-energy-data-feedback-system
This repository documents the source code for a mobile application visualizing building energy data across communities and cities. The application was developed as a result of research efforts in the [Network Dynamics Lab](http://ndl.gatech.edu/) at Georgia Tech, and is associated with the following publications: [Designing community-scale energy feedback](https://www.sciencedirect.com/science/article/pii/S1876610219308525).

The application consists of three major functionalities:

- Spatial: as users walk through community, augmented reality icons pop-up and display building energy intensity.

<img src="gifs/AR_5.gif" width="40%"> 

- Energy Supply: graphic interface allowing user to compare individual building energy production to the entire campus.

<img src="gifs/supply.gif" width="40%"> 
 
- Energy Use: graphical interface allowing user to compare individual building energy use trends to the entire campus trends.

<img src="gifs/consumption.gif" width="40%">

<!--
![](https://github.gatech.edu/afrancisco8/open-urban-energy-data-feedback-system/blob/master/gifs/AR_5.gif) ![](https://github.gatech.edu/afrancisco8/open-urban-energy-data-feedback-system/blob/master/gifs/supply.gif) ![](https://github.gatech.edu/afrancisco8/open-urban-energy-data-feedback-system/blob/master/gifs/consumption.gif)
-->

## Related Publications
- Francisco, A., & Taylor, J. E. (2019). Designing community-scale energy feedback. Energy Procedia, 158, 4178-4183.

## Device Requirements
- Supports the following devices: iPhone 6S and upwards, iPhone SE, iPad (2017), All iPad Pro models
- Mapbox API key
- Firebase API key

## Data Requirements


## Usage


### Setting up using CocoaPods
1. Add to your podfile:

`pod 'ARCL'`

2. In Terminal, navigate to your project folder, then:

`pod update`

`pod install`

3. Add `NSCameraUsageDescription` and `NSLocationWhenInUseUsageDescription` to plist with a brief explanation (see demo project for an example)

### Setting up manually
1. Add all files from the `ARKit+CoreLocation/Source` directory to your project.
2. Import ARKit, SceneKit, CoreLocation and MapKit.
3. Add `NSCameraUsageDescription` and `NSLocationWhenInUseUsageDescription` to plist with a brief explanation (see demo project for an example)

### Issues
I mentioned this was experimental - currently, ARKit occasionally gets confused as the user is walking through a scene, and may change their position inaccurately. This issue also seems to affect the “euler angles”, or directional information about the device, so after a short distance it may think you’re walking in a different direction.

While Apple can improve ARKit over time, I think there are improvements we can make to avoid those issues, such as recognising when it happens and working to correct it, and by comparing location data with our supposed location to determine if we’ve moved outside a possible bounds.

## Going Forward

We have some Milestones and Issues related to them - anyone is welcome to discuss and contribute to them. Pull requests are welcomed. You can discuss new features/enhancements/bugs either by adding a new Issue or via [the Slack community](https://join.slack.com/t/arcl-dev/shared_invite/enQtMjgzNTcxMDE1NTA0LTZjNDI0MjA3YmFhYjFiNGY4MWY5ZThhZGYzMzcyNTFjNzQzZGVlNmYwOGQ1Y2I5NmJmYTc2MTNjMTZhZTI5ZjU).

## Thanks
Library created by [@AndrewProjDent](https://twitter.com/andrewprojdent), but a community effort from here on.

Available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
