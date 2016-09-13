
ALTER TABLE `thinkbig`.`BATCH_NIFI_JOB`
CHANGE COLUMN `FLOW_FILE_UUID` `FLOW_FILE_ID` VARCHAR(255) NOT NULL DEFAULT '';


ALTER TABLE `thinkbig`.`BATCH_NIFI_STEP`
ADD COLUMN `FLOW_FILE_ID` VARCHAR(45) NULL;

ALTER TABLE `thinkbig`.`BATCH_NIFI_STEP`
ADD COLUMN `JOB_FLOW_FILE_ID` VARCHAR(45) NULL;


CREATE TABLE `GENERATED_KEYS` (
  `PK_COLUMN` varchar(255) NOT NULL,
  `VALUE_COLUMN` bigint(20) NOT NULL,
  PRIMARY KEY (`PK_COLUMN`)
) ENGINE=InnoDB;


/**
INSERT THE MAX ids into the GENERATED_KEYS table
*/

INSERT INTO `thinkbig`.`GENERATED_KEYS`
(`PK_COLUMN`,
`VALUE_COLUMN`)
SELECT 'JOB_INSTANCE_ID', MAX(JOB_INSTANCE_ID) FROM BATCH_JOB_INSTANCE;

INSERT INTO `thinkbig`.`GENERATED_KEYS`
(`PK_COLUMN`,
`VALUE_COLUMN`)
SELECT 'JOB_EXECUTION_ID', MAX(JOB_EXECUTION_ID) FROM BATCH_JOB_EXECUTION;

INSERT INTO `thinkbig`.`GENERATED_KEYS`
(`PK_COLUMN`,
`VALUE_COLUMN`)
SELECT 'STEP_EXECUTION_ID', MAX(STEP_EXECUTION_ID) FROM BATCH_STEP_EXECUTION;



CREATE TABLE `BATCH_JOB_EXECUTION_CTX_VALS` (
  `JOB_EXECUTION_ID` bigint(20) NOT NULL,
  `TYPE_CD` varchar(10) NOT NULL,
  `KEY_NAME` varchar(100) NOT NULL,
  `STRING_VAL` longtext,
  `DATE_VAL` timestamp NULL DEFAULT NULL,
  `LONG_VAL` bigint(20) DEFAULT NULL,
  `DOUBLE_VAL` double DEFAULT NULL,
  `CREATE_DATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ID` varchar(45) NOT NULL,
  UNIQUE KEY `BATCH_JOB_EXEC_CTX_VALS_UQ1` (`JOB_EXECUTION_ID`,`KEY_NAME`),
  KEY `BATCH_JOB_EXEC_CTX_VALS_PK` (`ID`)
) ENGINE=InnoDB;

CREATE TABLE `BATCH_STEP_EXECUTION_CTX_VALS` (
  `JOB_EXECUTION_ID` bigint(20) NOT NULL,
  `STEP_EXECUTION_ID` bigint(20) NOT NULL DEFAULT '0',
  `EXECUTION_CONTEXT_TYPE` varchar(6) DEFAULT NULL,
  `TYPE_CD` varchar(10) NOT NULL,
  `KEY_NAME` varchar(100) NOT NULL,
  `STRING_VAL` longtext,
  `DATE_VAL` timestamp NULL DEFAULT NULL,
  `LONG_VAL` bigint(20) DEFAULT NULL,
  `DOUBLE_VAL` double DEFAULT NULL,
  `CREATE_DATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ID` varchar(45) DEFAULT NULL,
  KEY `BATCH_STEP_EXEC_CTX_VALS_PK` (`ID`),
  KEY `BATCH_STEP_EXEC_CTX_VALS_UQ1` (`STEP_EXECUTION_ID`,`KEY_NAME`)
) ENGINE=InnoDB;



CREATE TABLE `NIFI_EVENT` (
  `EVENT_ID` bigint(20) NOT NULL,
  `FLOW_FILE_ID` varchar(45) NOT NULL,
  `FM_FEED_NAME` varchar(255) DEFAULT NULL,
  `EVENT_TIME` timestamp NULL DEFAULT NULL,
  `EVENT_DURATION_MILLIS` bigint(20) DEFAULT NULL,
  `EVENT_TYPE` varchar(45) DEFAULT NULL,
  `SOURCE_CONNECTION_ID` varchar(45) DEFAULT NULL,
  `PROCESSOR_ID` varchar(45) DEFAULT NULL,
  `FEED_PROCESS_GROUP_ID` varchar(45) DEFAULT NULL,
  `FILE_SIZE` varchar(100) DEFAULT NULL,
  `FILE_SIZE_BYTES` bigint(20) DEFAULT NULL,
  `PARENT_FLOW_FILE_IDS` varchar(255) DEFAULT NULL,
  `CHILD_FLOW_FILE_IDS` varchar(255) DEFAULT NULL,
  `ATTRIBUTES_JSON` longtext,
  `EVENT_DETAILS` mediumtext,
  `PROCESSOR_NAME` varchar(255) DEFAULT NULL,
  `JOB_FLOW_FILE_ID` varchar(45) DEFAULT NULL,
  `IS_END_OF_JOB` varchar(1) DEFAULT NULL,
  `IS_START_OF_JOB` varchar(1) DEFAULT NULL,
  `IS_BATCH_JOB` varchar(1) DEFAULT NULL,
  `IS_FAILURE` varchar(1) DEFAULT NULL,
  `IS_FINAL_JOB_EVENT` varchar(45) DEFAULT NULL COMMENT 'Y/N .  This will be set to Y when this is the last event for any and all related parent root flow files.  This indicator marks the true complete end of a large job that may have merged many files together to a single event.',
  `HAS_FAILURE_EVENTS` varchar(1) DEFAULT NULL,
  `VERSION` int(11) DEFAULT NULL,
  `CREATED_TIME` timestamp NULL DEFAULT NULL,
  `MODIFIED_TIME` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`EVENT_ID`,`FLOW_FILE_ID`)
) ENGINE=InnoDB;

