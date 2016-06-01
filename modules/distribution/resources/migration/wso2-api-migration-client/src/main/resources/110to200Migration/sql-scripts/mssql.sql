ALTER TABLE AM_API  ADD API_TIER VARCHAR(256);


-- AM Throttling tables --
IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_POLICY_SUBSCRIPTION]') AND TYPE IN (N'U'))
CREATE TABLE AM_POLICY_SUBSCRIPTION (
            POLICY_ID INTEGER IDENTITY(1,1),
            NAME VARCHAR(512) NOT NULL,
            DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,
            TENANT_ID INTEGER NOT NULL,
            DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
            QUOTA_TYPE VARCHAR(25) NOT NULL,
            QUOTA INTEGER NOT NULL,
            QUOTA_UNIT VARCHAR(10) NULL,
            UNIT_TIME INTEGER NOT NULL,
            TIME_UNIT VARCHAR(25) NOT NULL,
            RATE_LIMIT_COUNT INTEGER NULL DEFAULT NULL,
            RATE_LIMIT_TIME_UNIT VARCHAR(25) NULL DEFAULT NULL,
            IS_DEPLOYED BIT NOT NULL DEFAULT 0,
			CUSTOM_ATTRIBUTES VARBINARY(MAX) DEFAULT NULL,
            STOP_ON_QUOTA_REACH BIT NOT NULL DEFAULT 0,
            BILLING_PLAN VARCHAR(20) NOT NULL,
            PRIMARY KEY (POLICY_ID),
            UNIQUE (NAME, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_POLICY_APPLICATION]') AND TYPE IN (N'U'))
CREATE TABLE AM_POLICY_APPLICATION (
            POLICY_ID INTEGER IDENTITY(1,1),
            NAME VARCHAR(512) NOT NULL,
            DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,
            TENANT_ID INTEGER NOT NULL,
            DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
            QUOTA_TYPE VARCHAR(25) NOT NULL,
            QUOTA INTEGER NOT NULL,
            QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,
            UNIT_TIME INTEGER NOT NULL,
            TIME_UNIT VARCHAR(25) NOT NULL,
            IS_DEPLOYED BIT NOT NULL DEFAULT 0,
			CUSTOM_ATTRIBUTES VARBINARY(MAX) DEFAULT NULL,
            PRIMARY KEY (POLICY_ID),
            UNIQUE  (NAME, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_POLICY_HARD_THROTTLING]') AND TYPE IN (N'U'))
CREATE TABLE AM_POLICY_HARD_THROTTLING (
            POLICY_ID INTEGER IDENTITY(1,1),
            NAME VARCHAR(512) NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
            QUOTA_TYPE VARCHAR(25) NOT NULL,
            QUOTA INTEGER NOT NULL,
            QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,
            UNIT_TIME INTEGER NOT NULL,
            TIME_UNIT VARCHAR(25) NOT NULL,
            IS_DEPLOYED BIT NOT NULL DEFAULT 0,
            PRIMARY KEY (POLICY_ID),
            UNIQUE  (NAME, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_API_THROTTLE_POLICY]') AND TYPE IN (N'U'))
CREATE TABLE AM_API_THROTTLE_POLICY (
            POLICY_ID INTEGER IDENTITY(1,1),
            NAME VARCHAR(512) NOT NULL,
            DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,
            TENANT_ID INTEGER NOT NULL,
            DESCRIPTION VARCHAR (1024),
            DEFAULT_QUOTA_TYPE VARCHAR(25) NOT NULL,
            DEFAULT_QUOTA INTEGER NOT NULL,
            DEFAULT_QUOTA_UNIT VARCHAR(10) NULL,
            DEFAULT_UNIT_TIME INTEGER NOT NULL,
            DEFAULT_TIME_UNIT VARCHAR(25) NOT NULL,
            APPLICABLE_LEVEL VARCHAR(25) NOT NULL,
            IS_DEPLOYED BIT NOT NULL DEFAULT 0,
            PRIMARY KEY (POLICY_ID),
            UNIQUE  (NAME, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_CONDITION_GROUP]') AND TYPE IN (N'U'))
CREATE TABLE AM_CONDITION_GROUP (
            CONDITION_GROUP_ID INTEGER IDENTITY(1,1),
            POLICY_ID INTEGER NOT NULL,
            QUOTA_TYPE VARCHAR(25),
            QUOTA INTEGER NOT NULL,
            QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,
            UNIT_TIME INTEGER NOT NULL,
            TIME_UNIT VARCHAR(25) NOT NULL,
            DESCRIPTION VARCHAR (1024) NULL DEFAULT NULL,
            PRIMARY KEY (CONDITION_GROUP_ID),
            FOREIGN KEY (POLICY_ID) REFERENCES AM_API_THROTTLE_POLICY(POLICY_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_QUERY_PARAMETER_CONDITION]') AND TYPE IN (N'U'))
CREATE TABLE AM_QUERY_PARAMETER_CONDITION (
            QUERY_PARAMETER_ID INTEGER IDENTITY(1,1),
            CONDITION_GROUP_ID INTEGER NOT NULL,
            PARAMETER_NAME VARCHAR(255) DEFAULT NULL,
            PARAMETER_VALUE VARCHAR(255) DEFAULT NULL,
	    	IS_PARAM_MAPPING BIT DEFAULT 1,
            PRIMARY KEY (QUERY_PARAMETER_ID),
            FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_HEADER_FIELD_CONDITION]') AND TYPE IN (N'U'))
CREATE TABLE AM_HEADER_FIELD_CONDITION (
            HEADER_FIELD_ID INTEGER IDENTITY(1,1),
            CONDITION_GROUP_ID INTEGER NOT NULL,
            HEADER_FIELD_NAME VARCHAR(255) DEFAULT NULL,
            HEADER_FIELD_VALUE VARCHAR(255) DEFAULT NULL,
	    	IS_HEADER_FIELD_MAPPING BIT DEFAULT 1,
            PRIMARY KEY (HEADER_FIELD_ID),
            FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_JWT_CLAIM_CONDITION]') AND TYPE IN (N'U'))
CREATE TABLE AM_JWT_CLAIM_CONDITION (
            JWT_CLAIM_ID INTEGER IDENTITY(1,1),
            CONDITION_GROUP_ID INTEGER NOT NULL,
            CLAIM_URI VARCHAR(512) DEFAULT NULL,
            CLAIM_ATTRIB VARCHAR(1024) DEFAULT NULL,
	    IS_CLAIM_MAPPING BIT DEFAULT 1,
            PRIMARY KEY (JWT_CLAIM_ID),
            FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_IP_CONDITION]') AND TYPE IN (N'U'))
CREATE TABLE AM_IP_CONDITION (
  AM_IP_CONDITION_ID INTEGER IDENTITY(1,1),
  STARTING_IP VARCHAR(45) NULL,
  ENDING_IP VARCHAR(45) NULL,
  SPECIFIC_IP VARCHAR(45) NULL,
  WITHIN_IP_RANGE BIT DEFAULT 1,
  CONDITION_GROUP_ID INT NULL,
  PRIMARY KEY (AM_IP_CONDITION_ID),
  FOREIGN KEY (CONDITION_GROUP_ID)
    REFERENCES AM_CONDITION_GROUP (CONDITION_GROUP_ID)   ON DELETE CASCADE ON UPDATE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_POLICY_GLOBAL]') AND TYPE IN (N'U'))
CREATE TABLE AM_POLICY_GLOBAL (
            POLICY_ID INTEGER IDENTITY(1,1),
            NAME VARCHAR(512) NOT NULL,
            KEY_TEMPLATE VARCHAR(512) NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
            SIDDHI_QUERY VARBINARY(MAX) DEFAULT NULL,
            IS_DEPLOYED BIT NOT NULL DEFAULT 0,
            PRIMARY KEY (POLICY_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_THROTTLE_TIER_PERMISSIONS]') AND TYPE IN (N'U'))
CREATE TABLE AM_THROTTLE_TIER_PERMISSIONS (
  THROTTLE_TIER_PERMISSIONS_ID INTEGER IDENTITY(1,1),
  TIER VARCHAR(50) NULL,
  PERMISSIONS_TYPE VARCHAR(50) NULL,
  ROLES VARCHAR(512) NULL,
  TENANT_ID INTEGER NULL,
  PRIMARY KEY (THROTTLE_TIER_PERMISSIONS_ID));

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[AM_BLOCK_CONDITIONS]') AND TYPE IN (N'U'))
CREATE TABLE AM_BLOCK_CONDITIONS (
  CONDITION_ID INTEGER IDENTITY(1,1),
  TYPE varchar(45) DEFAULT NULL,
  VALUE varchar(45) DEFAULT NULL,
  ENABLED varchar(45) DEFAULT NULL,
  DOMAIN varchar(45) DEFAULT NULL,
  PRIMARY KEY (CONDITION_ID)
);

-- End of API-MGT Tables --

-- Performance indexes start--

create index IDX_ITS_LMT on IDN_THRIFT_SESSION (LAST_MODIFIED_TIME);
create index IDX_IOAT_AT on IDN_OAUTH2_ACCESS_TOKEN (ACCESS_TOKEN);
create index IDX_IOAT_UT on IDN_OAUTH2_ACCESS_TOKEN (USER_TYPE);
create index IDX_AAI_CTX on AM_API (CONTEXT);
create index IDX_AAKM_CK on AM_APPLICATION_KEY_MAPPING (CONSUMER_KEY);
create index IDX_AAUM_AI on AM_API_URL_MAPPING (API_ID);
create index IDX_AAUM_TT on AM_API_URL_MAPPING (THROTTLING_TIER);
create index IDX_AATP_DQT on AM_API_THROTTLE_POLICY (DEFAULT_QUOTA_TYPE);
create index IDX_ACG_QT on AM_CONDITION_GROUP (QUOTA_TYPE);
create index IDX_APS_QT on AM_POLICY_SUBSCRIPTION (QUOTA_TYPE);
create index IDX_AS_AITIAI on AM_SUBSCRIPTION (API_ID,TIER_ID,APPLICATION_ID);
create index IDX_APA_QT on AM_POLICY_APPLICATION (QUOTA_TYPE);
create index IDX_AA_AT_CB on AM_APPLICATION (APPLICATION_TIER,CREATED_BY);
