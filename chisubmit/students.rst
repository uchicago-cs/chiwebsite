.. _chisubmit_students:

For Students
============

This page contains instructions on how to use chisubmit specifically for students. These are generic
instructions, so some commands will use parameters like ``COURSE_ID`` or ``ASSIGNMENT_ID``, which
will be supplied by your instructor. 

Initial setup
-------------

The following are a number of steps you need to perform on any machine where you run chisubmit. They
only need to be run once. To perform these steps, you will need the hostname of your course's
chisubmit server. Your instructor will supply this information, and we will refer to
it as ``CHISUBMIT_HOST``.

Getting your chisubmit credentials
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First of all, you need to obtain a set of chisubmit credentials that will allow you to use the 
chisubmit commands without having to use your university credentials every time you run chisubmit.
Just run the following::

    chisubmit-get-credentials --url https://CHISUBMIT_HOST/api/v0/
    
This command will ask for your "chisubmit username" and "chisubmit password". Unless your instructor
tells you otherwise, these will just be your university username and password. These are transmitted
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
    
Where ``COURSE_ID`` should be substituted by the course identifier provided by your instructor.

You can verify that your chisubmit credentials and default course are properly set up by
running this::

   chisubmit student assignment list
   
This will list the upcoming assignments in the course (if your instructor hasn't set up any
assignments, then the command will return immediately without any errors).

If you are registered for multiple classes that use chisubmit, you can change the default
course as many times as you want, but you can also use the ``--course`` option to specify
a course. For example::

   chisubmit --course COURSE_ID student assignment list

Getting your git credentials
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chisubmit needs to access your git repository to verify that submissions have been performed
correctly. To do so, it needs access to your git account. You will use a chisubmit command
to log into your git account, and authorize chisubmit to use your git account.

If your course is set up to use a GitLab server, you just need to run the following command::

   chisubmit student course get-git-credentials
   
This command will ask for your "git username" and "git password". Unless your instructor
tells you otherwise, these will just be your university username and password.  

If your course is set up to use GitHub, you first need to run the following command, where
``GITHUB_USERNAME`` is your GitHub username::

    chisubmit student course set-git-username GITHUB_USERNAME
    
Since your university username may not be the same as your GitHub username, the above command
tells chisubmit what GitHub account to access. Once you've run this command, just run this::
   
   chisubmit student course get-git-credentials

This command will ask for your "git username" and "git password". You will need to enter your
GitHub username and password.


Registering for an assignment
-----------------------------

Before you can make a submission for an assignment, you will need to register for that
assignment. Furthermore, your git repository will typically not be created until you
register for your first assignment.

To register for an assignment, your instructor will provide an *assignment identifier*,
which we will refer to as ``ASSIGNMENT_ID``. You can
also see the list of upcoming assignments (and their identifiers) by running this::

   chisubmit student assignment list

If you are registering individually for an assignment, you just need to run this::

    chisubmit student assignment register ASSIGNMENT_ID

If you are registering as a team, you will need to use the ``--partner`` option.
For example, if you are ``studentA`` and your project partner is ``studentB``, 
you (``studentA``) must first run this command::

    chisubmit student assignment register ASSIGNMENT_ID --partner studentB

Your partner (``studentB``) needs to confirm that they want to be in that same team.
So, they (not you) must run this command::

    chisubmit student assignment register ASSIGNMENT_ID --partner studentA
    
If you are registering a team with three or more students, then you just need
to repeat the ``--partner`` option for each partner. So, assuming we have three
students (``studentA``, ``studentB``, and ``studentC``), each student would
run the following commands, respectively::

    chisubmit student assignment register ASSIGNMENT_ID --partner studentB --partner studentC
    
    chisubmit student assignment register ASSIGNMENT_ID --partner studentA --partner studentC
    
    chisubmit student assignment register ASSIGNMENT_ID --partner studentA --partner studentB

chisubmit will assign you a team name that is composed of your student identifiers
(e.g., in the two-student example, the team name would be ``studentA-studentB``). You can see the 
list of teams you are in by running this command::

    chisubmit student team list

Take into account that, when registering as a team, your registration will not be
complete until **all** members of the team have run ``chisubmit student assignment register``.
If you have run the command, but are not sure whether all your partners have also registered,
you can use this command to check the status of your team (and, in particular, whether 
your partner(s) have completed their part of the registration)::

    chisubmit student team show TEAMNAME

(where ``TEAMNAME`` should be replaced by your team name)



Initializing your repository
----------------------------

Once you have registered for your first assignment, a git repository will be created for you (either
on GitHub or on a GitLab server, depending on the setup of your course). Take into account that if
you register for one assignment individually, an individual repository will be created for you. If
you then register for a different assignment as part of a team, a *separate* team repository will
be created for you (where all your team members will have access).

