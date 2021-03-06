.. _chisubmit_graders:

For Graders
===========

This page contains instructions on how to use chisubmit specifically for graders. 

Initial setup
-------------

Before you perform any of the instructions discussed in this page, create an empty directory
to do your grading in (we will refer to this directory as your *grading directory*).
Inside that directory, run the following command::

   chisubmit init
   

Pulling repositories to grade
-----------------------------

Once an assignment is ready to grade, you need to create local *grading repos* to do your grading
on. These grading repos will have a branch called ``ASSIGNMENT_ID-grading``
(where ``ASSIGNMENT_ID`` is the assignment being graded; e.g., assignment ``p1`` would have
a branch called ``p1-grading``).
*All your grading must be done on this branch*. **Do not modify any other branch on the repository**

To pull the repositories assigned to you, run the following::

        chisubmit grader pull-grading ASSIGNMENT_ID
        
Where ``ASSIGNMENT_ID`` is the assignment identifier.

The repositories will now be in ``repositories/COURSE_ID/ASSIGNMENT_ID/`` inside your grading directory.

If your course uses extensions, you should repeat this step after each extended deadline. Your
instructor may also notify you that you've been assigned additional repositories; you will
need to repeat these steps to pull the repositories that have been newly assigned to you.


Grading the code
----------------

Add comments directly on the code. Use the following format::

        /*** GRADER COMMENT: You forgot to initialize variable 'foo' */
        
        ### GRADER COMMENT: You forgot to initialize variable 'foo'

Or::

        /*** GRADER COMMENT 
         * The following code is wrong for a variety of reasons. Let me tell you why:
         *  - It hurts my eyes
         *  - It offends the order of created things
         *  - It is an aberration unto the Lord
         */
         
        ### GRADER COMMENT 
        # The following code is wrong for a variety of reasons. Let me tell you why:
        #  - It hurts my eyes
        #  - It offends the order of created things
        #  - It is an aberration unto the Lord
         

Any time a penalty is assessed, make sure to include it in the comment::

        /*** GRADER COMMENT 
         *** PENALTY: -10 points
         *
         * ...
         *
         */
         
        ### GRADER COMMENT 
        ### PENALTY: -10 points
        #
        # ...
        #

If the assignment has a rubric file, there will be a file called ``ASSIGNMENT_ID.rubric.txt`` at the
root of the repository. It will look something like this::

   Points:
       - Tests:
           Points Possible: 50
           Points Obtained: 
   
       - Implementing foo():
           Points Possible: 20
           Points Obtained: 
   
       - Implementing bar():
           Points Possible: 20
           Points Obtained: 
   
       - Code Style:
           Points Possible: 10
           Points Obtained: 
      
   Total Points: 0 / 100
   
   Comments: >
       None

You must fill out the points, and update ``Total Points`` accordingly. To provide comments on the grading,
do so under ``Comments: >``. Please note that students will see these comments.

If you need to apply global deductions (i.e., deductions that do not apply to a single section of the rubric),
you can add the following to the rubric::

   Penalties:
       DEDUCTION_1_DESCRIPTION: DEDUCTION_1_AMOUNT
       DEDUCTION_2_DESCRIPTION: DEDUCTION_2_AMOUNT
       ...
       DEDUCTION_N_DESCRIPTION: DEDUCTION_N_AMOUNT
              
For example::

   Penalties:
       Submitted code in Word document: -30
       Uses library we specifically asked you not to use: -5
       

If you need to apply global bonuses (typically an adjustment to the final grade to account
for something; e.g., if the student worked alone), you can add the following to the rubric::

   Bonuses:
       BONUS_1_DESCRIPTION: BONUS_1_AMOUNT
       BONUS_2_DESCRIPTION: BONUS_2_AMOUNT
       ...
       BONUS_N_DESCRIPTION: BONUS_N_AMOUNT
              
For example::

   Bonuses:
       Worked alone: 10       
              
Note: the above is just an *example*. In general, you should only apply the penalties and bonuses
specified by the course instructor(s).              

This is an example of a completed rubric::

   Points:
       - Tests:
           Points Possible: 50
           Points Obtained: 45
   
       - Implementing foo():
           Points Possible: 20
           Points Obtained: 10
   
       - Implementing bar():
           Points Possible: 20
           Points Obtained: 20
   
       - Code Style:
           Points Possible: 10
           Points Obtained: 7.5

   Penalties:
       Code comments are written in Old English: -5
       
   Bonuses:
       Worked alone: 10       
      
   Total Points: 87.5 / 100
   
   Comments: >
       Well done!


Pushing your graded work
------------------------

Before pushing your graded work to the staging server, make sure that you have committed
your work. Just commit as you usually would in Git::

   git commit -m "Graded" 

Take into account that chisubmit will already set up the repository so a generic author appears 
on the commit.

If your course is using rubrics, validate the rubrics with this command::

        chisubmit grader validate-rubrics ASSIGNMENT_ID 
        
Use the ``--only TEAM_ID`` option to validate a single rubric.

Note: The rubric file will not be added to Git by default. You will have to ``git add`` it
to make sure it is included.

Finally, push your work to the staging server::

        chisubmit grader push-grading ASSIGNMENT_ID 
        
Take into account that you do not need to wait until all your repositories are graded before
running these commands. If you have not yet graded a repository, running the above
command will have no effect on that repository.

You can also use the ``--only TEAM_ID`` option to only push a single repository.


