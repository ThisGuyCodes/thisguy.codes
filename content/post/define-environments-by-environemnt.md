---
categories:
- development
date: 2015-07-28T02:36:12-07:00
draft: true
tags:
- development
title: define environments by environemnt
---

I'm currently in the throes of redefining our entire production setup (along
with everyone else on the DevOps team), and along the way I've started to
develop an idea about how to manage environement-dependant settings in
applicatons.

#### In short, don't.

To be less dramatic: don't manage environment-dependant changes *in the
application*. Instead, have that handled by the environment.

Perhaps now would be a good time to clarify the two different definitions of
"environment" I'm using here:

* An application's locations in the development pipeline (dev, test, stage,
prod, etc).
* The world around you (or around an application).

In reference to this posts title, I'm suggesting you define the former via the
latter.
