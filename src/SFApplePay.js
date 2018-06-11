/**
 * Created by SF on 2018/4/8.
 */

import React, {Component} from 'react';
import {
    NativeModules,
    NativeEventEmitter,
    NativeAppEventEmitter,
    Platform
} from 'react-native';

const _IAP = NativeModules.SFIAPBridge;
const SFApplePay = {

    iapPay:function (productId,callBack) {
        _IAP.pay(productId,(err,msg)=>{
            if (callBack){
                callBack(err,msg);
            }
        })
    }
};
module.exports = SFApplePay;
