--<ScriptOptions statementTerminator=";"/>

CREATE TABLE "DB2INST1"."CUSTOMERS" (
		"ID" BIGINT NOT NULL,
		"CREATIONDATE" TIMESTAMP,
		"NAME" VARCHAR(100) NOT NULL,
		"STATUS" VARCHAR(10),
		"TYPE" VARCHAR(10),
		"UPDATEDATE" TIMESTAMP,
		"ZIPCODE" VARCHAR(254),
		"AGE" DOUBLE,
		"CAROWNER" VARCHAR(254),
		"CHILDREN" INTEGER,
		"CHURN" VARCHAR(254),
		"CHURNRISK" DOUBLE,
		"EMAILADDRESS" VARCHAR(150) NOT NULL,
		"ESTIMATEDINCOME" DOUBLE,
		"FIRSTNAME" VARCHAR(50) NOT NULL,
		"GENDER" VARCHAR(10),
		"LASTNAME" VARCHAR(50) NOT NULL,
		"MARITALSTATUS" VARCHAR(254),
		"MOSTDOMINANTTONE" VARCHAR(254),
		"PROFESSION" VARCHAR(50),
		"ACCOUNT_ACCOUNTNUMBER" VARCHAR(254),
		"CHURNSTATUS" VARCHAR(20),
		"CHURNCLASS" VARCHAR(20)
	)
	DATA CAPTURE NONE;

CREATE INDEX "DB2INST1"."I_CUSTMRS_ACCOUNT"
	ON "DB2INST1"."CUSTOMERS"
	("ACCOUNT_ACCOUNTNUMBER"		ASC) PCTFREE 10
ALLOW REVERSE SCANS;

ALTER TABLE "DB2INST1"."CUSTOMERS" ADD CONSTRAINT "SQL180112224203910" PRIMARY KEY
	("ID");
