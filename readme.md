## community-energy-feedback
This repository documents the source code for a mobile application visualizing building energy data across communities and cities. The application was developed as a part of research efforts in the [Network Dynamics Lab](http://ndl.gatech.edu/) at Georgia Tech, and is associated with the following publications: 

- Francisco, A., & Taylor, J. E. (2019). Understanding citizen perspectives on open urban energy data through the development and testing of a community energy feedback system. Applied Energy, 256. [https://doi.org/10.1016/j.apenergy.2019.113804](https://www.sciencedirect.com/science/article/pii/S0306261919314916)
- Francisco, A., & Taylor, J. E. (2019). Designing community-scale energy feedback. Energy Procedia, 158, 4178-4183. [https://doi.org/10.1016/j.egypro.2019.01.812](https://www.sciencedirect.com/science/article/pii/S1876610219308525)

## Functionalities
The application consists of three major functionalities:

- Spatial: as users walk through community, augmented reality icons pop-up and display building energy intensity.

<img src="gifs/AR_5.gif" width="40%"> 

- Energy Supply: graphic interface allowing user to compare individual building energy production to the entire campus.

<img src="gifs/supply.gif" width="40%"> 
 
- Energy Use: graphical interface allowing user to compare individual building energy use trends to the entire campus trends.

<img src="gifs/consumption.gif" width="40%">

## Usage
### Compilation/Dependencies
The project is dependent on several Podfiles. The following should be added to the project podfile:

`pod ARCL`  
`pod Charts`  
`pod CocoaLumberjack`  

Next, update and install the podfile. The project should then compile and run in Xcode 11 using any device running iOS 13+. As the app requires camera and location usage, the project should be built on a device rather than a simulator. In order to run the application, open the project in Xcode, connect a device (registered with an Apple Developer Account) and choose the device in the selection menu in the top left, and hit Run.    

### Data Requirements



## Development
The project was written using Swift 4.0 and is organized as follows:
- Source folder
    + **ARViewController**
    + **SupplyViewController**
    + **ConsumptionViewController**
- Views folder
    + **Main.storyboard**
    + **Custom Views**
- Data folder

## Usage


## Thanks

