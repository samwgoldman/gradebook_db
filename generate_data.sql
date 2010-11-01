BEGIN;

SET LOCAL synchronous_commit TO OFF;

-- Set def'n
CREATE TABLE N AS SELECT * FROM generate_series(1, 100) as i;

-- Create N users
INSERT INTO "user" (id)
SELECT i FROM N;

-- Create N classes
INSERT INTO class (id)
SELECT 1;

-- Assign all users to all classes
INSERT INTO class_user (class_id, user_id)
SELECT class.id, "user".id FROM class, "user";

-- Create N quizzes
INSERT INTO quiz (id)
SELECT i FROM N;

-- Create N options
INSERT INTO "option" (id)
SELECT i FROM N;

-- Create N questions of each type for each quiz
INSERT INTO question (quiz_id, number, type, points)
SELECT quiz.i, question.i, question.t, 1
FROM N AS quiz
CROSS JOIN (SELECT i, 'true_false'::question_type t FROM N
            WHERE i BETWEEN 0 AND 33
            UNION
            SELECT i, 'multiple_choice'::question_type FROM N
            WHERE i BETWEEN 34 AND 66
            UNION
            SELECT i, 'multiple_answer'::question_type FROM N
            WHERE i BETWEEN 67 AND 100) question;

CREATE INDEX question_type_idx ON question (type);

-- Create true solution for all true or false questions
INSERT into solution_true_false (quiz_id, number, truth)
SELECT quiz_id, number, b'1'
FROM question
WHERE question.type = 'true_false';

-- Create 10 "option"s for each multiple choice question
INSERT INTO question_multiple_choice (quiz_id, number, option_id, "order")
SELECT quiz_id, number, option.i, option.i
FROM question, N as option
WHERE question.type = 'multiple_choice'
AND i <= 10;

-- Create solution for all multiple choice questions
INSERT INTO solution_multiple_choice (quiz_id, number, option_id)
SELECT quiz_id, number, 1
FROM question
WHERE question.type = 'multiple_choice';

-- Create 10 "option"s for each multiple answer question
INSERT INTO question_multiple_answer (quiz_id, number, option_id, "order")
SELECT quiz_id, number, option.i, option.i
FROM question, N as option
WHERE question.type = 'multiple_answer'
AND i <= 10;

-- Create three solutions for all multiple answer questions
INSERT INTO solution_multiple_answer (quiz_id, number, option_id)
SELECT quiz_id, number, option.i
FROM question, N as option
WHERE question.type = 'multiple_answer'
AND i <= 3;

-- Create an assignment for all users in all classes to all quizzes
INSERT INTO assignment (class_id, user_id, quiz_id)
SELECT class.id, "user".id, quiz.id FROM class, "user", quiz;

-- Create answer for each "user" and question
INSERT INTO answer (class_id, user_id, quiz_id, number)
SELECT class_id, user_id, quiz_id, number
FROM assignment
NATURAL INNER JOIN question;

-- Create answer for each true or false question's answer
INSERT INTO answer_true_false (class_id, user_id, quiz_id, number, value)
SELECT class_id, user_id, quiz_id, number, b'1'
FROM question
NATURAL INNER JOIN answer
WHERE question.type = 'true_false';

-- Create answer for each multiple choice question's answer
INSERT INTO answer_multiple_choice (class_id, user_id, quiz_id, number, option_id)
SELECT class_id, user_id, quiz_id, number, 1
FROM question
NATURAL INNER JOIN answer
WHERE question.type = 'multiple_choice';

-- Create three answers for each multiple answer question's answer
INSERT INTO answer_multiple_answer (class_id, user_id, quiz_id, number, option_id)
SELECT class_id, user_id, quiz_id, number, option.i
FROM question
NATURAL INNER JOIN answer
CROSS JOIN N as option
WHERE question.type = 'multiple_answer'
AND i <= 3;

DROP INDEX question_type_idx;
DROP TABLE N;

COMMIT;