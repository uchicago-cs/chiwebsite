Introduction
============

In this project, you will implement a simple Internet Relay Chat (IRC)
server called :math:`\chi` . This project has three goals:

#. To provide a refresher of socket and concurrent programming covered
   in CMSC 15400.

#. To implement a system that is (partially) compliant with an
   established network protocol specification.

#. To allow you to become comfortable with high-level networking
   concepts before we move on to the lower-level concepts in this
   course.

This project is divided into three parts. The first part is meant as a
relatively short warmup exercise, and you should be able to do it just
by applying what you learned about network sockets in CMSC 15400. The
other two parts are more complex, but should still be doable if you’ve
taken CMSC 15400 (we will, nonetheless, be providing a review of sockets
and concurrent programming in the first two discussion sessions of CMSC
23300).

This document is divided into three parts: Sections [sec:irc] through
[sec:examples] provide an overview of IRC and provide several examples
of valid IRC communications; Sections [sec:code] and [sec:build]
describe how to get the :math:`\chi` code and how to build it; finally,
Sections [sec:grading] to [sec:proj1c] describe how the project will be
graded, and the specific requirements of the three parts the project is
divided into.

