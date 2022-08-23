# MrPowerManager [App]

Remotely manage your pc

<div align="center">
<img alt="Logo" height="200" src="assets/images/logo3.png" width="200" />
<div align="left">

# **MrPowerManager App**
App frontend of MrPowerManager's project. It uses the amazing [Flutter framework](https://flutter.dev/)!

The app is a **toolkit**, it gives the user a lot of possibility to remotely control its PCs. 

---

## 💻 Backend💻
### *Backend API*

>Remote access to this rest API (***now deployed***):
>
> *https://mrpowermanager.herokuapp.com/*
----------------------------------------------------------------------------------------------------------------------------------------
<a name="client"></a>
### *Pc frontend (server)*

>You can find here the server frontend made for this project (***Windows application***):
>
> *https://github.com/MrPio/MrPowerManagerServer*
----------------------------------------------------------------------------------------------------------------------------------------



## **Main Screen, the common commands**

In the first screen the user is presented with the most basic command, like manage pc **sound value**, the **screen brightness**, **suspend/lock/shut down** pc, and so on... 

There also are advanced command like a **share the clipboard** functionality. You can set the pc to automatically store each **screenshot** you take inside the gallery of your phone!

<img alt="API" height="560" src="https://user-images.githubusercontent.com/22773005/185809248-a49242a2-eea8-40c8-98c7-281abb8cbc8d.png"/>    
<img alt="API" height="560" src="https://user-images.githubusercontent.com/22773005/185809253-0e7d5df2-b904-4211-ba53-af8bdad0eac2.png"/>    

---

## **TaskManager Screen**

Task Manager screen shows pc's currently open apps, with their logo. The user can bring then to top, or kill them.

<img alt="API" height="560" src="https://user-images.githubusercontent.com/22773005/185809374-48501ca7-03c7-49a6-b02d-f4d943a8808f.png"/>    


---

## **LiveCharts Screen**

Here you can find the value of your pc like CPU, GPU, RAM usage, but also TEMP.

## Not only this, but this screen provide you realtime **WATTAGE COMPSUMPTION**. 

An estimation made possible by inference made upon a lot of collected data with different machines. This is a crucial point of this project, beacuse there aren't so many projects on this theme out there.

User can use this info **(WattHour values)** to calculate how much does his pc cost in terms of electricity.

<img alt="API" height="480" src="https://user-images.githubusercontent.com/22773005/185809609-80c98af1-3d59-4fe4-8550-f3f00ed5b0c8.png"/>    
<img alt="API" height="480" src="https://user-images.githubusercontent.com/22773005/185809610-da9c1a08-e0bb-402e-ba20-1c5408e9df71.png"/>    
<img alt="API" height="480" src="https://user-images.githubusercontent.com/22773005/185809611-f4a567f2-7d88-4302-bdd9-cb44e9ed2cb6.png"/>    
<img alt="API" height="480" src="https://user-images.githubusercontent.com/22773005/185809612-fab2b24b-a34f-4f4b-a8c9-1af54192c187.png"/>    

---

## **Login/Password Screen**

In this screen the user can securely store its password and logins.

In a nutshell the cellphone store the key, while the pc hold the encrypted password. This mecanism uses [Fernet symmetric encryption](https://cryptography.io/en/latest/fernet/)

**Here comes the best part**
The user can register its logins (url, username, passeord) and once this is done, a new button permanently appear and 
### gives the user the possibility to **automate the login process**, once the button is pressed the pc immediately goes to that page, paste the credentials and press enter. This operation takes barely 2 seconds!

---

<img alt="API" height="560" src="https://user-images.githubusercontent.com/22773005/185810067-9ba4565e-b4ee-4412-8c7c-c7f4b6e62249.jpg"/>   
<img alt="API" height="560" src="https://user-images.githubusercontent.com/22773005/185810118-2ba09468-1867-40ab-9b04-83c471bf096d.png"/>

## **AdvancedRemoteControl Screen**

### In This Screen the user can control the pc WEBCAM, the pc KEYBOARD and its SCREEN

<img alt="API" height="480" src="https://user-images.githubusercontent.com/22773005/185810215-ab5b579e-07a5-4e1d-b0d2-b1ff50648e42.png"/> 
<img alt="API" height="480" src="https://user-images.githubusercontent.com/22773005/185810216-8b1ae3a8-496b-45f9-9f4c-35c0314ad3bc.png"/> 
<img alt="API" height="480" src="https://user-images.githubusercontent.com/22773005/185810217-948ccc67-e260-46d1-a491-e0d64cf7c3d2.png"/> 
<img alt="API" height="480" src="https://user-images.githubusercontent.com/22773005/185810219-d8170728-41b2-4adc-9b52-0cce1a3140b7.png"/> 

<img alt="API" height="380" src="https://user-images.githubusercontent.com/22773005/185810223-a105b8a7-77fd-4309-a0be-4671cd0f5b21.jpg"/> 
<img alt="API" height="380" src="https://user-images.githubusercontent.com/22773005/185810227-b68ad2f2-55a5-4a6a-977f-7dad2309ec8b.jpg"/> 
<img alt="API" height="380" src="https://user-images.githubusercontent.com/22773005/185810224-9e739117-4acd-4c9d-9f0f-4690faf494b8.jpg"/> 
<img alt="API" height="380" src="https://user-images.githubusercontent.com/22773005/185810225-4f61e87c-5bb7-4263-a1e2-6b2472d31016.jpg"/> 

