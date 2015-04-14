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

   $ chisubmit instructor assignment stats p1
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

chisubmit can be used to perform the entire grading workflow over Git. The basic workflow is:

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

chisubmit assumes that a rubric is divided into one or more "section" which is worth a number of points.
This mechanism is currently fairly inflexible (it is hard to modify and remove sections of the rubric), 
so we recommend you don't create the rubric until you know for sure what the sections of the rubric will
be. Once you do, just run this command for each section::

   chisubmit instructor assignment add-grade-component ASSIGNMENT_ID SECTION_ID "SECTION_NAME" POINTS
   
Where:

* ``ASSIGNMENT_ID`` is the assignment identifier.
* ``SECTION_ID`` is an identifier for the section. Only alphanumeric characters are allowed, with no spaces.
* ``SECTION_NAME`` is a descriptive name for the section.
* ``POINTS`` is the number of points this section is worth.

For example::

   chisubmit instructor assignment add-grade-component p1 tests "Tests" 50 
   chisubmit instructor assignment add-grade-component p1 conn "Implementing foo()" 20 
   chisubmit instructor assignment add-grade-component p1 bar "Implementing bar()" 20
   chisubmit instructor assignment add-grade-component p1 style "Code Style" 10

Please note that the points are not required to add up to 100. 


After the submission deadline
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once the deadline for an assignment passes, the instructor has to perform a series of steps
before the graders can start grading. These steps will create local *grading repos* on
the instructor's machine, and each repo will get a new branch called ``ASSIGNMENT_ID-grading``
(where ``ASSIGNMENT_ID`` is the assignment being graded; e.g., assignment ``p1`` would have
a branch called ``p1-grading``). All grading takes place on this branch. No other branch
in the teams' repositories should be modified.

If your course uses extensions, the following steps have to be repeated after each "extended" deadline, 
as they will only create the grading repos for the teams that are ready for grading. 

To create the grading repos and the grading branches, run the following::

        chisubmit instructor grading create-grading-repos ASSIGNMENT_ID
        chisubmit instructor grading create-grading-branches ASSIGNMENT_ID

Next, assign graders to the submissions::

        chisubmit instructor grading assign-graders ASSIGNMENT_ID

Use ``--avoid-assignment ASSIGNMENT_ID`` to avoid assigning the same teams that were assigned to the graders 
in a previous assignment. Use ``--from-assignment ASSIGNMENT_ID`` to assign the same teams to the same graders 
(whenever possible).

You can see the graders assigned to each assignment with this command::

        chisubmit instructor grading list-grader-assignments ASSIGNMENT_ID

If you are using rubrics, run the following to create the rubric files and to commit them to the grading branches::

        chisubmit instructor grading add-rubrics --commit $ASSIGNMENT_ID

Skip the `--commit` option if you don't want the rubrics to be committed to the grading repos 
(this can be useful to test whether the rubrics are being correctly generated).

Finally, push the grading repos to the staging server::

        chisubmit instructor grading push-grading-branches --to-staging ASSIGNMENT_ID

After the graders have finished grading
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once the graders are done grading, pull their work from the staging server::

        chisubmit instructor grading pull-grading-branches --from-staging ASSIGNMENT_ID

If you are using rubrics, use the following command to collect the scores from the rubrics::

        chisubmit instructor grading collect-rubrics $ASSIGNMENT_ID

Run with ``--dry-run`` if you just want to check what the grades are, without actually loading 
them into the chisubmit database.

Check whether all the submissions have been graded::

        chisubmit instructor grading show-grading-status ASSIGNMENT_ID --by-grader

Finally, push the graded repositories to the students::

        chisubmit instructor grading push-grading-branches --to-students ASSIGNMENT_ID
        
Regrading
~~~~~~~~~

If a team requests a regrading, simply ask the grader assigned to that team to regrade the
work and to push an updated version of the repository to the staging server. Once this is done,
just run the following commands to collect and publish the new version::

        chisubmit instructor grading pull-grading-branches --from-staging ASSIGNMENT_ID --only TEAM_ID
        chisubmit instructor grading collect-rubrics $ASSIGNMENT_ID
        chisubmit instructor grading push-grading-branches --to-students ASSIGNMENT_ID --only TEAM_ID
        

 