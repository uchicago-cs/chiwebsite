.. _chisubmit_instructors:

For Instructors
===============

This page contains instructions on how to use chisubmit specifically for instructors. 

Initial setup
-------------

Courses can only be created by the chisubmit administrator. Once a course has been created,
it will be assigned a course identifier, which we will refer to as ``COURSE_ID``.

Before you perform any of the instructions discussed in this page, make sure you've followed
the steps described in :ref:`chisubmit_common`.


Assignment management
---------------------

Creating an assignment
~~~~~~~~~~~~~~~~~~~~~~

To create an assignment, run the following command::

   chisubmit instructor assignment add ASSIGNMENT_ID "ASSIGNMENT_NAME" "DEADLINE"
   
Where:

* ``ASSIGNMENT_ID`` is an assignment identifier. Only alphanumeric characters are allowed, with no spaces.
* ``ASSIGNMENT_DESCRIPTION`` is the human-readable name of the assignment.
* ``DEADLINE`` is the deadline for the assignment, in ``YYYY-MM-DD HH:MM`` format. The time is assumed to be
  in the local timezone. Note that it is not currently possible to create assignments without deadlines. If an
  assignment does not have a deadline, just set the deadline to some reasonable maximum (e.g., the end of the
  quarter/semester).
  
For example::

   chisubmit instructor assignment add p1 "Project 1" "2015-01-12 20:00"

Modifying attributes of an assignment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Assignments have several attributes you can modify using the following command::

   chisubmit instructor assignment set-attribute ASSIGNMENT_ID ATTRIBUTE_NAME ATTRIBUTE_VALUE
   
Where ``ATTRIBUTE_NAME`` is one of the following:

* ``min_students``: The minimum number of students required to form a team to register for
  this assignment (Default: ``1``, i.e., an individual assignment)
* ``max_students``: The maximum number of students required to form a team to register for
  this assignment (Default: ``1``, i.e., an individual assignment)
* ``deadline``: The deadline. Must be of the form ``YYYY-MM-DD HH:MM``
* ``grace_period``: The deadline grace period (the period of time after the deadline when
  assignments will continue to be accepted, but without consuming an extension). The value
  must be of the form ``HH:MM:SS``.


Listing assignments
~~~~~~~~~~~~~~~~~~~

To list all assignments, including their deadlines, run the following command::

   chisubmit instructor assignment list
   
   
Useful statistics
~~~~~~~~~~~~~~~~~

The following command will print out a summary of how many teams have registered
for an assignment, and how many have submitted the assignment::

   chisubmit instructor assignment stats ASSIGNMENT_ID
   
Where:

* ``ASSIGNMENT_ID`` is the assignment identifier.

For example::

   $ chisubmit instructor assignment stats p1
   Assignment 'Project 1'
   =====================================
   
   36 / 71 students in 18 teams have signed up for assignment p1
   
   0 / 18 teams have submitted the assignment
   
The command can also be run with the ``--verbose`` flag to also print the names of the
students who have not yet registered for the assignment as well as the teams that have not yet
submitted the assignment. For example::

   $ chisubmit --verbose instructor assignment stats p1
   Assignment 'Project 1'
   =====================================
   
   36 / 71 students in 18 teams have signed up for assignment p1
   
   0 / 18 teams have submitted the assignment

   Students who have not yet signed up
   -----------------------------------
   Anderson, Thomas <neo@uchicago.edu>
   Hacker, Random J. <rjh@uchicago.edu>
   ...

   Teams that have not submitted
   -----------------------------
   amr-borja
   ams-jhr
   ...


Team management
---------------

Listing teams
~~~~~~~~~~~~~

To list all the teams in the course, run this::

   chisubmit instructor team list
   
This will show all the teams, the students in each team, and the assignments each team is registered for.

Team details
~~~~~~~~~~~~

To show information about a team, including the status of all the assignments the team is registered for, run this::

   chisubmit instructor team show TEAM_ID

This will produce output like this::

   Team name: amr-borja
   
   Extensions available: 0
      
   STUDENTS
   --------
   amr: Rogers, Anne  (CONFIRMED)
   borja: Sotomayor, Borja  (CONFIRMED)
   
   ASSIGNMENTS
   -----------
   ID: p1
   Name: Project 1
   Deadline: 2015-01-12 20:00:00-06:00
   Last submitted at: 2015-01-13 19:17:39-06:00
   Commit SHA: 5d47ffb0648dbcc29a78191982fefb1a4bff4426
   Extensions used: 1
   
   ID: p2
   Name: Project 2
   Deadline: 2015-01-22 20:00:00-06:00
   NOT SUBMITTED
   
   
