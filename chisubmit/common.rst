.. _chisubmit_common:

Initial setup
=============

The following are a number of steps you need to perform on any machine where you run chisubmit. They
only need to be run once. To perform these steps, you will need the hostname of your course's
chisubmit server, which we will refer to as ``CHISUBMIT_HOST``.

Getting your chisubmit credentials
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First of all, you need to obtain a set of chisubmit credentials that will allow you to use the 
chisubmit commands without having to use your university credentials every time you run chisubmit.
Just run the following::

    chisubmit-get-credentials --url https://CHISUBMIT_HOST/api/v0/
    
This command will ask for your "chisubmit username" and "chisubmit password". Unless instructed otherwise
by an instructor or chisubmit administrator, 
these will just be your university username and password. These are transmitted
securely over HTTPS to the chisubmit server, which will return a set of credentials (unrelated to
your university credentials, and valid only for chisubmit) which are stored locally in your computer
(specifically, in file ``~/.chisubmit/chisubmit.conf``).

If you rerun the above command in other computers, you will always get the same set of chisubmit
credentials. If you are concerned that your credentials have become compromised, you can reset your
chisubmit credentials like this::

    chisubmit-get-credentials --url https://CHISUBMIT_HOST/api/v0/ --reset

If you do this, you will need to rerun the original command (without ``--reset``) in all the machines
where you are running chisubmit, to ensure you are using the correct credentials.

Setting your default course
~~~~~~~~~~~~~~~~~~~~~~~~~~~

When running a chisubmit command, chisubmit needs to know what course that command
applies to. You can specify a default course like this::

    chisubmit student course set-default COURSE_ID
    
Where ``COURSE_ID`` should be substituted by the course identifier provided by your instructor or chisubmit administrator. 

You can verify that your chisubmit credentials and default course are properly set up by
running this::

   chisubmit student assignment list
   
This will list the upcoming assignments in the course (if no assignments have been set up in the course,
then the command will return immediately without any errors).

If you are registered for multiple classes that use chisubmit, you can change the default
course as many times as you want, but you can also use the ``--course`` option to specify
a course just for an individual command. For example::

   chisubmit --course COURSE_ID student assignment list

Getting your git credentials
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chisubmit needs to access your course's git server to perform a number of actions,
such as verifying that submissions have been performed
correctly. To do so, it needs access to your git account. You will use a chisubmit command
to log into your git account, and authorize chisubmit to use your git account.

If your course is set up to use a GitLab server, you just need to run the following command::

   chisubmit student course get-git-credentials
   
This command will ask for your "git username" and "git password". Unless instructed otherwise
by an instructor or chisubmit administrator, these will just be your university username and password.  

If your course is set up to use GitHub, you first need to run the following command, where
``GITHUB_USERNAME`` is your GitHub username::

    chisubmit student course set-git-username GITHUB_USERNAME
    
Since your university username may not be the same as your GitHub username, the above command
tells chisubmit what GitHub account to access. Once you've run this command, just run this::
   
   chisubmit student course get-git-credentials

This command will ask for your "git username" and "git password". You will need to enter your
GitHub username and password.

