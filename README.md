# House

A home automation platform written entirely in Swift. The House platform is made of two parts:

* Hub
* Extensions

House Extensions act as units that can feed information to, or opt in to be controlled by, the House Hub. For example; lights, sensors, switches.

The House Hub acts as a central unit to automate tasks at pre-defined times or in response to events from House Extensions.

The House Hub and House Extensions commuincate over an agreed messaging protocol to exchange information. 

The current repository is the House Core - a codebase that the Hub and Extension share. There are no runnable binaries to compile here.