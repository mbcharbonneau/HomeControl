# MonsterPit
Welcome to the Monster Pit!

Monster Pit is home automation app for iOS, built in Swift. You probably won't have much luck simply forking this project for your own use. There's a lot going on, and it's all built for my own custom hardware and room layout!

![Screenshot](http://mbcharbonneau.com/files/MonsterPit.png)

I'm working on documenting this project in a series of blog posts, and this repo will be provided as a jumping off point for anyone interested in starting their own app. In the meantime, you can contact me [@mbcharbonneau](https://twitter.com/mbcharbonneau) on Twitter.

## Services

[Parse](http://parse.com) is the data backend and push notification service that lets the app talk to hardware via the Internet.

[IFTTT](http://ifttt.com) provides a maker channel for controlling home automation hardware through an HTTP call.

## Hardware

[Arduino Yún](https://www.arduino.cc/en/Products/ArduinoYUN) is the house's main controller. It gathers data from several hardware devices on the local network, and sends it up to Parse.

[iBeacons](http://redbearlab.com/ibeacon/) provide highly specific indoor positioning. For instance, knowing when you set your phone on the nightstand when it's time for bed.

[Belkin WeMo](http://www.belkin.com/us/Products/home-automation/c/wemo-home-automation/) devices allow the app to control lights and appliances.

## Building

You'll have to provide a few constants and API keys before you can compile. Here's the format you'll need:

```
struct Configuration {
    struct Parse {
        static let AppID = "";
        static let ClientKey = "";
    }

    struct IFTTT {
        static let ClientKey = "";
    }

    struct MonsterPit {
        static let Location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        static let BeaconUUID = ""
    }
}
```

... but even then you won't see anything unless you already have data in Parse. Take a look at `RoomSensor.swift` and `SwitchedDevice.swift` for more info.
