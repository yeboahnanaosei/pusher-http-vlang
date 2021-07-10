# Pusher Channels V client
[![V logo](./v_logo.png)](https://vlang.io) | [![Pusher Logo](./pusher_logo.svg)](https://pusher.com)
:---: | :---:

V module for interacting with the Pusher Channels HTTP API   
Pusher is a service that lets you build realtime features into your application.  
Read about pusher here: [Pusher.com](https://pusher.com)

### ⚠️ WARNING:  
This is a very early stage implementation. It is more of a proof-of-concept.  
**However, the goal is to build a full featured client for V.**  

At the moment a lot of things are not correct:
* Code duplication everywhere
* No error handling
* Possibly inefficient code
* etc...

### GOALS:
* Completely satisfy the specification: [Pusher Server Library Specification](https://pusher.com/docs/channels/library_auth_reference/server-library-reference-specification/)
* Strive to become an "officially-supported" library.  
  
    > The library MUST offer the following features to be considered feature-complete and be  open for consideration as an “officially-supported” Channels server library by Pusher.

### CONTRIBUTING:
You are welcome to contribute.  

The only thing I ask is to try and write your commit messages like explained in this article: [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/) 