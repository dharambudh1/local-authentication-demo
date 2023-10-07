# Local Authentication Demo

## Description:
This project is a sample that demonstrates how users can be authenticated locally, directly on their devices. If your device supports it, you can use your fingerprint or face to prove your identity.

  - Here's what this project can do:
    - `canCheckBiometrics`: Tells you if your device can use biometrics like fingerprints or face recognition.
    - `isDeviceSupported`: Checks if your device can use biometrics or if it can use another method to confirm your identity if needed.
    - `canAuthenticate`: Gives you a "true" if either `canCheckBiometrics` is "true" or `isDeviceSupported` is "true."
    - `getAvailableBiometrics`: Shows you a list of the biometric data that's saved on your device.
    - `hasAvailableBiometric`: Tells you if there's any biometric data saved on your device, giving you a "true" or "false."
    - `authenticate`: Confirms if you were able to prove your identity successfully, showing "true" if you did and "false" if you didn't.

## Preview
![alt text](https://i.postimg.cc/tgMNTCnF/imgonline-com-ua-twotoone-Cf7-Hq-L1m-ILZM5b-B.png "img")