Please take into account that the repository creation is not instantaneous. There can be a lag of 10-30
minutes between completing your registration and having your 
repository created. 

.. note::

   Once your repository is created, you will be able to access it on GitHub or GitLab. However, before you
   can pull or push from/to GitHub or GitLab, you have to make sure you add your SSH key to Github or GitLab.
   
   Instructions for adding your SSH key on GitHub can be found `here <https://help.github.com/articles/generating-ssh-keys/>`__.
   
   Instructions for adding your SSH key on a GitLab server will depend on the setup of your server, but
   general instructions can be found `here <https://about.gitlab.com/2014/03/04/add-ssh-key-screencast/>`__.

If your course is using GitHub, you will receive an "invitation e-mail" from GitHub asking you to join a group. 
Make sure you accept this invitation; you will not be able to access your repository until you do. 

Once your repository has been created, you can verify that chisubmit can access it by running this command::

   chisubmit student team repo-check TEAM_NAME
   
Where ``TEAM_NAME`` is your team name. If you signed up for the assignment individually, this will
just be your university username.

If your course is set up to use GitHub, you should see something like this::

   Your repository exists and you have access to it.
   Repository website: https://github.com/GIT_ORGANIZATION/COURSE_ID-TEAM_NAME
   Repository URL: git@github.com:GIT_ORGANIZATION/COURSE_ID-TEAM_NAME.git

Where ``GIT_ORGANIZATION`` will be the GitHub Organization used by your course and ``COURSE_ID`` is
the course identifier.

If your course is set up to use GitLab, you should see something like this::

   Your repository exists and you have access to it.
   Repository website: https://git-server.example.edu/COURSE_ID/TEAM_NAME
   Repository URL: git@git-server.example.edu:COURSE_ID/TEAM_NAME.git

Where, instead of ``git-server.example.edu``, you will see your course's GitLab server.

.. note::

   If your GitLab server is ``git-server.example.edu``, then it's likely that the URL to add
   your SSH key to GitLab will be ``https://git-server.example.edu/profile/keys``. Unless
   your instructor tells you otherwise, the username and password for the GitLab server
   will likely be your university username and password.


In the following instructions, we will be using the ``Repository URL`` value, which we will refer to as
``GIT_URL``.

**IMPORTANT**: If you have a team repository (not an individual repository) the repository only
has to be initialized by one of the team members.

To initialize your repository, the first thing you need to do is create an empty local repository. 
In an empty directory, run the following::

   git init
   git remote add -f origin GIT_URL
   
Where ``GIT_URL`` should be replaced with the ``Repository URL`` printed by ``chisubmit student team repo-check``.       

Next, create a ``README`` file and enter the names of all the team members. Add, commit, and push this file to 
your repository::

   git add README
   git commit -m "Added README"
   git push -u origin master
        

Cloning your repository
-----------------------

If a repository has already been initialized as described above, and you want to create a clone elsewhere, just
run the following::

   git clone GIT_URL

Where ``GIT_URL`` should be replaced with the ``Repository URL`` printed by ``chisubmit student team repo-check``.       


Uploading seed code
-------------------

.. note::

   **Note**: The procedure described in this section relies on the ``git subtree`` subcommand. This command was 
   added in Git 1.7.11 and, unfortunately, many operating systems (most notably some recent versions of Ubuntu)
   have earlier versions of Git (or versions of Git where subtree is included but disabled by default).
   
   If this subcommand is not available on your version of Git, try installing a newer version if possible. 
   Note that it is also possible to enable ``subtree`` on earlier versions of Git, but it requires 
   `some legwork <http://engineeredweb.com/blog/how-to-install-git-subtree/>`_). You can also download 
   the Git source code and manually `install only the subtree subcommand <https://github.com/git/git/blob/master/contrib/subtree/INSTALL>`_ .


Some assignments involve starting from some initial seed code provided by the instructors. 
The preferred method of adding this seed code to your repository is by having the instructor
upload the code to a separate repository (which we will refer to as the *upstream* repository),
which you will then pull into your repository, making it easy to then pull any future changes that
happen in the upstream repository.

Do not follow these instructions unless told to by your instructor. There are many other ways of 
supplying seed code, and your instructor may provide alternate instructions.

To follow these instructions, your instructor will supply you with the URL of the upstream repository,
which we will refer to as ``UPSTREAM_URL``, and a prefix, which we will refer to as ``PREFIX``.

