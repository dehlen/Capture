# Capture
<p align="center">
   <img width="256" height="256" src="./icon.png">
</p>

Capture is a native macOS application to record your screen. What makes this application special is, that you can choose from a list of currently open windows and Capture will automatically set the recorded frame to the window frame. The application also works for multiple displays and gives you a handful of useful features concerning the export, quality of the recorded video and more. By default Capture will export to GIF. 

I wrote this application because at my workplace we often attach a GIF to a Pull Request in order to present a completed feature to the reviewers.

## Caveats
- Currently only GIF export is allowed
- Stopping a recording is not possible via a menu item
- There is no way to specify audio sources
- You can only select an open window. The selected recording frame is not resizable.

## Dependencies

| Dependency    | Are           |
| ------------- |:-------------:|
| Clipy/KeyHolder, Clipy/Magnet | Used to record shortcuts. |
| matthewpalmer/Regift     | Used to export a video as GIF. |
| mxcl/PromiseKit, PromiseKit/Foundation | Dependencies of AppUpdater which is currently not Carthage compatible. AppUpdater is used to provide automatic app updates. |
| dehlen/AboutWindowController | Not really a dependency since I own this one. AboutWindowController is used to show a nice Xcode-like About window. |

## Releasing
1. Update version in Xcode project
2. Tag new version in git repository
3. Create new GitHub release
4. Append signed .app to created release

## Support
If you find a bug or have an idea for an enhancement don't hesitate to file an issue. I am very grateful for every contribution you can make to improve Capture. Please note that this application is at the moment free to use and fully open-source.

## Installation
Please go to https://captureapp.dev and download the latest version or simply go to the releases tab and download the version you want. If you have macOS Developer account you can also build the application from source of course.

## Build


## Alternatives
- QuickTime
- [Kap](https://getkap.co)
