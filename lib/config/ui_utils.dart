
import 'package:flutter/cupertino.dart';
import 'device_screen_type.dart';

  /// Gets the different types of devices depending on the screen size
  DeviceScreenType getDeviceType(MediaQueryData mediaQuery) {

    var orientation = mediaQuery.orientation;

    double deviceWidth = 0;
    if(orientation == Orientation.landscape){
      deviceWidth = mediaQuery.size.height;
    }
    else{
      deviceWidth = mediaQuery.size.width;
    }

    if(deviceWidth >= 1100){
      return DeviceScreenType.Desktop;
    }
    else if(deviceWidth >= 800){
      return DeviceScreenType.Tablet;
    }
    else{
      return DeviceScreenType.Mobile;
    }
  }