To bring the seed code into your repository, you need to run the following::

    git remote add -f PREFIX-upstream UPSTREAM_URL
    git subtree add --prefix PREFIX PREFIX-upstream master --squash

The seed code will be located in a directory with the same name as the prefix provided by your instructor.
However, at this point, you have only added the code to your local repository. To push it to your git repository, 
run the following::

    git push -u origin master

If your instructor makes any changes to the upstream repository, and you want to merge them into your 
repository, you will need to run the following command::

    git subtree pull --prefix PREFIX PREFIX-upstream master --squash


Submitting an assignment
------------------------

When you are ready to submit an assignment, make sure you have pushed all your commits to your course's
git server (either GitHub or a GitLab server). If your code hasn't been pushed, then chisubmit will not see it.



Selecting the commit you want to submit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To submit a project for grading, you first need to select the specific commit you want to submit for grading. 
Commits in git are identified by a SHA-1 hash, and look something like this::

    4eac77c9f11dfb101dbbbe3e9f2df07c40f9b2f5

You can see the list of commits in your repository by running the following::

    git log

Or, if you simply want to get the SHA-1 hash of the latest commit in your ``master`` branch, you can just run this::

    git rev-parse master

Making the submission
~~~~~~~~~~~~~~~~~~~~~

Once you've identified the commit you want to submit, you need to run the following **BEFORE THE DEADLINE**::

    chisubmit student assignment submit <team-id> <assignment-id> <commit-sha>

Where:

* ``<team-id>`` is your team identifier. If you signed up for the assignment individually, this will just be
  your university username. If you are unsure of what your team identifier is, remember you can run
  ``chisubmit student team list`` to list all the teams you belong to.
* ``<assignment-id>`` is the assignment identifier. Your instructor will tell you what identifier to use, 
  but you can also see the list of possible assignment ids by running ``chisubmit student assignment list``.
* ``<commit-sha>`` is the SHA-1 hash of the commit you want to submit.

For example, the command could look something like this::

    chisubmit student assignment submit amr-borja p1a 4eac77c9f11dfb101dbbbe3e9f2df07c40f9b2f5

You will be given an opportunity to verify the details of the submission before you actually 
submit your code. For example, the above command would print something like this::

    You are going to make a submission for p1a (chirc: Part 1).
    The commit you are submitting is the following:
    
          Commit: 4eac77c9f11dfb101dbbbe3e9f2df07c40f9b2f5
            Date: 2015-01-07 08:55:31
         Message: Ready for submission
          Author: Borja Sotomayor <borja@cs.uchicago.edu>
    
    PLEASE VERIFY THIS IS THE EXACT COMMIT YOU WANT TO SUBMIT
    
    Your team currently has 4 extensions
    
    You are going to use 0 extensions on this submission.
    
    You will have 4 extensions left after this submission.

    Are you sure you want to continue? (y/n):

Again, the above has to be run **before the deadline**. If you fail to do so, it doesn't matter 
if your code was pushed to the git server before the deadline. For your code to be accepted for 
grading, you must also run the chisubmit submission command before the deadline. The chisubmit 
system will mercilessly stop accepting submissions once the deadline has passed.

Using extensions
~~~~~~~~~~~~~~~~

If your course allows the use of extensions, and you wish to use an extension for a submission, then
you need to run the following::

    chisubmit student assignment submit <team-id> <project-id> <commit-sha> --extensions <num-extensions>

i.e., the same as before, but with an additional `--extensions` parameter to specify how many extensions
you are using in this submission. 

If you are using an extension, you do *not* need to run this command before the original deadline.
Instead, you should allow the original deadline to pass, and then make sure that you make your submission
(with the extension) before the *extended deadline*. So, if the deadline is January 12 at 8pm, 
and you plan to use two extensions, then the extended deadline is January 14 at 8pm.

For example, you could run the command like this::

    chisubmit student assignment submit amr-borja p1a 4eac77c9f11dfb101dbbbe3e9f2df07c40f9b2f5 --extensions 1

chisubmit will validate that the number of extensions you're requesting is acceptable based on the submission time, 
the deadline, and the number of extensions you have left. chisubmit will not allow you to submit your code if 
you try to request too many or not enough extensions (or if you do not have sufficient extensions to make the submission).

Please note that you do *not* need to ask permission to use an extension, and you do *not* need to notify 
the instructor via e-mail that you are taking an extension. Just specifying it when you run chisubmit is enough.

Amending a submission
~~~~~~~~~~~~~~~~~~~~~

If you make a submission, and realize you want to change something in your submission, all you have to 
do is make the changes, commit them, and run ``chisubmit student assignment submit`` with the new commit and 
with the ``--force`` option. For example:: 

    chisubmit student assignment submit amr-borja p1a 3bc2ab13a504393e12c48a3b8a56510a901329fd --force

