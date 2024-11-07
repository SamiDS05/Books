-- Create the database
CREATE DATABASE IF NOT EXISTS github_quiz;
USE github_quiz;

-- Create table for questions
CREATE TABLE questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    question_text VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table for options
CREATE TABLE options (
    option_id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT,
    option_text VARCHAR(255) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id)
);

-- Create table for users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table for quiz attempts
CREATE TABLE quiz_attempts (
    attempt_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    score INT NOT NULL,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Create table for user responses
CREATE TABLE user_responses (
    response_id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT,
    question_id INT,
    selected_option_id INT,
    is_correct BOOLEAN,
    FOREIGN KEY (attempt_id) REFERENCES quiz_attempts(attempt_id),
    FOREIGN KEY (question_id) REFERENCES questions(question_id),
    FOREIGN KEY (selected_option_id) REFERENCES options(option_id)
);

-- Insert the questions
INSERT INTO questions (question_text) VALUES
('O que é o GitHub?'),
('O que é um repositório no GitHub?'),
('O que é um commit?'),
('O que é um pull request?'),
('Para que serve o arquivo README.md?');

-- Insert the options
INSERT INTO options (question_id, option_text, is_correct) VALUES
(1, 'Um editor de código', FALSE),
(1, 'Uma plataforma de hospedagem de código e colaboração', TRUE),
(1, 'Um sistema operacional', FALSE),
(1, 'Uma linguagem de programação', FALSE),

(2, 'Um tipo de arquivo de código', FALSE),
(2, 'Um diretório que contém todos os arquivos do projeto e histórico de versões', TRUE),
(2, 'Uma ferramenta de compilação', FALSE),
(2, 'Um programa de instalação', FALSE),

(3, 'Um erro no código', FALSE),
(3, 'Uma mensagem de erro', FALSE),
(3, 'Um registro de alterações feitas no código', TRUE),
(3, 'Uma branch do repositório', FALSE),

(4, 'Uma solicitação para mesclar alterações de código', TRUE),
(4, 'Um comando para baixar arquivos', FALSE),
(4, 'Uma solicitação para excluir um repositório', FALSE),
(4, 'Um tipo de branch', FALSE),

(5, 'Para executar o projeto', FALSE),
(5, 'Para documentar e descrever o projeto', TRUE),
(5, 'Para compilar o código', FALSE),
(5, 'Para configurar o Git', FALSE);

-- Create view for quiz statistics
CREATE VIEW quiz_statistics AS
SELECT 
    u.username,
    COUNT(qa.attempt_id) as total_attempts,
    AVG(qa.score) as average_score,
    MAX(qa.score) as best_score
FROM users u
LEFT JOIN quiz_attempts qa ON u.user_id = qa.user_id
GROUP BY u.user_id;

-- Create stored procedure for getting question details
DELIMITER //
CREATE PROCEDURE get_question_with_options(IN p_question_id INT)
BEGIN
    SELECT 
        q.question_id,
        q.question_text,
        o.option_id,
        o.option_text,
        o.is_correct
    FROM questions q
    JOIN options o ON q.question_id = o.question_id
    WHERE q.question_id = p_question_id;
END //
DELIMITER ;

-- Create trigger to update quiz_attempts score
DELIMITER //
CREATE TRIGGER calculate_score AFTER INSERT ON user_responses
FOR EACH ROW
BEGIN
    UPDATE quiz_attempts
    SET score = (
        SELECT COUNT(*) 
        FROM user_responses 
        WHERE attempt_id = NEW.attempt_id 
        AND is_correct = TRUE
    )
    WHERE attempt_id = NEW.attempt_id;
END //
DELIMITER ;

-- Create index for better performance
CREATE INDEX idx_user_responses ON user_responses(attempt_id, question_id);
CREATE INDEX idx_quiz_attempts ON quiz_attempts(user_id, completed_at);