# The Secret Keeper featuring Canary Tokens
Secret Keeper is a demo iOS application as an example of integration of Canary Tokens with a mobile application. Secret Keeper is the product of rapid development(very rapid) and hence it is a beta. It serves to show that Canary Tokens can be added and used effectively with mobile applications. This application accepts a [Canary Token](www.canarytokens.com) from the website, detects the token onTouch and adds the token to the application. Everytime the App is opened, the token is triggered (this trigger has some quirks).

## Please Note:
This is a demo. It is not for production. On initial startup, the first password you enter will be your password from then on. There are example 'Secrets' added. 

## Features 
1. Realm Database stores 'Secrets' for the user (this database is encrypted)
2. App picks up a Secret Keeper Canary Token link and adds it to the App.
3. Everytime App is opened the Canary Token is triggered and supplemented with the device location.
4. Everytime there is a failed login, the Canary Token is triggered and a face snapshot is taken of the culprit (so smile). 

## Thanks
[CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) - Really cool crypto library that I used for some of the encryption. Thank you!
[Realm](https://realm.io/) - Realm database is so easy to use. Made our lives so much easier. Thanks!