Pulling team repos
~~~~~~~~~~~~~~~~~~

To pull all the repos from all the teams in the course, run the following::

   chisubmit instructor team pull-repos DIRECTORY

Where ``DIRECTORY`` is the directory to pull the repos to.

This command can be run multiple times on the same directory. If the repository has already been pulled,
the latest commits will be pulled from the repository.

You can also pull only the repos for the teams registered for a specific assignment::

   chisubmit instructor team pull-repos --assignment ASSIGNMENT_ID DIRECTORY

This command also accepts the following parameters:

* ``--only TEAM_ID``: Only pulls the repository for team ``TEAM_ID``
* ``--only-ready-for-grading``: Only pulls the repositories that are ready for grading (note: this requires
  specifying an assignment with ``--assignment``. A repository is
  considered ready for grading if a submission has been made, and the deadline for the assignment has passed.
  If your course uses extensions, the "ready for grading" repositories will come in waves, and it is advisable
  to run this command after each extended deadline.
  
  
Grading
-------

chisubmit can be used to perform the entire grading workflow over Git. Please note that this requires
the creation of an additional *staging server*. If your chisubmit admin has not set this up for your
course, you will not be able to manage grading with chisubmit.

The basic workflow is:

#. Students submit their assignments
#. Instructor pushes a copy of submitted assignments to a *staging server*. This is a git server
   that only the instructors and the graders have access to.
#. Instructor assigns teams to graders.
#. Graders pull the team repositories assigned to them.
#. After grading the repositories, they push their graded versions to the staging server.
#. The instructor reviews the grading, and pushes the graded versions to the regular server
   (the one that students have access to).

Optionally, it is possible to assign a rubric to an assignment, which the graders can then fill out,
making it easier to collect the scores assigned by the graders.

Creating the rubric
~~~~~~~~~~~~~~~~~~~

chisubmit assumes that a rubric is divided into one or more "components", each of which is worth a number of points.
To add a new rubric to an assignment, you must first create a text file with the following format::

   Points:
       - The PA1 Tests:
           Points Possible: 50
           Points Obtained: 
   
       - The PA1 Design:
           Points Possible: 50
           Points Obtained: 
           
   Total Points: 0 / 100 

This format is similar to what the graders will be filling out (see the :ref:`chisubmit_graders` section
for more details). In the above file, the rubric has two components: ``The PA1 Tests`` and ``The PA1 Design``,
and we leave the ``Points Obtained`` blank. The ``Total Points`` field must always be of the form ``0 / TOTAL``
(please note that the points are not required to add up to 100). 

To load the rubric for an assignment, run the following::

   instructor assignment add-rubric ASSIGNMENT_ID RUBRIC_FILE
   
Where:

* ``ASSIGNMENT_ID`` is the assignment identifier.
* ``RUBRIC_FILE`` is the rubric file

To ensure the rubric was loaded correctly, run the following command::

   instructor assignment add-rubric ASSIGNMENT_ID

This will display the rubric exactly as it will be shown to the graders and to the students.

If you realize you need to update the rubric, you can run the ``add-rubric`` command again, but please
note that it will completely replace the previous rubric. This is not an issue if grading has not yet
begun, but can cause inconsistencies if graders have already started grading with a previous rubric. 



Creating grading repos
~~~~~~~~~~~~~~~~~~~~~~

Once the deadline for an assignment passes, the instructor has to perform a series of steps
before the graders can start grading. In a class with multiple instructor, only one instructor
should follow these steps (and we will refer to this instructor as the "master instructor").

The first step is to create local *grading repos* on the master instructor's machine.
Each repo will be a clone of a submitted repo, but with a new branch called ``ASSIGNMENT_ID-grading``
(where ``ASSIGNMENT_ID`` is the assignment being graded; e.g., assignment ``p1`` would have
a branch called ``p1-grading``). All grading takes place on this branch. No other branch
in the teams' repositories should be modified.

These grading repos will be configured with two Git remotes: 

* ``origin``: Pointing to the student repository
* ``staging``: Pointing to a clone of that repository on the staging server.

The graders (and other non-master instructors) will only have access to the staging server.
The master instructor is the only one that has access to both, and thus is responsible
for creating the initial clones of the submitted repositories, as well as pushing the
final grading back to the students.

To create the grading repos and the grading branches, run the following::

   chisubmit instructor grading create-grading-repos --master ASSIGNMENT_ID
   
The repositories will be created in ``repositories/COURSE_ID/ASSIGNMENT_ID/`` (in the
directory where you ran ``chisubmit init``).   
   
To push them to the staging server, run the following::

   chisubmit instructor grading push-grading ASSIGNMENT_ID

If your course uses extensions, the following steps have to be repeated after each "extended" deadline, 
as they will only create the grading repos for the teams that are ready for grading. 

.. note::

   Once the grading repos have been created by the master instructor, the repos
   will be flagged as "ready for grading", which means students will no longer
   be allowed to cancel their submissions. Please read the "Submitting an assignment" section
   in :ref:`chisubmit_students` for a lengthier discussion of what this implies.
   
   In practice, it is advisable to allow some time (if possible) between the deadline
   and the creation of the grading repos, in case any students realize they
   want to cancel a submission, which chisubmit will allow them to do themselves
   as long as the grading repos have not yet been created. Once the grading repos 
   are created, cancelling a submission requires manual intervention from
   the instructor, because a grader could've started grading that submission.
   The exact steps for cancelling a submission are described later in this page.

Assigning graders to repos
~~~~~~~~~~~~~~~~~~~~~~~~~~

Next, you will need to assign graders to each repo. chisubmit provides a mechanism to randomly
assign graders to repos, with a few parameters to guide that random assignment.

First of all, if there is a conflict of interest between a grader and a student (e.g., friends,
roommates, etc.), it is possible to make a record of that conflict so the grader is never assigned 
to grade that student's work. To mark a conflict of interest, just run this command::

   chisubmit instructor grading add-conflict GRADER_ID STUDENT_ID
   
Where ``GRADER_ID`` and ``STUDENT_ID`` are the usernames of the grader and the student, respectively.

To assign graders to the submissions, run the following::

   chisubmit instructor grading assign-graders ASSIGNMENT_ID

Use ``--avoid-assignment ASSIGNMENT_ID`` to avoid assigning the same teams that were assigned to the graders 
in a previous assignment. Use ``--from-assignment ASSIGNMENT_ID`` to assign the same teams to the same graders 
(whenever possible).

By default, ``assign-grader`` will divide up all the submitted repos equally amongst all the graders. If a different
allocation is preferable, you can create a file with the following format::

   grader1: 10
   grader2: 5
   grader3: remainder
   grader4: remainder
   grader5: remainder
   
This will assign 10 repos to ``grader1``, 5 repos to ``grader2``, and split the remaining equally between
``grader3``, ``grader4``, and ``grader5``. To use this file, run the command as follows::

   chisubmit instructor grading assign-graders ASSIGNMENT_ID --grader-file GRADER_FILE

You can use the ``--dry-run`` option to see what assignments would be made, but without
actually saving them.

You can modify individual grading assignments (i.e., who is assigned to grade what repo)
using the following command::

   chisubmit instructor grading assign-grader ASSIGNMENT_ID TEAM_ID GRADER_ID

You can see the graders assigned to each assignment with this command::

   chisubmit instructor grading list-grader-assignments ASSIGNMENT_ID


Reviewing grading in progress
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The master instructor can pull the graders' work from the staging server by running the following::

   chisubmit instructor grading pull-grading ASSIGNMENT_ID
   
If other instructors want to review the grading, they first need to run this::

   chisubmit instructor grading create-grading-repos ASSIGNMENT_ID
   
This will create local grading repos in their machine, but with access limited only to the
staging server (notice how we did not include the ``--master`` option). Once they have
done this, they can use the ``pull-grading`` command any time they want to pull the graders'
latest work.

After running ``pull-grading``, an instructor (master or non-master) can also run the following 
command to get a report of what repos have been graded::

    chisubmit instructor grading show-grading-status --by-grader ASSIGNMENT_ID
    
Usually, it is useful to see this report broken down by grader, but you can omit the ``--by-grader``
option if you want to see all the repos listed together. You can also use the
``--include-diff-urls`` option to include, for each repo, a URL that will show
a diff between the submitted version of the work and the graded version (this
is useful when reviewing the graders' work)

Any changes to the grading can be pushed back to the staging server by running this::

    chisubmit instructor grading push-grading ASSIGNMENT_ID
   
**Note**: Do not use ``git push`` manually if you are the master instructor, as this may
result in you pushing the grading to the students before you intended to. If you are
the master instructor and want to use ``git pull`` and ``git push`` manually, 
make sure you are using the ``staging`` remote.


After the graders have finished grading
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once the graders are done grading, the master instructor should pull their work from the 
staging server as described above::

    chisubmit instructor grading pull-grading ASSIGNMENT_ID
    
The grading can then be pushed back to the students by running the following::

    chisubmit instructor grading push-grading --to-students ASSIGNMENT_ID

If you are using rubrics, use the following command to collect the scores from the rubrics::

    chisubmit instructor grading collect-rubrics $ASSIGNMENT_ID

And the following to produce a CSV file with all the grades::

    chisubmit instructor grading list-grades > grades.csv


Common requests
---------------
        
Manually registering a student or team
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To manually register a student for an assignment run the following command::

   chisubmit instructor assignment register ASSIGNMENT_ID --student STUDENT_ID
   
Where:

* ``ASSIGNMENT_ID`` is the assignment identifier.
* ``STUDENT_ID`` is the student's username.

To manually register a team, run the same command but with multiple ``--student`` options.
For example::

   chisubmit instructor assignment register pa1 --student borja --student amr

This will register a team with two students (``borja`` and ``amr``) for assignment ``pa1``.
        
Manual submission of an assignment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes, it will be necessary for an instructor to manually submit an
assignment, either because the student is unable to do so, or because the
instructor needs to override the deadline (and manually specify how many
extensions to use).

To do this, run the following command::

   chisubmit instructor assignment submit TEAM_ID ASSIGNMENT_ID COMMIT_SHA EXTENSIONS
   
Where:

* ``TEAM_ID`` is the team's identifier (or the student username for individual assignments)
* ``ASSIGNMENT_ID`` is the assignment identifier.
* ``COMMIT_SHA`` is the SHA of the commit to submit.
* ``EXTENSIONS`` is the number of extensions this submission should consume, regardless of
  when the submission is made.
  
This command will also work for resubmissions: it can be run multiple times, but chisubmit
may reject the resubmission if the previous submission is already being graded.
         
        
Regrading assignments
~~~~~~~~~~~~~~~~~~~~~

If a student or team requests a regrade, simply ask the grader assigned to that team to regrade the
work and to push an updated version of the repository to the staging server (alternatively,
any instructor can do this as well). Once this is done, the master instructor just needs
to run the following::

        chisubmit instructor grading pull-grading ASSIGNMENT_ID --only TEAM_ID
        chisubmit instructor grading push-grading --to-students ASSIGNMENT_ID --only TEAM_ID

        
Cancelling a submission
~~~~~~~~~~~~~~~~~~~~~~~

If a student tries to cancel a submission *after* the grading repos have been created, chisubmit
will tell them to contact an instructor. When this happens, the master instructor should run 
the following command::

   chisubmit instructor assignment cancel-submit TEAM_ID ASSIGNMENT_ID

Where:

* ``TEAM_ID`` is the team's identifier (or the student username for individual assignments)
* ``ASSIGNMENT_ID`` is the assignment identifier.

Then, go into the following directory::

   repositories/COURSE_ID/ASSIGNMENT_ID/TEAM_ID
   
Where ``COURSE_ID``, ``ASSIGNMENT_ID``, and ``TEAM_ID`` should be replaced by the appropriate values.
   
And run the following::

   AID=<assignment identifier>
   git checkout master
   git branch -D $AID-grading
   git push staging :$AID-grading
   
Where ``<assignment identifier>`` should be replaced with the assignment identifier.

This will remove the grading branch from both the local grading repos and the staging server
that the graders have access to.

Once the student or team makes another submission, the ``create-grading-repos`` command
will create a new grading branch.

Please note that the ``cancel-submit`` command may print out the following warning::

   This submission has already been assigned a grader (GRADER_ID)
   Make sure the grader has been notified to discard this submission.
   You must also remove the existing grading branch from the staging server.
        
In this case, make sure to contact the grader with username ``GRADER_ID`` to alert
them about this. Here is a suggested message template::

   TEAM_ID's submission, which was originally assigned to you, has
   been cancelled. If you have already fetched the ASSIGNMENT_ID repositories, please
   delete that directory. Once TEAM_ID makes an updated submission,
   it may be assigned to you again (but don't be alarmed if it isn't).



 