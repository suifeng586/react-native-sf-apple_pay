# react-native-sf-apple-pay


# 苹果内计费支付




# 安装
npm install react-native-sf-apple-pay


# Methods
|  Methods  |  Params  |  Param Types  |   description  |  Example  |
|:-----|:-----|:-----|:-----|:-----|
|iapPay|productId|string|内计费支付||


# 例子
```

import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
    Dimensions,
    TouchableOpacity
} from 'react-native';

import SFDrawer from "react-native-sf-drawer"
var dw = Dimensions.get('window').width;
var dh = Dimensions.get('window').height;
export default class App extends Component {
  click = () => {
    this.refs.drawer.show()

  }
  render() {
    return (
      <View style={styles.container}>
        <TouchableOpacity onPress={this.click}>
          <View style={{
            width:dw,
            height:150,
            backgroundColor:'red'
          }}></View>
        </TouchableOpacity>

        <SFDrawer
            ref="drawer"

          drawerDirection={'left'}
        >
          <View style={{
            height:dh,
            backgroundColor:'green'
          }}></View>
        </SFDrawer>
      </View>
    );
  }
}

```