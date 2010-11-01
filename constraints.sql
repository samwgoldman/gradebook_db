BEGIN;

ALTER TABLE "user" ADD PRIMARY KEY (id);

ALTER TABLE class ADD PRIMARY KEY (id);

ALTER TABLE class_user ADD FOREIGN KEY (class_id) REFERENCES class (id);
ALTER TABLE class_user ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE class_user ADD PRIMARY KEY (class_id, user_id);

ALTER TABLE quiz ADD PRIMARY KEY (id);

ALTER TABLE question ADD FOREIGN KEY (quiz_id) REFERENCES quiz (id);
ALTER TABLE question ADD PRIMARY KEY (quiz_id, number);

ALTER TABLE "option" ADD PRIMARY KEY (id);

ALTER TABLE question_multiple_choice ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE question_multiple_choice ADD FOREIGN KEY (option_id) REFERENCES "option" (id);
ALTER TABLE question_multiple_choice ADD PRIMARY KEY (quiz_id, number, option_id, "order");

ALTER TABLE question_multiple_answer ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE question_multiple_answer ADD FOREIGN KEY (option_id) REFERENCES "option" (id);
ALTER TABLE question_multiple_answer ADD PRIMARY KEY (quiz_id, number, option_id, "order");

ALTER TABLE solution_true_false ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE solution_true_false ADD PRIMARY KEY (quiz_id, number);

ALTER TABLE solution_multiple_choice ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE solution_multiple_choice ADD FOREIGN KEY (option_id) REFERENCES "option" (id);
ALTER TABLE solution_multiple_choice ADD PRIMARY KEY (quiz_id, number);

ALTER TABLE solution_multiple_answer ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE solution_multiple_answer ADD FOREIGN KEY (option_id) REFERENCES "option" (id);
ALTER TABLE solution_multiple_answer ADD PRIMARY KEY (quiz_id, number, option_id);

ALTER TABLE assignment ADD FOREIGN KEY (class_id) REFERENCES class (id);
ALTER TABLE assignment ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE assignment ADD FOREIGN KEY (quiz_id) REFERENCES quiz (id);
ALTER TABLE assignment ADD PRIMARY KEY (class_id, user_id, quiz_id);

ALTER TABLE answer ADD FOREIGN KEY (class_id, user_id, quiz_id) REFERENCES assignment (class_id, user_id, quiz_id);
ALTER TABLE answer ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE answer ADD PRIMARY KEY (class_id, user_id, quiz_id, number);

ALTER TABLE answer_true_false ADD FOREIGN KEY (class_id, user_id, quiz_id) REFERENCES assignment (class_id, user_id, quiz_id);
ALTER TABLE answer_true_false ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE answer_true_false ADD PRIMARY KEY (class_id, user_id, quiz_id, number);

ALTER TABLE answer_multiple_choice ADD FOREIGN KEY (class_id, user_id, quiz_id) REFERENCES assignment (class_id, user_id, quiz_id);
ALTER TABLE answer_multiple_choice ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE answer_multiple_choice ADD FOREIGN KEY (option_id) REFERENCES "option" (id);
ALTER TABLE answer_multiple_choice ADD PRIMARY KEY (class_id, user_id, quiz_id, number);

ALTER TABLE answer_multiple_answer ADD FOREIGN KEY (class_id, user_id, quiz_id) REFERENCES assignment (class_id, user_id, quiz_id);
ALTER TABLE answer_multiple_answer ADD FOREIGN KEY (quiz_id, number) REFERENCES question (quiz_id, number);
ALTER TABLE answer_multiple_answer ADD FOREIGN KEY (option_id) REFERENCES "option" (id);
ALTER TABLE answer_multiple_answer ADD PRIMARY KEY (class_id, user_id, quiz_id, number, option_id);

COMMIT;

VACUUM FULL ANALYZE;