CREATE TABLE `NIFI_FEED_PROCESSOR_STATS` (
  `FM_FEED_NAME` varchar(45) NOT NULL,
  `NIFI_PROCESSOR_ID` varchar(45) NOT NULL,
  `NIFI_FEED_PROCESS_GROUP_ID` varchar(45) DEFAULT NULL,
  `COLLECTION_TIME` timestamp NULL DEFAULT NULL,
  `TOTAL_EVENTS` int(11) DEFAULT NULL,
  `DURATION_MILLIS` bigint(19) DEFAULT NULL,
  `BYTES_IN` bigint(19) DEFAULT NULL,
  `BYTES_OUT` bigint(19) DEFAULT NULL,
  `MIN_EVENT_TIME` timestamp NULL DEFAULT NULL,
  `MAX_EVENT_TIME` timestamp NULL DEFAULT NULL,
  `JOBS_STARTED` bigint(20) DEFAULT NULL,
  `JOBS_FINISHED` bigint(20) DEFAULT NULL,
  `JOBS_FAILED` bigint(20) DEFAULT NULL,
  `PROCESSORS_FAILED` bigint(20) DEFAULT NULL,
  `FLOW_FILES_STARTED` bigint(20) DEFAULT NULL,
  `FLOW_FILES_FINISHED` bigint(20) DEFAULT NULL,
  `COLLECTION_ID` varchar(45) DEFAULT NULL,
  `COLLECTION_INTERVAL_SEC` bigint(20) DEFAULT NULL,
  `ID` varchar(45) NOT NULL,
  `PROCESSOR_NAME` varchar(255) DEFAULT NULL,
  `JOB_DURATION` bigint(20) DEFAULT NULL,
  `SUCCESSFUL_JOB_DURATION` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FM_FEED_NAME` (`FM_FEED_NAME`),
  KEY `MIN_EVENT_TIME` (`MIN_EVENT_TIME`),
  KEY `MAX_EVENT_TIME` (`MAX_EVENT_TIME`)
) ENGINE=InnoDB;

CREATE TABLE `NIFI_RELATED_ROOT_FLOW_FILES` (
  `FLOW_FILE_ID` varchar(45) NOT NULL,
  `RELATION_ID` varchar(45) NOT NULL,
  `EVENT_ID` bigint(20) DEFAULT NULL,
  `EVENT_FLOW_FILE_ID` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`FLOW_FILE_ID`)
) ENGINE=InnoDB;



/**
Remove any orphan records so FKs work
 */
DELETE FROM BATCH_NIFI_JOB
WHERE JOB_EXECUTION_ID NOT IN(SELECT JOB_EXECUTION_ID from BATCH_JOB_EXECUTION);

DELETE FROM BATCH_NIFI_STEP
WHERE STEP_EXECUTION_ID NOT IN(SELECT STEP_EXECUTION_ID from BATCH_STEP_EXECUTION);



alter table BATCH_NIFI_JOB
ADD CONSTRAINT fk_JOB_EXECUTION
FOREIGN KEY(JOB_EXECUTION_ID)
REFERENCES BATCH_JOB_EXECUTION(JOB_EXECUTION_ID);

alter table BATCH_NIFI_STEP
ADD CONSTRAINT fk_STEP_EXECUTION
FOREIGN KEY(STEP_EXECUTION_ID)
REFERENCES BATCH_STEP_EXECUTION(STEP_EXECUTION_ID);

ALTER TABLE `thinkbig`.`BATCH_NIFI_JOB`
ADD PRIMARY KEY (`EVENT_ID`, `FLOW_FILE_ID`)  ,
ADD UNIQUE INDEX `BATCH_NIFI_JOB_UQ1` (`JOB_EXECUTION_ID` ASC)  ;


ALTER TABLE `thinkbig`.`BATCH_NIFI_STEP`
ADD PRIMARY KEY (`EVENT_ID`, `FLOW_FILE_ID`)  ,
ADD UNIQUE INDEX `BATCH_NIFI_STEP_UQ1` (`STEP_EXECUTION_ID` ASC),
ADD UNIQUE INDEX `BATCH_NIFI_STEP_UQ2` (`COMPONENT_ID` ASC, `JOB_FLOW_FILE_ID` ASC),
ADD INDEX `BATCH_NIFI_STEP_IDX1` (`JOB_FLOW_FILE_ID` ASC);


/**
DEPRECATED TABLES ARE

 `BATCH_EXECUTION_CONTEXT_VALUES`
 BATCH_JOB_SEQ
 BATCH_JOB_EXECUTION_SEQ
 BATCH_STEP_EXECUTION_SEQ

  */