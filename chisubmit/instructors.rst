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

   chisubmit instructor team show

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

To pull all the repos from all the teams registered for an assignment, run the following::

   chisubmit instructor team pull-repos ASSIGNMENT_ID DIRECTORY

Where:

* ``ASSIGNMENT_ID`` is the assignment identifier.
* ``DIRECTORY`` is the directory to pull the repos to.

This command can be run multiple times on the same directory. If the repository has already been pulled,
the latest commits will be pulled from the repository.

This command also accepts the following parameters:

* ``--only TEAM_ID``: Only pulls the repository for team ``TEAM_ID``
* ``--only-ready-for-grading``: Only pulls the repositories that are ready for grading. A repository is
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

chisubmit assumes that a rubric is divided into one or more "components" which is worth a number of points.
This mechanism is currently fairly inflexible (it is hard to modify and remove components of the rubric), 
so we recommend you don't create the rubric until you know for sure what the components of the rubric will
be. Once you do, just run this command for each component::

   chisubmit instructor assignment add-rubric-component ASSIGNMENT_ID "COMPONENT_NAME" POINTS
   
Where:

* ``ASSIGNMENT_ID`` is the assignment identifier.
* ``COMPONENT_NAME`` is a descriptive name for the component.
* ``POINTS`` is the number of points this component is worth.

For example::

   chisubmit instructor assignment add-rubric-component p1 "Tests" 50 
   chisubmit instructor assignment add-rubric-component p1 "Implementing foo()" 20 
   chisubmit instructor assignment add-rubric-component p1 "Implementing bar()" 20
   chisubmit instructor assignment add-rubric-component p1 "Code Style" 10

Please note that the points are not required to add up to 100. 


After the submission deadline
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Next, assign graders to the submissions::

        chisubmit instructor grading assign-graders ASSIGNMENT_ID

Use ``--avoid-assignment ASSIGNMENT_ID`` to avoid assigning the same teams that were assigned to the graders 
in a previous assignment. Use ``--from-assignment ASSIGNMENT_ID`` to assign the same teams to the same graders 
(whenever possible).

By default, ``assign-grader`` will divide up all the submitted repos equally amongst the graders. If a different
allocation is preferable, you can create a file with the following format::

   grader1: 10
   grader2: 5
   grader3: remainder
   grader4: remainder
   grader5: remainder
   
This will assign 10 repos to ``grader1``, 5 repos to ``grader2``, and split the remaining equally between
``grader3``, ``grader4``, and ``grader5``. To use this file, run the command as follows::

   chisubmit instructor grading assign-graders ASSIGNMENT_ID --grader-file GRADER_FILE

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
option if you want to see all the repos listed together.

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

        
Regrading
~~~~~~~~~

If a team requests a regrading, simply ask the grader assigned to that team to regrade the
work and to push an updated version of the repository to the staging server (alternatively,
any instructor can do this as well). Once this is done, the master instructor just needs
to run the following::

        chisubmit instructor grading pull-grading ASSIGNMENT_ID --only TEAM_ID
        chisubmit instructor grading push-grading --to-students ASSIGNMENT_ID --only TEAM_ID
        

 