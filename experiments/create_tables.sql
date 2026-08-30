CREATE TABLE `condition_log` (
 `row` int(11) NOT NULL AUTO_INCREMENT,
 `subjectID` varchar(45) DEFAULT NULL,
 `assignedCondition` int(11) DEFAULT NULL,
 PRIMARY KEY (`row`)
);


CREATE TABLE `data_log` (
 `responses` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`responses`)),
 `question_order` text DEFAULT NULL,
 `trial_type` varchar(45) DEFAULT NULL,
 `trial_index` int(11) DEFAULT NULL,
 `rt` float DEFAULT NULL,
 `time_elapsed` float DEFAULT NULL,
 `condition` int(11) DEFAULT NULL,
 `response` float DEFAULT NULL,
 `prompt` varchar(45) DEFAULT NULL,
 `color_rgb` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
 `concept` varchar(45) DEFAULT NULL,
 `time_finished` float DEFAULT NULL,
 `rowID` int(11) NOT NULL AUTO_INCREMENT,
 `color_index` int(11) DEFAULT NULL,
 `concept_category` text DEFAULT NULL,
 `subject_id` text DEFAULT NULL,
 `workerID` varchar(100) NOT NULL,
 PRIMARY KEY (`rowID`)
);


CREATE TABLE `register_log` (
 `row` int(11) NOT NULL AUTO_INCREMENT,
 `completionCode` varchar(45) DEFAULT NULL,
 `workerID` varchar(45) DEFAULT NULL,
 PRIMARY KEY (`row`)
);