chisubmit will warn you that there is an existing submission, and will ask you to confirm that you 
want to make a new one::


    WARNING: You have already submitted assignment p1a and you 
    are about to overwrite the previous submission of the following commit:
    
          Commit: 4eac77c9f11dfb101dbbbe3e9f2df07c40f9b2f5
            Date: 2015-01-07 08:55:31
         Message: Ready for submission
          Author: Borja Sotomayor <borja@cs.uchicago.edu>
    
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    THE ABOVE SUBMISSION FOR p1a (chirc: Part 1) WILL BE CANCELLED.
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    If you continue, your submission for p1a (chirc: Part 1)
    will now point to the following commit:
    
          Commit: 3bc2ab13a504393e12c48a3b8a56510a901329fd
            Date: 2015-01-07 08:59:31
         Message: Ok, really ready for submission now
          Author: Borja Sotomayor <borja@cs.uchicago.edu>
    
    PLEASE VERIFY THIS IS THE EXACT COMMIT YOU WANT TO SUBMIT
    
    Your team currently has 4 extensions

    You used 0 extensions in your previous submission of this assignment.
    and you are going to use 0 additional extensions now.
    
    You will have 4 extensions left after this submission.
    
    Are you sure you want to continue? (y/n):  y

Like your first submission, you can only re-submit *before the deadline*. Once the deadline passes, you 
**cannot** modify your submission, not even if you use extensions.

If you make a submission and, before the deadline, you realize you want to use an extension 
(and re-submit after the deadline with an extension), then you need to make sure you **cancel** 
your submission before the deadline::

    chisubmit student assignment cancel-submit amr-borja p1a

You will see something like this::

    This is your existing submission for assignment pa1:
    
          Commit: 3bc2ab13a504393e12c48a3b8a56510a901329fd
            Date: 2015-01-07 08:59:31
         Message: Ok, really ready for submission now
          Author: Borja Sotomayor <borja@cs.uchicago.edu>
    
    Are you sure you want to cancel this submission? (y/n):  y
    
    Your submission has been cancelled.

Other useful chisubmit commands
-------------------------------

chisubmit student assignment list
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Shows the list of assignments, including their deadlines::

    $ chisubmit student assignment list
    p1a  2015-01-12 20:00:00-06:00  chirc: Part 1
    p1b  2015-01-22 20:00:00-06:00  chirc: Part 2
    p1c  2015-02-02 20:00:00-06:00  chirc: Part 3
    p2a  2015-02-18 20:00:00-06:00  chitcp: Part 1
    p2b  2015-02-25 20:00:00-06:00  chitcp: Part 2
    p3   2015-03-11 20:00:00-05:00  Simple Router

chisubmit student assignment show-deadline ASSIGNMENT_ID
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Provides more details about the deadline of an assignment::

    $ chisubmit student assignment show-deadline p1a
    chirc: Part 1
    
          Now: 2015-01-10 20:19:29-06:00
     Deadline: 2015-01-12 20:00:00-06:00
    
    The deadline has not yet passed
    You have 1 days, 23 hours, 40 minutes, 31 seconds left

If the deadline has passed, it will tell you how many extensions you need::

    $ chisubmit student assignment show-deadline pa1
    Programming Assignment 1
    
          Now: 2015-01-10 20:21:12-06:00
     Deadline: 2015-01-10 17:00:00-06:00
    
    The deadline passed 0 days, 3 hours, 21 minutes, 12 seconds ago
    If you submit your assignment now, you will need to use 1 extensions

chisubmit student team show TEAM_ID
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Will show you information about the team, including the number of extensions 
remaining, assignments you are registered for, and extensions used in previous assignments::

    $ chisubmit student team show the-reticent-reallocs
    Team name: the-reticent-reallocs
    
    Extensions available: 3
    
    STUDENTS
    --------
    jmalloc: Mallock, John  (CONFIRMED)
    sprintf: Printeffe, Sarah  (CONFIRMED)

    ASSIGNMENTS
    -----------
    ID: pa1
    Name: Programming Assignment 1
    Deadline: 2015-01-10 20:00:00-06:00
    Last submitted at: 2015-01-10 20:28:39-06:00
    Extensions used: 1
    
    ID: pa2
    Name: Programming Assignment 2
    Deadline: 2015-01-11 20:00:00-06:00
    Last submitted at: 2015-01-10 20:28:40-06:00
    Extensions used: 0
    
    ID: pa3
    Name: Programming Assignment 3
    Deadline: 2015-01-12 20:00:00-06:00
    NOT SUBMITTED

 