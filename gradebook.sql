-- CLEANUP

DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- USER

CREATE TABLE "user" (
  id serial
);

-- CLASS

CREATE TABLE class (
  id serial
);

CREATE TABLE class_user (
  class_id integer not null,
  user_id integer not null
);

-- QUIZ

CREATE TABLE quiz (
  id serial
);

-- QUESTION

CREATE TYPE question_type AS ENUM ('true_false', 'multiple_choice', 'multiple_answer');

CREATE TABLE question (
  quiz_id integer not null,
  number integer not null,
  type question_type not null,
  points integer not null
);

CREATE TABLE "option" (
  id serial
);

CREATE TABLE question_multiple_choice (
  quiz_id integer not null,
  number integer not null,
  option_id integer not null,
  "order" integer not null
);

CREATE TABLE question_multiple_answer (
  quiz_id integer not null,
  number integer not null,
  option_id integer not null,
  "order" integer not null
);

-- SOLUTION

CREATE TABLE solution_true_false (
  quiz_id integer not null,
  number integer not null,
  truth bit not null
);

CREATE TABLE solution_multiple_choice (
  quiz_id integer not null,
  number integer not null,
  option_id integer not null
);

CREATE TABLE solution_multiple_answer (
  quiz_id integer not null,
  number integer not null,
  option_id integer not null
);

-- ASSIGNMENT

CREATE TABLE assignment (
  class_id integer not null,
  user_id integer not null,
  quiz_id integer not null
);

-- ANSWER

CREATE TABLE answer (
  class_id integer not null,
  user_id integer not null,
  quiz_id integer not null,
  number integer not null
);

CREATE TABLE answer_true_false (
  class_id integer not null,
  user_id integer not null,
  quiz_id integer not null,
  number integer not null,
  value bit not null
);

CREATE TABLE answer_multiple_choice (
  class_id integer not null,
  user_id integer not null,
  quiz_id integer not null,
  number integer not null,
  option_id integer not null
);

CREATE TABLE answer_multiple_answer (
  class_id integer not null,
  user_id integer not null,
  quiz_id integer not null,
  number integer not null,
  option_id integer not null
);

-- VIEWS

CREATE VIEW score_true_false AS
  SELECT
    class_id, user_id, quiz_id, number,
    CASE
      WHEN solution.truth = answer.value THEN question.points
      ELSE 0
    END as score
  FROM question
  NATURAL JOIN solution_true_false solution
  NATURAL JOIN answer_true_false answer;

CREATE VIEW score_multiple_choice AS
  SELECT
    class_id, user_id, quiz_id, number,
    CASE
      WHEN solution.option_id = answer.option_id THEN question.points
      ELSE 0
    END as score
  FROM question
  NATURAL JOIN solution_multiple_choice solution
  NATURAL JOIN answer_multiple_choice answer;

CREATE VIEW score_multiple_answer AS
  SELECT
    class_id, user_id, quiz_id, number,
    CASE
      WHEN answer.option_sum = solution.option_sum THEN points
      ELSE 0
    END as score
  FROM (
    SELECT class_id, user_id, quiz_id, number, SUM(answer.option_id) option_sum
    FROM answer_multiple_answer answer
    GROUP BY class_id, user_id, quiz_id, number
  ) AS answer
  INNER JOIN (
    SELECT quiz_id, number, points, SUM(solution.option_id) option_sum
    FROM question
    NATURAL JOIN solution_multiple_answer solution
    GROUP BY quiz_id, number, points
  ) AS solution USING (quiz_id, number);

CREATE VIEW score AS
  SELECT * FROM score_true_false
  UNION
  SELECT * FROM score_multiple_choice
  UNION
  SELECT * FROM score_multiple_answer;

CREATE VIEW quiz_points AS
  SELECT quiz.id as quiz_id, SUM(question.points) as points
  FROM quiz
  INNER JOIN question ON question.quiz_id = quiz.id
  GROUP BY quiz.id;

CREATE VIEW class_points AS
  SELECT class_id, SUM(question.points) as points
  FROM (SELECT class_id, quiz_id FROM assignment GROUP BY class_id, quiz_id) assignment
  NATURAL JOIN question
  GROUP BY class_id;

CREATE VIEW assignment_score AS
  SELECT class_id, user_id, quiz_id, SUM(score) as score
  FROM score
  GROUP BY class_id, user_id, quiz_id;

CREATE VIEW assignment_percent_score AS
  SELECT class_id, user_id, quiz_id, ROUND(score / points * 100) as percent_score
  FROM assignment_score
  NATURAL JOIN quiz_points;

CREATE VIEW assignment_average_score AS
  SELECT class_id, quiz_id, ROUND(AVG(score)) as average_score
  FROM assignment_score
  GROUP BY class_id, quiz_id;

CREATE VIEW assignment_average_percent_score AS
  SELECT class_id, quiz_id, ROUND(average_score / points * 100) as average_percent_score
  FROM assignment_average_score
  NATURAL JOIN quiz_points;

CREATE VIEW user_score AS
  SELECT class_id, user_id, SUM(score) as score
  FROM assignment_score
  GROUP BY class_id, user_id;

CREATE VIEW user_percent_score AS
  SELECT class_id, user_id, ROUND(score / points * 100) as percent_score
  FROM user_score
  NATURAL JOIN class_points;
